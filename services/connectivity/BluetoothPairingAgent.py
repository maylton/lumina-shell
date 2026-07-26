#!/usr/bin/env python3
"""BlueZ pairing agent bridge for Lumina Shell.

The helper exports org.bluez.Agent1 on the system bus, sends newline-delimited
JSON events to QML, and accepts newline-delimited JSON responses on stdin.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import re
import signal
import sys
from typing import Any

ADDRESS_RE = re.compile(r"^[0-9A-F]{2}(?::[0-9A-F]{2}){5}$")
BLUEZ_SERVICE = "org.bluez"
BLUEZ_ROOT = "/org/bluez"
OBJECT_MANAGER_PATH = "/"
AGENT_PATH = "/org/lumina/BluetoothAgent"
AGENT_INTERFACE = "org.bluez.Agent1"
AGENT_MANAGER_INTERFACE = "org.bluez.AgentManager1"
DEVICE_INTERFACE = "org.bluez.Device1"
ADAPTER_INTERFACE = "org.bluez.Adapter1"
PROPERTIES_INTERFACE = "org.freedesktop.DBus.Properties"
OBJECT_MANAGER_INTERFACE = "org.freedesktop.DBus.ObjectManager"
CAPABILITY = "KeyboardDisplay"


def emit(event_type: str, **payload: Any) -> None:
    message = {"type": event_type, **payload}
    sys.stdout.write(json.dumps(message, ensure_ascii=False) + "\n")
    sys.stdout.flush()


def normalize_address(value: str) -> str:
    address = str(value or "").strip().upper()
    return address if ADDRESS_RE.fullmatch(address) else ""


def variant_value(value: Any) -> Any:
    return getattr(value, "value", value)


def pairing_code(value: int) -> str:
    return f"{int(value):06d}"


def find_device_paths(managed_objects: dict[str, Any], address: str) -> tuple[str, str]:
    requested = normalize_address(address)
    if not requested:
        return "", ""

    for path, interfaces in managed_objects.items():
        properties = interfaces.get(DEVICE_INTERFACE)
        if not properties:
            continue

        candidate = str(variant_value(properties.get("Address", ""))).upper()
        if candidate != requested:
            continue

        adapter_path = str(variant_value(properties.get("Adapter", "")))
        return str(path), adapter_path

    return "", ""


async def stream_reader() -> asyncio.StreamReader:
    reader = asyncio.StreamReader()
    protocol = asyncio.StreamReaderProtocol(reader)
    loop = asyncio.get_running_loop()
    await loop.connect_read_pipe(lambda: protocol, sys.stdin)
    return reader


async def run(address: str) -> int:
    try:
        from dbus_next import DBusError, Variant
        from dbus_next.aio import MessageBus
        from dbus_next.constants import BusType
        from dbus_next.service import ServiceInterface, method
    except ImportError as error:
        emit(
            "failed",
            code="missing-dbus-next",
            message="Install python-dbus-next to use Bluetooth authentication",
        )
        sys.stderr.write(str(error) + "\n")
        return 8

    class LuminaBluetoothAgent(ServiceInterface):
        def __init__(self) -> None:
            super().__init__(AGENT_INTERFACE)
            self.pending: asyncio.Future[Any] | None = None
            self.pending_kind = ""

        def _clear_pending(self) -> None:
            self.pending = None
            self.pending_kind = ""

        async def _request(self, kind: str, **payload: Any) -> Any:
            if self.pending is not None and not self.pending.done():
                raise DBusError(
                    "org.bluez.Error.Rejected",
                    "another pairing request is already pending",
                )

            future: asyncio.Future[Any] = asyncio.get_running_loop().create_future()
            self.pending = future
            self.pending_kind = kind
            emit("prompt", kind=kind, **payload)

            try:
                return await future
            finally:
                if self.pending is future:
                    self._clear_pending()

        def accept(self, value: Any = True) -> bool:
            if self.pending is None or self.pending.done():
                return False
            self.pending.set_result(value)
            return True

        def reject(self, reason: str = "user rejected pairing") -> bool:
            if self.pending is None or self.pending.done():
                return False
            self.pending.set_exception(
                DBusError("org.bluez.Error.Rejected", reason)
            )
            return True

        def cancel_pending(self, reason: str = "pairing canceled") -> bool:
            if self.pending is None or self.pending.done():
                return False
            self.pending.set_exception(
                DBusError("org.bluez.Error.Canceled", reason)
            )
            return True

        @method()
        def Release(self) -> None:
            self.cancel_pending("BlueZ released the pairing agent")

        @method()
        async def RequestPinCode(self, device: "o") -> "s":
            value = await self._request("pin", device=str(device))
            return str(value)

        @method()
        def DisplayPinCode(self, device: "o", pincode: "s") -> None:
            emit(
                "display",
                kind="display-pin",
                device=str(device),
                code=str(pincode),
            )

        @method()
        async def RequestPasskey(self, device: "o") -> "u":
            value = await self._request("passkey", device=str(device))
            return int(value)

        @method()
        def DisplayPasskey(
            self,
            device: "o",
            passkey: "u",
            entered: "q",
        ) -> None:
            emit(
                "display",
                kind="display-passkey",
                device=str(device),
                code=pairing_code(passkey),
                entered=int(entered),
            )

        @method()
        async def RequestConfirmation(
            self,
            device: "o",
            passkey: "u",
        ) -> None:
            accepted = await self._request(
                "confirmation",
                device=str(device),
                code=pairing_code(passkey),
            )
            if not accepted:
                raise DBusError(
                    "org.bluez.Error.Rejected",
                    "user rejected pairing confirmation",
                )

        @method()
        async def RequestAuthorization(self, device: "o") -> None:
            accepted = await self._request("authorize", device=str(device))
            if not accepted:
                raise DBusError(
                    "org.bluez.Error.Rejected",
                    "user rejected pairing authorization",
                )

        @method()
        async def AuthorizeService(self, device: "o", uuid: "s") -> None:
            accepted = await self._request(
                "authorize",
                device=str(device),
                service=str(uuid),
            )
            if not accepted:
                raise DBusError(
                    "org.bluez.Error.Rejected",
                    "user rejected Bluetooth service",
                )

        @method()
        def Cancel(self) -> None:
            self.cancel_pending("BlueZ canceled pairing")

    async def proxy_interface(bus: Any, path: str, interface_name: str) -> Any:
        introspection = await bus.introspect(BLUEZ_SERVICE, path)
        proxy = bus.get_proxy_object(BLUEZ_SERVICE, path, introspection)
        return proxy.get_interface(interface_name)

    async def command_loop(
        reader: asyncio.StreamReader,
        agent: LuminaBluetoothAgent,
        cancel_event: asyncio.Event,
    ) -> None:
        while not cancel_event.is_set():
            line = await reader.readline()
            if not line:
                agent.cancel_pending("Lumina pairing UI closed")
                cancel_event.set()
                return

            try:
                command = json.loads(line.decode("utf-8", "replace"))
            except (json.JSONDecodeError, UnicodeDecodeError):
                continue

            action = str(command.get("action", ""))
            if action == "accept":
                agent.accept(True)
            elif action == "reject":
                agent.reject()
            elif action == "value":
                value = str(command.get("value", "")).strip()
                if agent.pending_kind == "pin":
                    valid = 1 <= len(value) <= 16 and "\n" not in value
                    if valid:
                        agent.accept(value)
                    else:
                        emit("invalid-response", kind="pin")
                elif agent.pending_kind == "passkey":
                    valid = value.isdigit() and 1 <= len(value) <= 6
                    valid = valid and int(value) <= 999999
                    if valid:
                        agent.accept(int(value))
                    else:
                        emit("invalid-response", kind="passkey")
            elif action == "cancel":
                agent.cancel_pending(str(command.get("reason", "user canceled")))
                cancel_event.set()
                return

    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()
    agent = LuminaBluetoothAgent()
    bus.export(AGENT_PATH, agent)

    agent_manager = None
    command_task: asyncio.Task[None] | None = None
    pair_task: asyncio.Task[Any] | None = None

    try:
        object_manager = await proxy_interface(
            bus,
            OBJECT_MANAGER_PATH,
            OBJECT_MANAGER_INTERFACE,
        )
        managed_objects = await object_manager.call_get_managed_objects()
        device_path, adapter_path = find_device_paths(managed_objects, address)
        if not device_path or not adapter_path:
            emit(
                "failed",
                code="device-not-found",
                message=f"Bluetooth device {address} is no longer available",
            )
            return 4

        agent_manager = await proxy_interface(
            bus,
            BLUEZ_ROOT,
            AGENT_MANAGER_INTERFACE,
        )
        await agent_manager.call_register_agent(AGENT_PATH, CAPABILITY)
        await agent_manager.call_request_default_agent(AGENT_PATH)
        emit("agent-ready", address=address)

        adapter_properties = await proxy_interface(
            bus,
            adapter_path,
            PROPERTIES_INTERFACE,
        )
        await adapter_properties.call_set(
            ADAPTER_INTERFACE,
            "Powered",
            Variant("b", True),
        )
        await adapter_properties.call_set(
            ADAPTER_INTERFACE,
            "Pairable",
            Variant("b", True),
        )

        device = await proxy_interface(bus, device_path, DEVICE_INTERFACE)
        reader = await stream_reader()
        cancel_event = asyncio.Event()
        loop = asyncio.get_running_loop()

        for handled_signal in (signal.SIGINT, signal.SIGTERM):
            try:
                loop.add_signal_handler(handled_signal, cancel_event.set)
            except NotImplementedError:
                pass

        command_task = asyncio.create_task(
            command_loop(reader, agent, cancel_event)
        )
        pair_task = asyncio.create_task(device.call_pair())
        cancel_task = asyncio.create_task(cancel_event.wait())
        emit("ready", address=address)

        done, _ = await asyncio.wait(
            {pair_task, cancel_task},
            return_when=asyncio.FIRST_COMPLETED,
        )

        if cancel_task in done and cancel_event.is_set():
            agent.cancel_pending("user canceled pairing")
            try:
                await device.call_cancel_pairing()
            except Exception:
                pass
            if not pair_task.done():
                pair_task.cancel()
            await asyncio.gather(pair_task, return_exceptions=True)
            emit("cancelled", reason="user")
            return 3

        cancel_task.cancel()
        await asyncio.gather(cancel_task, return_exceptions=True)
        await pair_task
        emit("completed", address=address)
        return 0
    except DBusError as error:
        error_type = str(getattr(error, "type", "org.bluez.Error.Failed"))
        error_text = str(getattr(error, "text", "") or error)
        emit(
            "failed",
            code="pair-failed",
            dbusError=error_type,
            message=error_text,
        )
        return 5
    except Exception as error:
        emit(
            "failed",
            code="agent-failed",
            message=str(error),
        )
        return 6
    finally:
        agent.cancel_pending("pairing agent stopped")
        if command_task is not None:
            command_task.cancel()
            await asyncio.gather(command_task, return_exceptions=True)
        if pair_task is not None and not pair_task.done():
            pair_task.cancel()
            await asyncio.gather(pair_task, return_exceptions=True)
        if agent_manager is not None:
            try:
                await agent_manager.call_unregister_agent(AGENT_PATH)
            except Exception:
                pass
        try:
            bus.unexport(AGENT_PATH, agent)
        except Exception:
            pass
        bus.disconnect()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("address")
    args = parser.parse_args()

    address = normalize_address(args.address)
    if not address:
        emit(
            "failed",
            code="invalid-address",
            message="Invalid Bluetooth address",
        )
        return 2

    emit("started", address=address)
    return asyncio.run(run(address))


if __name__ == "__main__":
    raise SystemExit(main())

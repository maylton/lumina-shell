#!/usr/bin/env python3
"""Interactive bluetoothctl pairing bridge for Lumina Shell.

The process speaks newline-delimited JSON on stdout and accepts newline-delimited
JSON commands on stdin. bluetoothctl is attached to a PTY so prompts that do not
end with a newline remain observable.
"""

from __future__ import annotations

import argparse
import json
import os
import pty
import re
import selectors
import signal
import sys
import termios
import time
from typing import Any

CSI_RE = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")
OSC_RE = re.compile(
    r"\x1b\](?:[^\x07\x1b]|\x1b(?!\\))*(?:\x07|\x1b\\)"
)
AGENT_READY_RE = re.compile(
    r"Agent registered|Agent is already registered",
    re.IGNORECASE,
)
DEFAULT_AGENT_READY_RE = re.compile(
    r"Default agent request successful",
    re.IGNORECASE,
)
PAIRABLE_READY_RE = re.compile(
    r"Changing pairable on succeeded|Pairable\s*:\s*yes",
    re.IGNORECASE,
)
AGENT_FAILURE_RE = re.compile(
    r"Failed to register agent|No agent is registered|"
    r"Failed to request default agent",
    re.IGNORECASE,
)
CONFIRM_RE = re.compile(
    r"(?:Confirm|Verify)\s+"
    r"(?:passkey|pairing(?:\s+code)?)\s*:?\s*([0-9]{1,6})"
    r"(?:\s+\((?:yes/no|yes\\/no)\))?\s*:?",
    re.IGNORECASE,
)
PIN_RE = re.compile(r"Enter PIN code\s*:", re.IGNORECASE)
PASSKEY_RE = re.compile(
    r"Enter passkey(?:\s+\(number in 0-999999\))?\s*:",
    re.IGNORECASE,
)
AUTHORIZE_RE = re.compile(
    r"Authorize service\s+([^\s]+)"
    r"(?:\s+\((?:yes/no|yes\\/no)\))?\s*:",
    re.IGNORECASE,
)
DISPLAY_PIN_RE = re.compile(
    r"(?:\[agent\]\s+)?PIN code:\s*([0-9A-Za-z]{1,16})",
    re.IGNORECASE,
)
DISPLAY_PASSKEY_RE = re.compile(
    r"(?:\[agent\]\s+)?Passkey:\s*([0-9]{1,6})"
    r"(?:\s+entered\s+([0-9]+))?",
    re.IGNORECASE,
)
SUCCESS_RE = re.compile(r"Pairing successful", re.IGNORECASE)
FAILURE_RE = re.compile(
    r"(?:Failed to pair|Pairing failed|AuthenticationFailed|"
    r"AuthenticationCanceled|AuthenticationRejected|"
    r"AuthenticationTimeout|org\.bluez\.Error\.[A-Za-z]+)"
    r"\s*:?\s*([^\r\n]*)",
    re.IGNORECASE,
)
ADDRESS_RE = re.compile(r"^[0-9A-F]{2}(?::[0-9A-F]{2}){5}$")


def emit(event_type: str, **payload: Any) -> None:
    message = {"type": event_type, **payload}
    sys.stdout.write(json.dumps(message, ensure_ascii=False) + "\n")
    sys.stdout.flush()


def collapse_backspaces(text: str) -> str:
    result: list[str] = []
    for character in text:
        if character == "\b":
            if result:
                result.pop()
        else:
            result.append(character)
    return "".join(result)


def cleaned(text: str) -> str:
    value = OSC_RE.sub("", text)
    value = CSI_RE.sub("", value)
    value = collapse_backspaces(value)
    value = value.replace("\r", "")
    return re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1a\x1c-\x1f]", "", value)


def useful_tail(text: str) -> str:
    lines = [line.strip() for line in cleaned(text).splitlines()]
    lines = [line for line in lines if line and not line.endswith("#")]
    return lines[-1][:240] if lines else ""


def write_fd(fd: int, text: str) -> None:
    os.write(fd, text.encode("utf-8"))


def terminate_child(pid: int, fd: int) -> None:
    try:
        write_fd(fd, "quit\n")
    except OSError:
        pass

    deadline = time.monotonic() + 1.0
    while time.monotonic() < deadline:
        try:
            waited, _ = os.waitpid(pid, os.WNOHANG)
        except ChildProcessError:
            return
        if waited == pid:
            return
        time.sleep(0.05)

    try:
        os.kill(pid, signal.SIGTERM)
    except ProcessLookupError:
        return

    try:
        os.waitpid(pid, 0)
    except ChildProcessError:
        pass


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("address")
    args = parser.parse_args()

    address = args.address.strip().upper()
    if not ADDRESS_RE.fullmatch(address):
        emit("failed", code="invalid-address", message="Invalid Bluetooth address")
        return 2

    try:
        pid, master_fd = pty.fork()
    except OSError as error:
        emit("failed", code="agent-start-failed", message=str(error))
        return 2

    if pid == 0:
        try:
            os.environ["LC_ALL"] = "C"
            os.environ["LANG"] = "C"
            os.environ["TERM"] = "dumb"
            os.environ["NO_COLOR"] = "1"
            os.execvp("bluetoothctl", ["bluetoothctl"])
        except OSError as error:
            sys.stderr.write(str(error))
            os._exit(127)

    try:
        attributes = termios.tcgetattr(master_fd)
        attributes[3] &= ~termios.ECHO
        termios.tcsetattr(master_fd, termios.TCSANOW, attributes)
    except (OSError, termios.error):
        pass

    os.set_blocking(master_fd, False)
    selector = selectors.DefaultSelector()
    selector.register(master_fd, selectors.EVENT_READ, "bluetoothctl")
    selector.register(sys.stdin, selectors.EVENT_READ, "ui")

    agent_requested = False
    agent_ready = False
    default_agent_requested = False
    pairable_requested = False
    pairable_ready = False
    pair_requested = False
    current_prompt = ""
    buffer = ""
    emitted_displays: set[str] = set()
    started_at = time.monotonic()
    agent_retry_at = started_at + 2.0
    setup_deadline = started_at + 10.0
    deadline = started_at + 100.0
    finished = False

    emit("started", address=address)

    def request_agent() -> None:
        nonlocal agent_requested
        write_fd(master_fd, "agent KeyboardDisplay\n")
        agent_requested = True

    def request_default_agent() -> None:
        nonlocal default_agent_requested
        if default_agent_requested:
            return
        write_fd(master_fd, "default-agent\n")
        default_agent_requested = True

    def request_pairable() -> None:
        nonlocal pairable_requested
        if pairable_requested:
            return
        write_fd(master_fd, "pairable on\n")
        pairable_requested = True

    def start_pairing() -> None:
        nonlocal pair_requested, buffer
        if pair_requested or not agent_ready:
            return
        pair_requested = True
        buffer = ""
        emit("ready", address=address)
        write_fd(master_fd, f"pair {address}\n")

    request_agent()

    try:
        while time.monotonic() < deadline:
            now = time.monotonic()

            if not pair_requested and now >= setup_deadline:
                emit(
                    "failed",
                    code="agent-not-ready",
                    message=useful_tail(buffer)
                    or "Bluetooth authentication agent did not become ready",
                )
                return 7

            if not agent_ready and now >= agent_retry_at:
                request_agent()
                agent_retry_at = now + 2.0

            for key, _ in selector.select(timeout=0.10):
                if key.data == "ui":
                    line = sys.stdin.readline()
                    if line == "":
                        emit("cancelled", reason="ui-closed")
                        return 3

                    try:
                        command = json.loads(line)
                    except json.JSONDecodeError:
                        continue

                    action = str(command.get("action", ""))
                    if action == "cancel":
                        if current_prompt in {"confirmation", "authorize"}:
                            write_fd(master_fd, "no\n")
                        else:
                            try:
                                os.kill(pid, signal.SIGINT)
                            except ProcessLookupError:
                                pass
                        emit("cancelled", reason=str(command.get("reason", "user")))
                        return 3

                    if action == "accept" and current_prompt in {
                        "confirmation",
                        "authorize",
                    }:
                        write_fd(master_fd, "yes\n")
                        current_prompt = ""
                        buffer = ""
                        continue

                    if action == "reject" and current_prompt in {
                        "confirmation",
                        "authorize",
                    }:
                        write_fd(master_fd, "no\n")
                        current_prompt = ""
                        buffer = ""
                        continue

                    if action == "value" and current_prompt in {
                        "pin",
                        "passkey",
                    }:
                        value = str(command.get("value", "")).strip()
                        if current_prompt == "pin":
                            valid = 1 <= len(value) <= 16 and "\n" not in value
                        else:
                            valid = (
                                value.isdigit()
                                and 1 <= len(value) <= 6
                                and int(value) <= 999999
                            )
                        if valid:
                            write_fd(master_fd, value + "\n")
                            current_prompt = ""
                            buffer = ""
                        else:
                            emit("invalid-response", kind=current_prompt)
                        continue

                try:
                    chunk = os.read(master_fd, 4096)
                except BlockingIOError:
                    continue
                except OSError:
                    chunk = b""

                if not chunk:
                    if not finished:
                        emit(
                            "failed",
                            code="agent-exited",
                            message="bluetoothctl exited before pairing completed",
                        )
                    return 4

                buffer = (
                    buffer + cleaned(chunk.decode("utf-8", "replace"))
                )[-16384:]

                if not agent_ready and AGENT_READY_RE.search(buffer):
                    agent_ready = True
                    emit("agent-ready", address=address)
                    request_default_agent()
                    request_pairable()

                if agent_ready and DEFAULT_AGENT_READY_RE.search(buffer):
                    emit("default-agent-ready", address=address)

                if agent_ready and PAIRABLE_READY_RE.search(buffer):
                    pairable_ready = True

                if not pair_requested and agent_ready and pairable_ready:
                    start_pairing()
                    continue

                if not pair_requested and AGENT_FAILURE_RE.search(buffer):
                    emit(
                        "failed",
                        code="agent-registration-failed",
                        message=useful_tail(buffer)
                        or "Bluetooth authentication agent registration failed",
                    )
                    return 7

                if not current_prompt:
                    confirmation = CONFIRM_RE.search(buffer)
                    if confirmation:
                        current_prompt = "confirmation"
                        emit(
                            "prompt",
                            kind="confirmation",
                            code=confirmation.group(1).zfill(6),
                        )
                        continue

                    if PIN_RE.search(buffer):
                        current_prompt = "pin"
                        emit("prompt", kind="pin")
                        continue

                    if PASSKEY_RE.search(buffer):
                        current_prompt = "passkey"
                        emit("prompt", kind="passkey")
                        continue

                    authorization = AUTHORIZE_RE.search(buffer)
                    if authorization:
                        current_prompt = "authorize"
                        emit(
                            "prompt",
                            kind="authorize",
                            service=authorization.group(1),
                        )
                        continue

                display_pin = DISPLAY_PIN_RE.search(buffer)
                if display_pin:
                    signature = f"pin:{display_pin.group(1)}"
                    if signature not in emitted_displays:
                        emitted_displays.add(signature)
                        emit(
                            "display",
                            kind="display-pin",
                            code=display_pin.group(1),
                        )

                display_passkey = DISPLAY_PASSKEY_RE.search(buffer)
                if display_passkey:
                    entered = int(display_passkey.group(2) or 0)
                    code = display_passkey.group(1).zfill(6)
                    signature = f"passkey:{code}:{entered}"
                    if signature not in emitted_displays:
                        emitted_displays.add(signature)
                        emit(
                            "display",
                            kind="display-passkey",
                            code=code,
                            entered=entered,
                        )

                if SUCCESS_RE.search(buffer):
                    finished = True
                    emit("completed", address=address)
                    return 0

                failure = FAILURE_RE.search(buffer)
                if failure:
                    finished = True
                    message = (failure.group(1) or "").strip()
                    emit(
                        "failed",
                        code="pair-failed",
                        message=message or useful_tail(buffer) or failure.group(0),
                    )
                    return 5

        emit(
            "failed",
            code="timeout",
            message=useful_tail(buffer) or "Bluetooth pairing timed out",
        )
        return 6
    finally:
        selector.close()
        terminate_child(pid, master_fd)
        try:
            os.close(master_fd)
        except OSError:
            pass


if __name__ == "__main__":
    raise SystemExit(main())

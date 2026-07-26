#!/usr/bin/env python3

import importlib.util
from pathlib import Path
import unittest


MODULE_PATH = (
    Path(__file__).resolve().parents[1]
    / "services"
    / "connectivity"
    / "BluetoothPairingAgent.py"
)
SPEC = importlib.util.spec_from_file_location(
    "lumina_bluetooth_pairing_agent",
    MODULE_PATH,
)
assert SPEC is not None and SPEC.loader is not None
AGENT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AGENT)


class FakeVariant:
    def __init__(self, value):
        self.value = value


class BluetoothPairingAgentTests(unittest.TestCase):
    def test_address_is_normalized(self):
        self.assertEqual(
            AGENT.normalize_address("3c:0a:7a:a0:b0:ad"),
            "3C:0A:7A:A0:B0:AD",
        )
        self.assertEqual(AGENT.normalize_address("invalid"), "")

    def test_numeric_confirmation_keeps_leading_zeroes(self):
        self.assertEqual(AGENT.pairing_code(4200), "004200")
        self.assertEqual(AGENT.pairing_code(123456), "123456")

    def test_device_and_adapter_are_resolved_from_object_manager(self):
        managed = {
            "/org/bluez/hci0": {
                "org.bluez.Adapter1": {
                    "Address": FakeVariant("AA:BB:CC:DD:EE:FF")
                }
            },
            "/org/bluez/hci0/dev_3C_0A_7A_A0_B0_AD": {
                "org.bluez.Device1": {
                    "Address": FakeVariant("3C:0A:7A:A0:B0:AD"),
                    "Adapter": FakeVariant("/org/bluez/hci0"),
                }
            },
        }

        device, adapter = AGENT.find_device_paths(
            managed,
            "3c:0a:7a:a0:b0:ad",
        )
        self.assertEqual(
            device,
            "/org/bluez/hci0/dev_3C_0A_7A_A0_B0_AD",
        )
        self.assertEqual(adapter, "/org/bluez/hci0")

    def test_unknown_device_returns_empty_paths(self):
        device, adapter = AGENT.find_device_paths({}, "3C:0A:7A:A0:B0:AD")
        self.assertEqual(device, "")
        self.assertEqual(adapter, "")


if __name__ == "__main__":
    unittest.main()

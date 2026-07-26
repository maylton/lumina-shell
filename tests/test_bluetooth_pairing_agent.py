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


class BluetoothPairingAgentPatterns(unittest.TestCase):
    def test_confirmation_code_is_detected(self):
        match = AGENT.CONFIRM_RE.search(
            "[agent] Confirm passkey 123456 (yes/no):"
        )
        self.assertIsNotNone(match)
        self.assertEqual(match.group(1), "123456")

    def test_pin_and_passkey_prompts_are_distinct(self):
        self.assertIsNotNone(
            AGENT.PIN_RE.search("[agent] Enter PIN code:")
        )
        self.assertIsNotNone(
            AGENT.PASSKEY_RE.search(
                "[agent] Enter passkey (number in 0-999999):"
            )
        )

    def test_authorization_service_is_detected(self):
        match = AGENT.AUTHORIZE_RE.search(
            "[agent] Authorize service 0000110b-0000-1000-8000-00805f9b34fb (yes/no):"
        )
        self.assertIsNotNone(match)
        self.assertEqual(
            match.group(1),
            "0000110b-0000-1000-8000-00805f9b34fb",
        )

    def test_displayed_codes_are_detected(self):
        pin = AGENT.DISPLAY_PIN_RE.search("[agent] PIN code: 004200")
        passkey = AGENT.DISPLAY_PASSKEY_RE.search(
            "[agent] Passkey: 654321 entered 3"
        )
        self.assertIsNotNone(pin)
        self.assertIsNotNone(passkey)
        self.assertEqual(pin.group(1), "004200")
        self.assertEqual(passkey.group(1), "654321")
        self.assertEqual(passkey.group(2), "3")

    def test_ansi_output_is_cleaned(self):
        self.assertEqual(
            AGENT.cleaned("\x1b[0;94mPairing successful\x1b[0m\r\n"),
            "Pairing successful\n",
        )


if __name__ == "__main__":
    unittest.main()

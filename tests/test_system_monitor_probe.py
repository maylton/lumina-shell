import importlib.util
import pathlib
import unittest


MODULE_PATH = (
    pathlib.Path(__file__).parents[1]
    / "services"
    / "system"
    / "SystemMonitorProbe.py"
)
SPEC = importlib.util.spec_from_file_location(
    "system_monitor_probe",
    MODULE_PATH,
)
PROBE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(PROBE)


class SystemMonitorProbeTest(unittest.TestCase):
    def test_parses_cpu_totals_and_idle_time(self):
        parsed = PROBE.parse_cpu_stat(
            "cpu  10 20 30 40 5 6 7 8 9 10\ncpu0 1 2 3 4"
        )

        self.assertEqual(parsed["total"], 145)
        self.assertEqual(parsed["idle"], 45)

    def test_parses_memory_using_available_value(self):
        parsed = PROBE.parse_meminfo(
            "MemTotal: 16384 kB\n"
            "MemFree: 1024 kB\n"
            "MemAvailable: 12288 kB\n"
        )

        self.assertEqual(parsed["totalBytes"], 16384 * 1024)
        self.assertEqual(parsed["usedBytes"], 4096 * 1024)

    def test_finds_default_network_interface(self):
        route = (
            "Iface Destination Gateway Flags RefCnt Use Metric Mask\n"
            "enp14s0 00000000 0100A8C0 0003 0 0 100 00000000\n"
        )

        self.assertEqual(
            PROBE.parse_default_interface(route),
            "enp14s0",
        )

    def test_compacts_pci_device_name(self):
        value = (
            "03:00.0 VGA compatible controller: "
            "Advanced Micro Devices, Inc. [AMD/ATI] Navi 48 (rev c5)"
        )

        self.assertEqual(
            PROBE.compact_pci_name(value),
            "Advanced Micro Devices, Inc. [AMD/ATI] Navi 48",
        )


if __name__ == "__main__":
    unittest.main()

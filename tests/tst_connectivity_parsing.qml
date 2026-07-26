import QtQuick
import QtTest
import "../services/connectivity/ConnectivityParsing.js" as Parsing

TestCase {
    name: "ConnectivityParsing"

    function test_parsesAndDeduplicatesWifiNetworks() {
        const networks = Parsing.parseWifiNetworks(
            ":Cafe\\:Guest:42:WPA2:▂▄__\n"
            + "*:Home:78:WPA2:▂▄▆_\n"
            + ":Home:55:WPA2:▂▄__\n"
        )

        compare(networks.length, 2)
        compare(networks[0].ssid, "Home")
        compare(networks[0].active, true)
        compare(networks[1].ssid, "Cafe:Guest")
        compare(networks[1].signal, 42)
    }

    function test_parsesProfilesAndAutoconnect() {
        const profiles = Parsing.parseConnections(
            "Home:uuid-wifi:802-11-wireless:wlan0:yes\n"
            + "Cable:uuid-wired:802-3-ethernet:--:no\n"
        )

        compare(profiles.length, 2)
        compare(profiles[0].active, true)
        compare(profiles[0].autoconnect, true)
        compare(profiles[1].active, false)
        compare(profiles[1].autoconnect, false)
    }

    function test_parsesVerifiedBluetoothInfo() {
        const info = Parsing.parseBluetoothInfo(
            "\x1b[0;94mDevice AA:BB:CC:DD:EE:FF Headphones\x1b[0m\n"
            + "    Name: Headphones\n"
            + "    Paired: yes\n"
            + "    Bonded: yes\n"
            + "    Trusted: yes\n"
            + "    Connected: yes\n"
            + "    Blocked: no\n"
        )

        compare(info.valid, true)
        compare(info.address, "AA:BB:CC:DD:EE:FF")
        compare(info.name, "Headphones")
        compare(info.paired, true)
        compare(info.bonded, true)
        compare(info.trusted, true)
        compare(info.connected, true)
        compare(info.blocked, false)
    }

    function test_summarizesBluetoothOutputWithoutEventConsole() {
        const summary = Parsing.bluetoothCommandSummary(
            "[CHG] Device AA:BB:CC:DD:EE:FF Connected: yes\n"
            + "Connection successful\n"
        )

        compare(summary, "Connection successful")
    }

    function test_mergesBluetoothState() {
        const devices = Parsing.mergeBluetoothDevices(
            "Device AA:BB:CC:DD:EE:FF Headphones\n"
            + "Device 11:22:33:44:55:66 Keyboard\n",
            "Device AA:BB:CC:DD:EE:FF Headphones\n",
            "Device AA:BB:CC:DD:EE:FF Headphones\n"
        )

        compare(devices.length, 2)
        compare(devices[0].name, "Headphones")
        compare(devices[0].paired, true)
        compare(devices[0].connected, true)
        compare(devices[1].paired, false)
    }
}

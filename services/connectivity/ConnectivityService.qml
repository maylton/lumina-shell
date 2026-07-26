pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: root

    readonly property var networkDevices: Networking.devices.values
    readonly property var wifiDevice: findWifiDevice(networkDevices)
    readonly property var wifiNetworks: wifiDevice
        ? wifiDevice.networks.values
        : []
    readonly property var activeWifi: findConnectedWifi(wifiNetworks)
    readonly property bool wifiAvailable: wifiDevice !== null
        && Networking.wifiHardwareEnabled
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiConnected: activeWifi !== null
    readonly property string wifiName: wifiConnected
        ? String(activeWifi.name || "Wi-Fi")
        : wifiEnabled
            ? "Not connected"
            : "Disabled"
    readonly property int wifiStrength: wifiConnected
        ? Math.round(Number(activeWifi.signalStrength || 0) * 100)
        : 0
    readonly property bool generallyConnected:
        Networking.connectivity === NetworkConnectivity.Full
        || Networking.connectivity === NetworkConnectivity.Limited
        || Networking.connectivity === NetworkConnectivity.Portal
    readonly property bool wiredConnected: hasWiredConnection(networkDevices)
        || (!wifiConnected && generallyConnected)
    readonly property string networkSummary: wifiConnected
        ? wifiName
        : wiredConnected
            ? "Wired"
            : "Offline"

    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property var bluetoothDevices: Bluetooth.devices.values
    readonly property var connectedBluetoothDevices:
        findConnectedBluetooth(bluetoothDevices)
    readonly property bool bluetoothAvailable: bluetoothAdapter !== null
    readonly property bool bluetoothEnabled: bluetoothAvailable
        && bluetoothAdapter.enabled
    readonly property bool bluetoothDiscovering: bluetoothAvailable
        && bluetoothAdapter.discovering
    readonly property int bluetoothConnectedCount:
        connectedBluetoothDevices.length
    readonly property string bluetoothSummary: !bluetoothAvailable
        ? "Unavailable"
        : !bluetoothEnabled
            ? "Disabled"
            : bluetoothConnectedCount > 0
                ? connectedBluetoothDevices[0].name
                : "On"

    function findWifiDevice(devices) {
        const values = devices || []

        for (var i = 0; i < values.length; ++i) {
            if (values[i] && values[i].type === DeviceType.Wifi)
                return values[i]
        }

        return null
    }

    function findConnectedWifi(networks) {
        const values = networks || []

        for (var i = 0; i < values.length; ++i) {
            if (values[i] && values[i].connected)
                return values[i]
        }

        return null
    }

    function hasWiredConnection(devices) {
        const values = devices || []

        for (var i = 0; i < values.length; ++i) {
            const device = values[i]

            if (device
                && device.type !== DeviceType.Wifi
                && String(device.name || "") !== "lo"
                && device.connected) {
                return true
            }
        }

        return false
    }

    function findConnectedBluetooth(devices) {
        const values = devices || []
        const connected = []

        for (var i = 0; i < values.length; ++i) {
            if (values[i] && values[i].connected)
                connected.push(values[i])
        }

        return connected
    }

    function setWifiEnabled(enabled) {
        if (!wifiAvailable)
            return

        Networking.wifiEnabled = Boolean(enabled)
    }

    function toggleWifi() {
        setWifiEnabled(!wifiEnabled)
    }

    function setBluetoothEnabled(enabled) {
        if (!bluetoothAvailable)
            return

        bluetoothAdapter.enabled = Boolean(enabled)
    }

    function toggleBluetooth() {
        setBluetoothEnabled(!bluetoothEnabled)
    }

    function setBluetoothDiscovery(enabled) {
        if (!bluetoothAvailable || !bluetoothEnabled)
            return

        bluetoothAdapter.discovering = Boolean(enabled)
    }

    function statusObject() {
        const connectedDevices = []

        for (var i = 0; i < connectedBluetoothDevices.length; ++i) {
            const device = connectedBluetoothDevices[i]

            connectedDevices.push({
                name: String(device.name || device.deviceName || "Device"),
                address: String(device.address || ""),
                batteryAvailable: Boolean(device.batteryAvailable),
                battery: device.batteryAvailable
                    ? Math.round(Number(device.battery || 0) * 100)
                    : 0
            })
        }

        return {
            network: {
                summary: networkSummary,
                wired: wiredConnected,
                wifiAvailable: wifiAvailable,
                wifiEnabled: wifiEnabled,
                wifiConnected: wifiConnected,
                wifiName: wifiName,
                wifiStrength: wifiStrength
            },
            bluetooth: {
                available: bluetoothAvailable,
                enabled: bluetoothEnabled,
                discovering: bluetoothDiscovering,
                summary: bluetoothSummary,
                connected: connectedDevices
            }
        }
    }

    IpcHandler {
        target: "connectivity"

        function wifi(enabled: bool): void {
            root.setWifiEnabled(enabled)
        }

        function wifiToggle(): void {
            root.toggleWifi()
        }

        function bluetooth(enabled: bool): void {
            root.setBluetoothEnabled(enabled)
        }

        function bluetoothToggle(): void {
            root.toggleBluetooth()
        }

        function discovery(enabled: bool): void {
            root.setBluetoothDiscovery(enabled)
        }

        function status(): string {
            return JSON.stringify(root.statusObject())
        }
    }
}

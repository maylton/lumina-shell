pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control.settings
import qs.services.connectivity
import qs.services.i18n

Column {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var connectedDevices:
        BluetoothManagerService.devices.filter(function(device) {
            return Boolean(device.connected)
        })
    readonly property var pairedDevices:
        BluetoothManagerService.devices.filter(function(device) {
            return Boolean(device.paired) && !device.connected
        })
    readonly property var foundDevices:
        BluetoothManagerService.devices.filter(function(device) {
            return !device.paired && !device.connected
        })

    width: parent ? parent.width : 0
    spacing: luminaDesign.spacing.controlSectionGap

    Component.onCompleted: {
        BluetoothManagerService.setActive(true)
        BluetoothManagerService.refresh()
    }

    function activateDevice(device) {
        if (device.connected) {
            BluetoothManagerService.disconnectDevice(device.address)
        } else if (device.paired) {
            BluetoothManagerService.connectDevice(device.address)
        } else {
            BluetoothManagerService.pair(device.address)
        }
    }

    function idleStatusDescription() {
        if (!ConnectivityService.bluetoothAvailable) {
            return I18n.tr(
                "dashboard.status.unavailable",
                "Unavailable"
            )
        }
        if (!ConnectivityService.bluetoothEnabled) {
            return I18n.tr(
                "dashboard.status.disabled",
                "Disabled"
            )
        }
        if (root.connectedDevices.length > 0)
            return root.connectedDevices[0].name

        return I18n.tr(
            "settings.connectivity.bluetooth.status.on",
            "On"
        )
    }

    function bluetoothStatusDescription() {
        const code = BluetoothManagerService.statusCode
        const name = BluetoothManagerService.targetName
            || BluetoothManagerService.targetAddress
        const replacements = [name]

        switch (code) {
        case "scanning":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.scanning",
                "Searching for Bluetooth devices"
            )
        case "scan-complete":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.scanComplete",
                "Bluetooth device search completed"
            )
        case "scan-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.scanFailed",
                "Bluetooth device search failed"
            )
        case "pairing":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.pairing",
                "Pairing with %1",
                replacements
            )
        case "connecting":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.connecting",
                "Connecting to %1",
                replacements
            )
        case "disconnecting":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.disconnecting",
                "Disconnecting %1",
                replacements
            )
        case "forgetting":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.forgetting",
                "Forgetting %1",
                replacements
            )
        case "connected":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.connected",
                "%1 is connected",
                replacements
            )
        case "disconnected":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.disconnected",
                "%1 is disconnected",
                replacements
            )
        case "forgotten":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.forgotten",
                "%1 was forgotten",
                replacements
            )
        case "paired-not-connected":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.pairedNotConnected",
                "%1 was paired, but the connection could not be confirmed",
                replacements
            )
        case "authentication-required":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.authenticationRequired",
                "%1 requires pairing confirmation",
                replacements
            )
        case "pair-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.pairFailed",
                "Could not pair with %1",
                replacements
            )
        case "connect-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.connectFailed",
                "Could not confirm a connection to %1",
                replacements
            )
        case "disconnect-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.disconnectFailed",
                "Could not confirm that %1 disconnected",
                replacements
            )
        case "forget-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.forgetFailed",
                "Could not forget %1",
                replacements
            )
        case "invalid-address":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.invalidAddress",
                "The Bluetooth device address is invalid"
            )
        default:
            return root.idleStatusDescription()
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.connectivity.bluetooth.section",
            "Bluetooth"
        )
        description: root.bluetoothStatusDescription()

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.connectivity.bluetooth.enabled",
                "Bluetooth"
            )
            description: root.idleStatusDescription()
            iconName: ConnectivityService.bluetoothEnabled
                ? "bluetooth-active-symbolic"
                : "bluetooth-disabled-symbolic"
            symbol: "ᛒ"
            available: ConnectivityService.bluetoothAvailable
            checked: ConnectivityService.bluetoothEnabled
            onToggled: value => BluetoothManagerService.setEnabled(value)
        }

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.connectivity.bluetooth.scan",
                "Find Bluetooth devices"
            )
            description: I18n.tr(
                "settings.connectivity.bluetooth.scanDescription",
                "Discovery runs for approximately twelve seconds"
            )
            iconName: "view-refresh-symbolic"
            symbol: "↻"
            actionLabel: BluetoothManagerService.busyAction === "scan"
                ? I18n.tr(
                    "settings.connectivity.scanning",
                    "Scanning"
                )
                : I18n.tr(
                    "settings.connectivity.scan",
                    "Scan"
                )
            available: ConnectivityService.bluetoothEnabled
                && !BluetoothManagerService.busy
            onActivated: BluetoothManagerService.scan()
        }
    }

    SettingsSection {
        visible: root.connectedDevices.length > 0
        title: I18n.tr(
            "settings.connectivity.connected",
            "Connected"
        )

        BoundedList {
            maximumHeight: 220

            Repeater {
                model: root.connectedDevices

                delegate: SettingsActionRow {
                    required property var modelData

                    width: parent.width
                    title: modelData.name
                    description: modelData.address
                    iconName: "bluetooth-active-symbolic"
                    symbol: "ᛒ"
                    actionLabel: BluetoothManagerService.busyAction
                        === "disconnect"
                        && BluetoothManagerService.targetAddress
                            === modelData.address
                        ? I18n.tr(
                            "settings.connectivity.bluetooth.action.disconnecting",
                            "Disconnecting"
                        )
                        : I18n.tr(
                            "settings.connectivity.disconnect",
                            "Disconnect"
                        )
                    available: !BluetoothManagerService.busy
                    onActivated: root.activateDevice(modelData)
                }
            }
        }
    }

    SettingsSection {
        visible: root.pairedDevices.length > 0
        title: I18n.tr(
            "settings.connectivity.bluetooth.paired",
            "Paired"
        )

        BoundedList {
            maximumHeight: 300

            Repeater {
                model: root.pairedDevices

                delegate: Column {
                    required property var modelData
                    property bool settingsGroup: true

                    width: parent.width
                    spacing: 1

                    SettingsActionRow {
                        width: parent.width
                        title: modelData.name
                        description: modelData.address
                        iconName: "bluetooth-symbolic"
                        symbol: "ᛒ"
                        actionLabel: BluetoothManagerService.busyAction
                            === "connect"
                            && BluetoothManagerService.targetAddress
                                === modelData.address
                            ? I18n.tr(
                                "settings.connectivity.bluetooth.action.connecting",
                                "Connecting"
                            )
                            : I18n.tr(
                                "settings.connectivity.connect",
                                "Connect"
                            )
                        available: !BluetoothManagerService.busy
                        onActivated: root.activateDevice(modelData)
                    }

                    SettingsActionRow {
                        width: parent.width
                        title: I18n.tr(
                            "settings.connectivity.bluetooth.forgetNamed",
                            "Forget %1",
                            [modelData.name]
                        )
                        description: modelData.address
                        iconName: "edit-delete-symbolic"
                        symbol: "×"
                        actionLabel: I18n.tr(
                            "settings.connectivity.forget",
                            "Forget"
                        )
                        destructive: true
                        available: !BluetoothManagerService.busy
                        onActivated: BluetoothManagerService.forgetDevice(
                            modelData.address
                        )
                    }
                }
            }
        }
    }

    SettingsSection {
        visible: root.foundDevices.length > 0
        title: I18n.tr(
            "settings.connectivity.bluetooth.scan",
            "Find Bluetooth devices"
        )
        description: I18n.tr(
            "settings.connectivity.bluetooth.scanDescription",
            "Discovery runs for approximately twelve seconds"
        )

        BoundedList {
            maximumHeight: 360

            Repeater {
                model: root.foundDevices

                delegate: SettingsActionRow {
                    required property var modelData

                    width: parent.width
                    title: modelData.name
                    description: modelData.address
                    iconName: "bluetooth-symbolic"
                    symbol: "ᛒ"
                    actionLabel: BluetoothManagerService.busyAction === "pair"
                        && BluetoothManagerService.targetAddress
                            === modelData.address
                        ? I18n.tr(
                            "settings.connectivity.bluetooth.action.pairing",
                            "Pairing"
                        )
                        : I18n.tr(
                            "settings.connectivity.bluetooth.pair",
                            "Pair"
                        )
                    available: !BluetoothManagerService.busy
                    onActivated: root.activateDevice(modelData)
                }
            }
        }
    }
}

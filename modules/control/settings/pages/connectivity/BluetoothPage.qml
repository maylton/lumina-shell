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
        ConnectivityManagerService.bluetoothDevices.filter(function(device) {
            return Boolean(device.connected)
        })
    readonly property var pairedDevices:
        ConnectivityManagerService.bluetoothDevices.filter(function(device) {
            return Boolean(device.paired) && !device.connected
        })
    readonly property var foundDevices:
        ConnectivityManagerService.bluetoothDevices.filter(function(device) {
            return !device.paired && !device.connected
        })

    width: parent ? parent.width : 0
    spacing: luminaDesign.spacing.controlSectionGap

    function activateDevice(device) {
        if (device.connected) {
            ConnectivityManagerService.disconnectBluetooth(device.address)
        } else if (device.paired) {
            ConnectivityManagerService.connectBluetooth(device.address)
        } else {
            ConnectivityManagerService.pairBluetooth(device.address)
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.connectivity.bluetooth.section",
            "Bluetooth"
        )
        description: ConnectivityManagerService.lastError
            || ConnectivityManagerService.statusMessage

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.connectivity.bluetooth.enabled",
                "Bluetooth"
            )
            description: ConnectivityService.bluetoothSummary
            iconName: ConnectivityService.bluetoothEnabled
                ? "bluetooth-active-symbolic"
                : "bluetooth-disabled-symbolic"
            symbol: "ᛒ"
            available: ConnectivityService.bluetoothAvailable
            checked: ConnectivityService.bluetoothEnabled
            onToggled: value =>
                ConnectivityManagerService.setBluetoothEnabled(value)
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
            actionLabel: ConnectivityManagerService.busyAction
                === "bluetooth-scan"
                ? I18n.tr(
                    "settings.connectivity.scanning",
                    "Scanning"
                )
                : I18n.tr(
                    "settings.connectivity.scan",
                    "Scan"
                )
            available: ConnectivityService.bluetoothEnabled
                && !ConnectivityManagerService.busy
            onActivated: ConnectivityManagerService.scanBluetooth()
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

                delegate: Column {
                    required property var modelData
                    property bool settingsGroup: true

                    width: parent.width
                    spacing: 1

                    SettingsActionRow {
                        width: parent.width
                        title: modelData.name
                        description: modelData.address
                        iconName: "bluetooth-active-symbolic"
                        symbol: "ᛒ"
                        actionLabel: I18n.tr(
                            "settings.connectivity.disconnect",
                            "Disconnect"
                        )
                        available: !ConnectivityManagerService.busy
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
                        available: false
                        availabilityText: I18n.tr(
                            "settings.connectivity.disconnectFirst",
                            "Disconnect this item first"
                        )
                    }
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
                        actionLabel: I18n.tr(
                            "settings.connectivity.connect",
                            "Connect"
                        )
                        available: !ConnectivityManagerService.busy
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
                        available: !ConnectivityManagerService.busy
                        onActivated:
                            ConnectivityManagerService.removeBluetooth(
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
                    actionLabel: I18n.tr(
                        "settings.connectivity.bluetooth.pair",
                        "Pair"
                    )
                    available: !ConnectivityManagerService.busy
                    onActivated: root.activateDevice(modelData)
                }
            }
        }
    }
}

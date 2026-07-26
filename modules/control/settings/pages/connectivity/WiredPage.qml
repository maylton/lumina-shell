pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control.settings
import qs.services.connectivity
import qs.services.i18n

Column {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var wiredProfiles:
        ConnectivityManagerService.wiredProfiles()
    readonly property var wiredDevices:
        ConnectivityManagerService.wiredDevices()

    width: parent ? parent.width : 0
    spacing: luminaDesign.spacing.controlSectionGap

    function localizedState(state) {
        const normalized = String(state || "unknown")
            .toLowerCase()
            .replace(/\s+/g, "-")
        const supported = [
            "connected",
            "connecting",
            "disconnected",
            "disconnecting",
            "unavailable",
            "unmanaged"
        ]
        const key = supported.indexOf(normalized) >= 0
            ? normalized
            : "unknown"

        return I18n.tr(
            "settings.connectivity.wired.state." + key,
            String(state || "Unknown")
        )
    }

    SettingsSection {
        title: I18n.tr(
            "settings.connectivity.wired.section",
            "Wired network"
        )
        description: root.wiredDevices.length === 0
            ? I18n.tr(
                "settings.connectivity.wired.none",
                "No managed Ethernet interface was found"
            )
            : root.wiredDevices.map(function(device) {
                return device.device + " · "
                    + root.localizedState(device.state)
            }).join(", ")

        Repeater {
            model: root.wiredProfiles

            delegate: Column {
                required property var modelData
                property bool settingsGroup: true

                width: parent.width
                spacing: 1

                SettingsActionRow {
                    width: parent.width
                    title: modelData.name
                    description: modelData.active
                        ? I18n.tr(
                            "settings.connectivity.connected",
                            "Connected"
                        )
                        : I18n.tr(
                            "settings.connectivity.wired.profile",
                            "Ethernet connection profile"
                        )
                    iconName: "network-wired-symbolic"
                    symbol: "↔"
                    actionLabel: modelData.active
                        ? I18n.tr(
                            "settings.connectivity.disconnect",
                            "Disconnect"
                        )
                        : I18n.tr(
                            "settings.connectivity.connect",
                            "Connect"
                        )
                    available: !ConnectivityManagerService.busy
                    onActivated: {
                        if (modelData.active) {
                            ConnectivityManagerService.deactivateConnection(
                                modelData.uuid
                            )
                        } else {
                            ConnectivityManagerService.activateConnection(
                                modelData.uuid
                            )
                        }
                    }
                }

                SettingsSwitchRow {
                    width: parent.width
                    title: I18n.tr(
                        "settings.connectivity.autoconnect",
                        "Automatic connection"
                    )
                    description: modelData.name
                    checked: modelData.autoconnect
                    available: !ConnectivityManagerService.busy
                    onToggled: value =>
                        ConnectivityManagerService.setAutoconnect(
                            modelData.uuid,
                            value
                        )
                }
            }
        }
    }
}

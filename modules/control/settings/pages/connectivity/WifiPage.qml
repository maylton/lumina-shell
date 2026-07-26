pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control.settings
import qs.services.connectivity
import qs.services.i18n

Column {
    id: root

    signal passwordRequested(var network)

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var wifiProfiles:
        ConnectivityManagerService.wifiProfiles()

    width: parent ? parent.width : 0
    spacing: luminaDesign.spacing.controlSectionGap

    function networkNeedsPassword(network) {
        const security = String(network && network.security || "").trim()
        return security.length > 0 && security !== "--"
    }

    function requestConnection(network) {
        if (!network)
            return

        if (network.active) {
            ConnectivityManagerService.disconnectWifi()
            return
        }

        const saved = ConnectivityManagerService.savedWifiProfile(network.ssid)
        if (saved) {
            ConnectivityManagerService.activateConnection(saved.uuid)
            return
        }

        if (networkNeedsPassword(network)) {
            passwordRequested(network)
            return
        }

        ConnectivityManagerService.connectWifi(
            network.ssid,
            network.security,
            ""
        )
    }

    SettingsSection {
        title: I18n.tr(
            "settings.connectivity.wifi.section",
            "Wi-Fi"
        )
        description: ConnectivityManagerService.lastError
            || ConnectivityManagerService.statusMessage

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.connectivity.wifi.enabled",
                "Wi-Fi"
            )
            description: ConnectivityService.wifiConnected
                ? ConnectivityService.wifiName
                : ConnectivityService.wifiEnabled
                    ? I18n.tr(
                        "dashboard.status.wifi.notConnected",
                        "Not connected"
                    )
                    : I18n.tr(
                        "dashboard.status.disabled",
                        "Disabled"
                    )
            iconName: ConnectivityService.wifiConnected
                ? "network-wireless-signal-excellent-symbolic"
                : ConnectivityService.wifiEnabled
                    ? "network-wireless-symbolic"
                    : "network-wireless-disabled-symbolic"
            symbol: "◉"
            available: ConnectivityService.wifiAvailable
            checked: ConnectivityService.wifiEnabled
            onToggled: value =>
                ConnectivityManagerService.setWifiEnabled(value)
        }

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.connectivity.wifi.scan",
                "Scan for networks"
            )
            description: I18n.tr(
                "settings.connectivity.wifi.scanDescription",
                "Refresh the nearby access point list"
            )
            iconName: "view-refresh-symbolic"
            symbol: "↻"
            actionLabel: ConnectivityManagerService.busyAction === "wifi-scan"
                ? I18n.tr(
                    "settings.connectivity.scanning",
                    "Scanning"
                )
                : I18n.tr(
                    "settings.connectivity.scan",
                    "Scan"
                )
            available: ConnectivityService.wifiEnabled
                && !ConnectivityManagerService.busy
            onActivated: ConnectivityManagerService.scanWifi()
        }
    }

    SettingsSection {
        visible: ConnectivityService.wifiEnabled
            && ConnectivityManagerService.wifiNetworks.length > 0
        title: I18n.tr(
            "settings.connectivity.wifi.scan",
            "Scan for networks"
        )
        description: I18n.tr(
            "settings.connectivity.wifi.scanDescription",
            "Refresh the nearby access point list"
        )

        BoundedList {
            maximumHeight: 360

            Repeater {
                model: ConnectivityManagerService.wifiNetworks

                delegate: SettingsActionRow {
                    required property var modelData

                    width: parent.width
                    title: modelData.ssid
                    description: modelData.active
                        ? I18n.tr(
                            "settings.connectivity.connected",
                            "Connected"
                        )
                        : modelData.signal + "%"
                            + (modelData.security
                                && modelData.security !== "--"
                                ? " · " + modelData.security
                                : " · " + I18n.tr(
                                    "settings.connectivity.openNetwork",
                                    "Open network"
                                ))
                    iconName: modelData.active
                        ? "network-wireless-signal-excellent-symbolic"
                        : "network-wireless-symbolic"
                    symbol: modelData.active ? "●" : "◉"
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
                    onActivated: root.requestConnection(modelData)
                }
            }
        }
    }

    SettingsSection {
        visible: root.wifiProfiles.length > 0
        title: I18n.tr(
            "settings.connectivity.savedNetworks.section",
            "Saved Wi-Fi networks"
        )
        description: I18n.tr(
            "settings.connectivity.savedNetworks.description",
            "Control automatic connection or forget a saved profile"
        )

        BoundedList {
            maximumHeight: 320

            Repeater {
                model: root.wifiProfiles

                delegate: Column {
                    required property var modelData
                    property bool settingsGroup: true

                    width: parent.width
                    spacing: 1

                    SettingsSwitchRow {
                        width: parent.width
                        title: modelData.name
                        description: modelData.active
                            ? I18n.tr(
                                "settings.connectivity.connected",
                                "Connected"
                            )
                            : I18n.tr(
                                "settings.connectivity.autoconnectDescription",
                                "Connect automatically when available"
                            )
                        checked: modelData.autoconnect
                        available: !ConnectivityManagerService.busy
                        onToggled: value =>
                            ConnectivityManagerService.setAutoconnect(
                                modelData.uuid,
                                value
                            )
                    }

                    SettingsActionRow {
                        width: parent.width
                        title: I18n.tr(
                            "settings.connectivity.forgetNamed",
                            "Forget %1",
                            [modelData.name]
                        )
                        description: I18n.tr(
                            "settings.connectivity.forgetDescription",
                            "Remove the saved connection profile"
                        )
                        iconName: "edit-delete-symbolic"
                        symbol: "×"
                        actionLabel: I18n.tr(
                            "settings.connectivity.forget",
                            "Forget"
                        )
                        destructive: true
                        available: !modelData.active
                            && !ConnectivityManagerService.busy
                        availabilityText: I18n.tr(
                            "settings.connectivity.disconnectFirst",
                            "Disconnect this item first"
                        )
                        onActivated:
                            ConnectivityManagerService.forgetConnection(
                                modelData.uuid
                            )
                    }
                }
            }
        }
    }
}

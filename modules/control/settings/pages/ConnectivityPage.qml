pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.design
import qs.modules.control.settings
import qs.services.connectivity
import qs.services.i18n

SettingsPage {
    id: root

    property var pendingNetwork: null
    readonly property var wifiProfiles:
        ConnectivityManagerService.wifiProfiles()
    readonly property var wiredProfiles:
        ConnectivityManagerService.wiredProfiles()
    readonly property var wiredDevices:
        ConnectivityManagerService.wiredDevices()

    title: I18n.tr(
        "settings.category.connectivity.label",
        "Connectivity"
    )
    description: I18n.tr(
        "settings.page.connectivity.description",
        "Wi-Fi, wired networking, and Bluetooth devices"
    )

    function networkNeedsPassword(network) {
        const security = String(network && network.security || "").trim()
        return security.length > 0 && security !== "--"
    }

    function savedProfile(network) {
        return ConnectivityManagerService.savedWifiProfile(
            network && network.ssid
        )
    }

    function requestWifiConnection(network) {
        if (!network)
            return

        if (network.active) {
            ConnectivityManagerService.disconnectWifi()
            return
        }

        const saved = savedProfile(network)
        if (saved) {
            ConnectivityManagerService.activateConnection(saved.uuid)
            return
        }

        if (networkNeedsPassword(network)) {
            pendingNetwork = network
            passwordInput.text = ""
            passwordPopup.open()
            Qt.callLater(function() {
                passwordInput.forceActiveFocus(Qt.PopupFocusReason)
            })
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
                onActivated: root.requestWifiConnection(modelData)
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

        Repeater {
            model: root.wifiProfiles

            delegate: Column {
                required property var modelData

                width: parent.width
                spacing: 0

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
                        "Remove the saved NetworkManager profile"
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
                        "Disconnect this profile first"
                    )
                    onActivated:
                        ConnectivityManagerService.forgetConnection(
                            modelData.uuid
                        )
                }
            }
        }
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
                return device.device + " · " + device.state
            }).join(", ")

        Repeater {
            model: root.wiredProfiles

            delegate: Column {
                required property var modelData

                width: parent.width
                spacing: 0

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

    SettingsSection {
        title: I18n.tr(
            "settings.connectivity.bluetooth.section",
            "Bluetooth"
        )

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

        Repeater {
            model: ConnectivityManagerService.bluetoothDevices

            delegate: Column {
                required property var modelData

                width: parent.width
                spacing: 0

                SettingsActionRow {
                    width: parent.width
                    title: modelData.name
                    description: modelData.connected
                        ? I18n.tr(
                            "settings.connectivity.connected",
                            "Connected"
                        )
                        : modelData.paired
                            ? I18n.tr(
                                "settings.connectivity.bluetooth.paired",
                                "Paired"
                            )
                            : modelData.address
                    iconName: modelData.connected
                        ? "bluetooth-active-symbolic"
                        : "bluetooth-symbolic"
                    symbol: "ᛒ"
                    actionLabel: modelData.connected
                        ? I18n.tr(
                            "settings.connectivity.disconnect",
                            "Disconnect"
                        )
                        : modelData.paired
                            ? I18n.tr(
                                "settings.connectivity.connect",
                                "Connect"
                            )
                            : I18n.tr(
                                "settings.connectivity.bluetooth.pair",
                                "Pair"
                            )
                    available: !ConnectivityManagerService.busy
                    onActivated: {
                        if (modelData.connected) {
                            ConnectivityManagerService.disconnectBluetooth(
                                modelData.address
                            )
                        } else if (modelData.paired) {
                            ConnectivityManagerService.connectBluetooth(
                                modelData.address
                            )
                        } else {
                            ConnectivityManagerService.pairBluetooth(
                                modelData.address
                            )
                        }
                    }
                }

                SettingsActionRow {
                    visible: modelData.paired
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
                    available: !modelData.connected
                        && !ConnectivityManagerService.busy
                    availabilityText: I18n.tr(
                        "settings.connectivity.disconnectFirst",
                        "Disconnect this device first"
                    )
                    onActivated:
                        ConnectivityManagerService.removeBluetooth(
                            modelData.address
                        )
                }
            }
        }
    }

    Controls.Popup {
        id: passwordPopup

        parent: root
        anchors.centerIn: parent
        width: Math.min(420, root.width - 40)
        height: 220
        modal: true
        focus: true
        closePolicy: Controls.Popup.CloseOnEscape
            | Controls.Popup.CloseOnPressOutside

        background: Rectangle {
            radius: root.luminaDesign.shape.extraLarge
            color: root.luminaDesign.color.surfaceContainer
            border.width: 1
            border.color: root.luminaDesign.color.outline
        }

        contentItem: Column {
            spacing: root.luminaDesign.spacing.large

            Text {
                width: parent.width
                - root.luminaDesign.spacing.extraLarge * 2
                x: root.luminaDesign.spacing.extraLarge
                text: I18n.tr(
                    "settings.connectivity.wifi.passwordFor",
                    "Password for %1",
                    [root.pendingNetwork
                        ? root.pendingNetwork.ssid
                        : ""]
                )
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleMedium
                font.weight: Font.Bold
            }

            Rectangle {
                width: parent.width
                    - root.luminaDesign.spacing.extraLarge * 2
                height: 44
                x: root.luminaDesign.spacing.extraLarge
                radius: root.luminaDesign.shape.full
                color: root.luminaDesign.color.surfaceMuted
                border.width: passwordInput.activeFocus ? 2 : 1
                border.color: passwordInput.activeFocus
                    ? root.luminaDesign.color.primary
                    : root.luminaDesign.color.outline

                TextInput {
                    id: passwordInput

                    anchors {
                        fill: parent
                        leftMargin: root.luminaDesign.spacing.large
                        rightMargin: root.luminaDesign.spacing.large
                    }
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    selectByMouse: true
                    color: root.luminaDesign.color.onSurface
                    font.pixelSize:
                        root.luminaDesign.typography.bodyMedium
                    Keys.onReturnPressed: event => {
                        connectPasswordButton.activate()
                        event.accepted = true
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: root.luminaDesign.spacing.medium

                Rectangle {
                    width: 120
                    height: 40
                    radius: root.luminaDesign.shape.full
                    color: root.luminaDesign.color.surfaceMuted

                    Text {
                        anchors.centerIn: parent
                        text: I18n.tr(
                            "settings.connectivity.cancel",
                            "Cancel"
                        )
                        color: root.luminaDesign.color.onSurface
                        font.pixelSize:
                            root.luminaDesign.typography.labelMedium
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: passwordPopup.close()
                    }
                }

                Rectangle {
                    id: connectPasswordButton

                    width: 120
                    height: 40
                    radius: root.luminaDesign.shape.full
                    color: root.luminaDesign.color.accentContainer

                    function activate() {
                        if (!root.pendingNetwork || !passwordInput.text)
                            return

                        ConnectivityManagerService.connectWifi(
                            root.pendingNetwork.ssid,
                            root.pendingNetwork.security,
                            passwordInput.text
                        )
                        passwordInput.text = ""
                        root.pendingNetwork = null
                        passwordPopup.close()
                    }

                    Text {
                        anchors.centerIn: parent
                        text: I18n.tr(
                            "settings.connectivity.connect",
                            "Connect"
                        )
                        color:
                            root.luminaDesign.color.onAccentContainer
                        font.pixelSize:
                            root.luminaDesign.typography.labelMedium
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: connectPasswordButton.activate()
                    }
                }
            }
        }
    }
}

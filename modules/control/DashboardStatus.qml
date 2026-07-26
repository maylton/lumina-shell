pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.connectivity
import qs.services.i18n
import qs.stores.control

DashboardCard {
    id: root

    readonly property string wifiDetail: ConnectivityService.wifiConnected
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
    readonly property string networkDetail:
        ConnectivityService.wifiConnected
            ? ConnectivityService.wifiName
            : ConnectivityService.wiredConnected
                ? I18n.tr(
                    "dashboard.status.wired",
                    "Wired"
                )
                : I18n.tr(
                    "dashboard.status.offline",
                    "Offline"
                )
    readonly property bool networkOffline:
        !ConnectivityService.wifiConnected
        && !ConnectivityService.wiredConnected
    readonly property string bluetoothDetail:
        !ConnectivityService.bluetoothAvailable
            ? I18n.tr(
                "common.unavailable",
                "Unavailable"
            )
            : !ConnectivityService.bluetoothEnabled
                ? I18n.tr(
                    "dashboard.status.disabled",
                    "Disabled"
                )
                : ConnectivityService.bluetoothConnectedCount > 0
                    ? ConnectivityService.bluetoothSummary
                    : I18n.tr(
                        "dashboard.status.bluetooth.on",
                        "On"
                    )

    accessibleName: I18n.tr(
        "dashboard.status.accessibleName",
        "Connectivity and system status"
    )

    Column {
        anchors {
            fill: parent
            margins: root.luminaDesign.spacing.controlContentInset
        }

        spacing: root.luminaDesign.spacing.controlItemGap

        Row {
            width: parent.width

            Text {
                width: parent.width
                text: I18n.tr(
                    "dashboard.status.title",
                    "System status"
                )
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleMedium
                font.weight: Font.Bold
            }
        }

        Row {
            width: parent.width
            spacing: root.luminaDesign.spacing.controlItemGap

            QuickToggle {
                width: (parent.width - parent.spacing) / 2
                title: "Wi-Fi"
                detail: root.wifiDetail
                iconName: ConnectivityService.wifiConnected
                    ? "network-wireless-signal-excellent-symbolic"
                    : ConnectivityService.wifiEnabled
                        ? "network-wireless-symbolic"
                        : "network-wireless-disabled-symbolic"
                symbol: "◉"
                checked: ConnectivityService.wifiEnabled
                available: ConnectivityService.wifiAvailable
                onToggled: ConnectivityService.toggleWifi()
            }

            QuickToggle {
                width: (parent.width - parent.spacing) / 2
                title: "Bluetooth"
                detail: root.bluetoothDetail
                iconName: ConnectivityService.bluetoothEnabled
                    ? "bluetooth-active-symbolic"
                    : "bluetooth-disabled-symbolic"
                symbol: "ᛒ"
                checked: ConnectivityService.bluetoothEnabled
                available: ConnectivityService.bluetoothAvailable
                onToggled: ConnectivityService.toggleBluetooth()
            }
        }

        Row {
            width: parent.width
            spacing: root.luminaDesign.spacing.small

            Repeater {
                model: [
                    {
                        label: root.networkDetail,
                        value: I18n.tr(
                            "dashboard.status.connection",
                            "Connection"
                        ),
                        connection: true
                    },
                    {
                        label: ControlCenterStore.uptimeLabel,
                        value: I18n.tr(
                            "dashboard.status.uptime",
                            "Uptime"
                        ),
                        connection: false
                    },
                    {
                        label: ConnectivityService.bluetoothConnectedCount,
                        value: I18n.tr(
                            "dashboard.status.connectedDevices",
                            "Connected devices"
                        ),
                        connection: false
                    }
                ]

                delegate: Rectangle {
                    id: statusMetric

                    required property var modelData

                    width: (parent.width - parent.spacing * 2) / 3
                    height: 44
                    radius: root.luminaDesign.shape.medium
                    color: root.luminaDesign.color.surfaceMuted

                    Column {
                        anchors.centerIn: parent
                        spacing: 0

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: statusMetric.modelData.label
                            color: statusMetric.modelData.connection
                                ? root.networkOffline
                                    ? root.luminaDesign.color.urgent
                                    : root.luminaDesign.color.primary
                                : root.luminaDesign.color.onSurface
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: statusMetric.modelData.value
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize:
                                root.luminaDesign.typography.labelSmall
                        }
                    }
                }
            }
        }
    }
}

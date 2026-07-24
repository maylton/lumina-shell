pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.connectivity
import qs.stores.control

DashboardCard {
    id: root

    accessibleName: "Connectivity and system status"

    Column {
        anchors {
            fill: parent
            margins: root.luminaDesign.spacing.large
        }

        spacing: root.luminaDesign.spacing.medium

        Row {
            width: parent.width

            Text {
                width: parent.width
                text: "System status"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleMedium
                font.weight: Font.Bold
            }
        }

        Row {
            width: parent.width
            spacing: root.luminaDesign.spacing.medium

            QuickToggle {
                width: (parent.width - parent.spacing) / 2
                title: "Wi-Fi"
                detail: ConnectivityService.wifiName
                symbol: "◉"
                checked: ConnectivityService.wifiEnabled
                available: ConnectivityService.wifiAvailable
                onToggled: ConnectivityService.toggleWifi()
            }

            QuickToggle {
                width: (parent.width - parent.spacing) / 2
                title: "Bluetooth"
                detail: ConnectivityService.bluetoothSummary
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
                        label: ConnectivityService.networkSummary,
                        value: "Connection",
                        connection: true
                    },
                    {
                        label: ControlCenterStore.uptimeLabel,
                        value: "Uptime",
                        connection: false
                    },
                    {
                        label: ConnectivityService.bluetoothConnectedCount,
                        value: "Connected devices",
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
                                ? ConnectivityService.networkSummary
                                    === "Offline"
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

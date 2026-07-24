pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.modules.notifications
import qs.services.notifications

DashboardCard {
    id: root

    property bool compact: false

    accessibleName: "Notification history"

    Column {
        anchors {
            fill: parent
            margins: root.luminaDesign.spacing.large
        }

        spacing: root.luminaDesign.spacing.medium

        Row {
            width: parent.width
            height: 38
            spacing: root.luminaDesign.spacing.small

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                    - dndAction.width
                    - clearAction.width
                    - parent.spacing * 2
                spacing: 1

                Text {
                    width: parent.width
                    text: "Notifications"
                    color: root.luminaDesign.color.onSurface
                    font.pixelSize:
                        root.luminaDesign.typography.titleMedium
                    font.weight: Font.Bold
                }

                Text {
                    width: parent.width
                    text: NotificationService.history.length === 0
                        ? "All caught up"
                        : NotificationService.unreadCount > 0
                            ? NotificationService.unreadCount + " unread"
                            : NotificationService.history.length
                                + " in history"
                    color: root.luminaDesign.color.textMuted
                    font.pixelSize:
                        root.luminaDesign.typography.labelSmall
                }
            }

            DashboardAction {
                id: dndAction

                wide: !root.compact
                symbol: "◐"
                label: NotificationService.doNotDisturb
                    ? "Silent"
                    : "Alerts"
                checked: NotificationService.doNotDisturb
                onActivated: NotificationService.toggleDoNotDisturb()
            }

            DashboardAction {
                id: clearAction

                wide: !root.compact
                symbol: "≡"
                label: "Clear"
                available: NotificationService.history.length > 0
                onActivated: NotificationService.clearHistory()
            }
        }

        ListView {
            id: historyList

            width: parent.width
            height: parent.height - 38 - parent.spacing
            spacing: root.luminaDesign.spacing.medium
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: ScriptModel {
                values: NotificationService.history
            }

            delegate: NotificationCard {
                required property var modelData

                width: historyList.width
                entry: modelData
            }

            Column {
                anchors.centerIn: parent
                visible: NotificationService.history.length === 0
                spacing: root.luminaDesign.spacing.medium

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: NotificationService.doNotDisturb ? "◐" : "♧"
                    color: root.luminaDesign.color.textMuted
                    font.pixelSize: 42
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: NotificationService.doNotDisturb
                        ? "Do Not Disturb is on"
                        : "No notifications"
                    color: root.luminaDesign.color.textMuted
                    font.pixelSize:
                        root.luminaDesign.typography.bodyMedium
                    font.weight: Font.DemiBold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: NotificationService.doNotDisturb
                    text: "New alerts stay quiet"
                    color: root.luminaDesign.color.textMuted
                    font.pixelSize:
                        root.luminaDesign.typography.labelSmall
                }
            }
        }
    }
}

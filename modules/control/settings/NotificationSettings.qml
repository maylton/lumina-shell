pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.notifications
import qs.stores.config

Flickable {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    clip: true
    contentWidth: width
    contentHeight: contentColumn.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: contentColumn

        width: root.width
        spacing: root.luminaDesign.spacing.large

        Column {
            width: parent.width
            spacing: 3

            Text {
                text: "Notifications"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleLarge
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                text: "Persistent notification behavior"
                color: root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.labelMedium
                wrapMode: Text.WordWrap
            }
        }

        DashboardCard {
            width: parent.width
            height: 116
            accessibleName: "Notification settings"

            QuickToggle {
                anchors {
                    fill: parent
                    margins: root.luminaDesign.spacing.extraLarge
                }

                title: "Do Not Disturb"
                detail: ConfigStore.doNotDisturb
                    ? "Notification popups are paused"
                    : "Notification popups are allowed"
                iconName: "notifications-disabled-symbolic"
                symbol: "◐"
                checked: ConfigStore.doNotDisturb
                onToggled: NotificationService.toggleDoNotDisturb()
            }
        }

        Text {
            width: parent.width
            text: "Recent notifications remain in the Dashboard, where "
                + "they are available as a daily control."
            color: root.luminaDesign.color.textMuted
            font.pixelSize: root.luminaDesign.typography.labelSmall
            wrapMode: Text.WordWrap
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.notifications
import qs.stores.config
import qs.stores.control
import qs.stores.session

Item {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens

    implicitHeight: 52

    Row {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        spacing: root.luminaDesign.spacing.medium

        Rectangle {
            width: 38
            height: 38
            radius: root.luminaDesign.shape.large
            color: root.luminaDesign.color.accentContainer

            Text {
                anchors.centerIn: parent
                text: "L"
                color: root.luminaDesign.color.onAccentContainer
                font.pixelSize: 20
                font.weight: Font.Bold
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                text: "Lumina"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleMedium
                font.weight: Font.Bold
            }

            Text {
                text: ControlCenterStore.activePage === "settings"
                    ? "Shell configuration"
                    : "Desktop dashboard"
                color: root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.labelSmall
            }
        }
    }

    Row {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        spacing: root.luminaDesign.spacing.small

        DashboardAction {
            symbol: "⚙"
            label: "Open shell settings"
            checked: ControlCenterStore.activePage === "settings"
            onActivated: ControlCenterStore.setPage("settings")
        }

        DashboardAction {
            visible: ConfigStore.dashboardShowSessionActions
            iconName: "system-shutdown-symbolic"
            symbol: "⏻"
            label: "Open session controls"
            onActivated: SessionMenuStore.openFor(root.outputName)
        }

        DashboardAction {
            iconName: "notifications-disabled-symbolic"
            symbol: "◐"
            label: "Do Not Disturb"
            checked: NotificationService.doNotDisturb
            onActivated: NotificationService.toggleDoNotDisturb()
        }

        DashboardAction {
            iconName: "window-close-symbolic"
            symbol: "×"
            label: "Close control center"
            onActivated: ControlCenterStore.close()
        }
    }
}

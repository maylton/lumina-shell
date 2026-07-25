pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.notifications

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: NotificationService.centerOutputName
        === outputName

    implicitWidth: notificationLabel.implicitWidth + 20
        + (NotificationService.unreadCount > 0 ? badge.width + 4 : 0)
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded ? luminaDesign.shape.full : luminaDesign.shape.medium
    scale: notificationMouse.pressed
        ? 0.94
        : notificationMouse.containsMouse
            ? 1.03
            : 1.0
    color: expanded || notificationMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : "transparent"
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary
    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: "Open notifications"
    Accessible.description: NotificationService.unreadCount
        + " unread notifications"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction:
        NotificationService.toggleCenter(root.outputName)

    Keys.onSpacePressed: event => {
        NotificationService.toggleCenter(root.outputName)
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        NotificationService.toggleCenter(root.outputName)
        event.accepted = true
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.fast
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 4

        Text {
            id: notificationLabel

            text: NotificationService.doNotDisturb ? "DND" : "Alerts"
            color: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            font.pixelSize: root.luminaDesign.typography.labelMedium
            font.weight: Font.DemiBold
        }

        Rectangle {
            id: badge

            visible: NotificationService.unreadCount > 0
            width: Math.max(18, badgeLabel.implicitWidth + 8)
            height: 18
            radius: root.luminaDesign.shape.full
            color: root.luminaDesign.color.urgent

            Text {
                id: badgeLabel

                anchors.centerIn: parent
                text: NotificationService.unreadCount > 99
                    ? "99+"
                    : String(NotificationService.unreadCount)
                color: root.luminaDesign.color.surfaceBase
                font.pixelSize: root.luminaDesign.typography.labelSmall
                font.weight: Font.Bold
            }
        }
    }

    MouseArea {
        id: notificationMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            NotificationService.toggleCenter(root.outputName)
        }
    }
}

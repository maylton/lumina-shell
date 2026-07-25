pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.bar.widgets
import qs.modules.control
import qs.services.notifications

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: NotificationService.centerOutputName
        === outputName

    property bool tooltipVisible: false

    implicitWidth: luminaDesign.size.barTouchTarget
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
    Accessible.name: expanded
        ? qsTr("Close notifications")
        : qsTr("Open notifications")
    Accessible.description: NotificationService.unreadCount
        + qsTr(" unread notifications")
        + (
            NotificationService.doNotDisturb
                ? qsTr(". Do Not Disturb is enabled")
                : ""
        )
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

    DashboardIcon {
        id: notificationIcon

        anchors.centerIn: parent
        customSource: Qt.resolvedUrl(
            "../../assets/icons/notification-symbolic.svg"
        )
        fallbackSymbol: "●"
        iconColor: root.expanded
            ? root.luminaDesign.color.onAccentContainer
            : NotificationService.doNotDisturb
                ? root.luminaDesign.color.textMuted
                : root.luminaDesign.color.onSurface
        iconSize: root.luminaDesign.size.trayIcon
    }

    Rectangle {
        anchors.centerIn: notificationIcon
        visible: NotificationService.doNotDisturb
        width: notificationIcon.width + 4
        height: 2
        radius: 1
        rotation: -45
        color: root.expanded
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.textMuted
    }

    Rectangle {
        id: badge

        anchors {
            right: parent.right
            top: parent.top
        }

        visible: NotificationService.unreadCount > 0
        width: Math.max(17, badgeLabel.implicitWidth + 7)
        height: 17
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

    MouseArea {
        id: notificationMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: tooltipTimer.restart()
        onExited: {
            tooltipTimer.stop()
            root.tooltipVisible = false
        }
        onPressed: {
            tooltipTimer.stop()
            root.tooltipVisible = false
        }
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            NotificationService.toggleCenter(root.outputName)
        }
    }

    Timer {
        id: tooltipTimer

        interval: 450
        repeat: false
        onTriggered: root.tooltipVisible =
            notificationMouse.containsMouse
    }

    TrayTooltip {
        anchorItem: root
        title: NotificationService.doNotDisturb
            ? qsTr("Notifications · DND")
            : qsTr("Notifications")
        description: NotificationService.unreadCount > 0
            ? qsTr("%1 unread").arg(NotificationService.unreadCount)
            : qsTr("No unread notifications")
        shown: root.tooltipVisible && !root.expanded
    }
}

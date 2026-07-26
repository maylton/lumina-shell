pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.bar.widgets
import qs.modules.control
import qs.services.notifications
import qs.stores.config
import qs.stores.shell

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: NotificationService.centerOutputName
        === outputName
    readonly property real circleDiameter:
        luminaDesign.size.barTouchTarget
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "notifications",
            "showBackground",
            false
        )
    )
    readonly property bool showUnreadBadge: Boolean(
        ConfigStore.widgetSetting(
            "notifications",
            "showUnreadBadge",
            true
        )
    )
    readonly property bool showDoNotDisturbState: Boolean(
        ConfigStore.widgetSetting(
            "notifications",
            "showDoNotDisturbState",
            true
        )
    )
    readonly property string surfacePlacement: String(
        ConfigStore.widgetSetting(
            "notifications",
            "surfacePlacement",
            "near-widget"
        )
    )

    property bool tooltipVisible: false

    width: circleDiameter
    height: circleDiameter
    implicitWidth: circleDiameter
    implicitHeight: circleDiameter
    radius: expanded || notificationMouse.pressed
        ? luminaDesign.shape.barIconActivated
        : circleDiameter / 2
    scale: notificationMouse.pressed
        ? 0.96
        : 1.0
    color: expanded || notificationMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : showBackground
            ? luminaDesign.color.surfaceMuted
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
    Accessible.onPressAction: root.activate(root.width / 2)

    function mappedAnchorX(localX) {
        const point = root.mapToItem(
            null,
            Number(localX),
            root.height / 2
        )
        return Number(point.x)
    }

    function activate(localX) {
        OverlayStore.prepareFor(
            "notifications",
            root.outputName,
            root.surfacePlacement,
            mappedAnchorX(localX)
        )
        NotificationService.toggleCenter(root.outputName)
    }

    Keys.onSpacePressed: event => {
        root.activate(root.width / 2)
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.activate(root.width / 2)
        event.accepted = true
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialFast
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
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
            : root.showDoNotDisturbState
                && NotificationService.doNotDisturb
                ? root.luminaDesign.color.textMuted
                : root.luminaDesign.color.onSurface
        iconSize: root.luminaDesign.size.barNotificationIcon
    }

    Rectangle {
        anchors.centerIn: notificationIcon
        visible: root.showDoNotDisturbState
            && NotificationService.doNotDisturb
        width: notificationIcon.width
            + root.luminaDesign.spacing.extraSmall
        height: Math.max(
            2,
            Math.round(root.luminaDesign.size.barContentScale * 2)
        )
        radius: height / 2
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

        visible: root.showUnreadBadge
            && NotificationService.unreadCount > 0
        width: Math.max(
            root.luminaDesign.size.barBadgeHeight,
            badgeLabel.implicitWidth
                + root.luminaDesign.size.barBadgePadding
        )
        height: root.luminaDesign.size.barBadgeHeight
        radius: root.luminaDesign.shape.full
        color: root.luminaDesign.color.urgent

        Text {
            id: badgeLabel

            anchors.centerIn: parent
            text: NotificationService.unreadCount > 99
                ? "99+"
                : String(NotificationService.unreadCount)
            color: root.luminaDesign.color.surfaceBase
            font.pixelSize: root.luminaDesign.typography.barBadge
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
        onClicked: mouse => {
            root.focus = false
            root.activate(mouse.x)
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

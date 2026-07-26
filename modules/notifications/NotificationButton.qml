pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.bar.widgets
import qs.modules.control
import qs.services.i18n
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
        ? I18n.tr(
            "bar.notifications.close",
            "Close notifications"
        )
        : I18n.tr(
            "bar.notifications.open",
            "Open notifications"
        )
    Accessible.description: I18n.tr(
        "bar.notifications.unread",
        "%1 unread notifications",
        [NotificationService.unreadCount]
    ) + (
        NotificationService.doNotDisturb
            ? ". " + I18n.tr(
                "bar.notifications.dndDescription",
                "Do Not Disturb is enabled"
            )
            : ""
    )
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate(root.width / 2)

    function mappedAnchorGeometry(localX) {
        const top = root.mapToItem(
            null,
            Number(localX),
            0
        )
        const bottom = root.mapToItem(
            null,
            Number(localX),
            root.height
        )

        return {
            x: Number(top.x),
            top: Number(top.y),
            bottom: Number(bottom.y)
        }
    }

    function validAnchorGeometry(anchor) {
        return anchor
            && isFinite(Number(anchor.x))
            && isFinite(Number(anchor.top))
            && isFinite(Number(anchor.bottom))
            && Number(anchor.x) >= 0
            && Number(anchor.top) >= 0
            && Number(anchor.bottom) >= Number(anchor.top)
    }

    function activate(localX) {
        const anchor = mappedAnchorGeometry(localX)

        BarPanelCoordinator.requestToggle(
            "notifications",
            root.outputName,
            root.surfacePlacement,
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

    Keys.onSpacePressed: event => {
        root.activate(root.width / 2)
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.activate(root.width / 2)
        event.accepted = true
    }

    Connections {
        target: BarPanelCoordinator

        function onOpenRequested(
            panelId,
            outputName,
            placement,
            anchorX,
            anchorTop,
            anchorBottom
        ) {
            if (panelId !== "notifications" || outputName !== root.outputName)
                return

            const currentAnchor = root.mappedAnchorGeometry(root.width / 2)
            const anchor = root.visible
                && root.width > 0
                && root.height > 0
                && root.validAnchorGeometry(currentAnchor)
                ? currentAnchor
                : {
                    x: anchorX,
                    top: anchorTop,
                    bottom: anchorBottom
                }

            OverlayStore.prepareFor(
                "notifications",
                root.outputName,
                placement,
                anchor.x,
                anchor.top,
                anchor.bottom
            )
            NotificationService.openCenter(root.outputName)
        }

        function onCloseRequested(panelId, outputName) {
            if (panelId !== "notifications" || outputName !== root.outputName)
                return

            if (root.expanded)
                NotificationService.closeCenter()
            else
                BarPanelCoordinator.reportClosed(
                    "notifications",
                    root.outputName
                )
        }
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
        onClicked: mouse => {
            root.focus = false
            root.activate(mouse.x)
        }
    }
}

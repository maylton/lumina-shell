pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.stores.config
import qs.stores.launcher

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: LauncherStore.open
        && LauncherStore.activeOutputName === outputName
    readonly property real circleDiameter:
        luminaDesign.size.barTouchTarget
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "launcher",
            "showBackground",
            false
        )
    )
    readonly property bool showLabel: Boolean(
        ConfigStore.widgetSetting("launcher", "showLabel", false)
    )

    width: showLabel
        ? launcherContent.implicitWidth
            + luminaDesign.spacing.barWidgetPadding * 2
        : circleDiameter
    height: circleDiameter
    implicitWidth: circleDiameter
    implicitHeight: circleDiameter
    radius: expanded || launcherMouse.pressed
        ? luminaDesign.shape.barIconActivated
        : circleDiameter / 2
    scale: launcherMouse.pressed
        ? 0.96
        : 1.0
    color: expanded || launcherMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : showBackground
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary
    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: "Open application launcher"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: LauncherStore.toggle(root.outputName)

    Keys.onSpacePressed: event => {
        LauncherStore.toggle(root.outputName)
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        LauncherStore.toggle(root.outputName)
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

    Row {
        id: launcherContent

        anchors.centerIn: parent
        spacing: root.showLabel
            ? root.luminaDesign.spacing.barItemGap
            : 0

        DashboardIcon {
            anchors.verticalCenter: parent.verticalCenter
            iconName: "system-search-symbolic"
            fallbackSymbol: "⌕"
            iconColor: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            iconSize: root.luminaDesign.size.barIcon
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showLabel
            text: "Apps"
            color: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            font.pixelSize:
                root.luminaDesign.typography.barSecondary
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: launcherMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.focus = false
            LauncherStore.toggle(root.outputName)
        }
    }
}

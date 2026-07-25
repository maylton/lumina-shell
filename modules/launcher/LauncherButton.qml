pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.stores.launcher

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: LauncherStore.open
        && LauncherStore.activeOutputName === outputName

    implicitWidth: luminaDesign.size.barTouchTarget
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded
        ? luminaDesign.shape.full
        : luminaDesign.shape.barMedium
    scale: launcherMouse.pressed
        ? 0.96
        : 1.0
    color: expanded || launcherMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : luminaDesign.color.surfaceMuted
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

    DashboardIcon {
        anchors.centerIn: parent
        iconName: "system-search-symbolic"
        fallbackSymbol: "⌕"
        iconColor: root.expanded
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        iconSize: root.luminaDesign.size.barIcon
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

pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.stores.launcher

Rectangle {
    id: root

    required property string outputName
    property bool expressive: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: LauncherStore.open
        && LauncherStore.activeOutputName === outputName

    implicitWidth: expressive
        ? luminaDesign.size.barTouchTarget
        : launcherLabel.implicitWidth + 20
    implicitHeight: expressive
        ? luminaDesign.size.barTouchTarget
        : luminaDesign.size.chipHeight
    radius: expanded ? luminaDesign.shape.full : luminaDesign.shape.medium
    scale: launcherMouse.pressed
        ? 0.94
        : launcherMouse.containsMouse
            ? 1.03
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
            duration: root.luminaDesign.motion.fast
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.medium
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.fast
            easing.type: Easing.OutCubic
        }
    }

    DashboardIcon {
        anchors.centerIn: parent
        visible: root.expressive
        iconName: "system-search-symbolic"
        fallbackSymbol: "⌕"
        iconColor: root.expanded
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        iconSize: 18
    }

    Text {
        id: launcherLabel
        anchors.centerIn: parent
        visible: !root.expressive
        text: "Apps"
        color: root.expanded
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        font.pixelSize: root.luminaDesign.typography.labelMedium
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: launcherMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            LauncherStore.toggle(root.outputName)
        }
    }
}

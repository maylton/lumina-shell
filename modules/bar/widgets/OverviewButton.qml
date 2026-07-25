import QtQuick
import qs.design
import qs.modules.control
import qs.services.niri

Rectangle {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    implicitWidth: luminaDesign.size.barTouchTarget
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: NiriService.overviewOpen
        ? luminaDesign.shape.full
        : luminaDesign.shape.barMedium
    scale: overviewMouse.pressed
        ? 0.96
        : 1.0
    color: NiriService.overviewOpen || overviewMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : luminaDesign.color.surfaceMuted
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: NiriService.overviewOpen
        ? "Close Niri overview"
        : "Open Niri overview"
    Accessible.description: "Show workspaces and windows"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate()

    function activate() {
        NiriService.toggleOverview()
    }

    Keys.onSpacePressed: event => {
        activate()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activate()
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
        iconName: "view-grid-symbolic"
        fallbackSymbol: "▦"
        iconColor: NiriService.overviewOpen
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        iconSize: root.luminaDesign.size.barIcon
    }

    MouseArea {
        id: overviewMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.focus = false
            root.activate()
        }
    }

    TrayTooltip {
        anchorItem: root
        title: NiriService.overviewOpen
            ? "Close overview"
            : "Open overview"
        description: "Niri workspace and window overview"
        shown: overviewMouse.containsMouse
    }
}

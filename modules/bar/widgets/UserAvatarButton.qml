import QtQuick
import qs.design
import qs.modules.control
import qs.stores.config
import qs.stores.control
import qs.stores.system

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded:
        ControlCenterStore.activeOutputName === outputName

    implicitWidth: luminaDesign.size.barTouchTarget
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded || avatarMouse.containsMouse
        ? luminaDesign.shape.full
        : luminaDesign.shape.barLarge
    color: expanded || avatarMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : ConfigStore.barWidgetPillsEnabled
            && ConfigStore.barBackgroundMode === "transparent"
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    scale: avatarMouse.pressed ? 0.96 : 1
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: "Open dashboard for "
        + SystemInfoStore.displayName
    Accessible.description: "Quick controls and session actions"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate()

    function activate() {
        if (expanded
            && ControlCenterStore.activePage === "dashboard") {
            ControlCenterStore.close()
        } else {
            ControlCenterStore.openFor(outputName, "dashboard")
        }
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

    UserAvatar {
        anchors.centerIn: parent
        avatarSize: root.luminaDesign.size.barTouchTarget
        borderWidth: root.expanded
            || root.activeFocus
            || avatarMouse.containsMouse
            ? 2
            : 1
        borderColor: root.expanded || avatarMouse.containsMouse
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.primary
    }

    Rectangle {
        anchors.fill: parent
        z: 2
        radius: root.luminaDesign.shape.full
        color: "transparent"
        border.width: root.activeFocus ? 2 : 0
        border.color: root.luminaDesign.color.primary
    }

    MouseArea {
        id: avatarMouse

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
        title: SystemInfoStore.displayName
        description: "Open Dashboard and session actions"
        shown: avatarMouse.containsMouse
    }
}

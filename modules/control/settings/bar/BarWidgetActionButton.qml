import QtQuick
import QtQuick.Controls as Controls
import qs.design
import qs.modules.control

Rectangle {
    id: root

    property string iconName: ""
    property string fallbackSymbol: ""
    property string accessibleName: ""
    property bool destructive: false
    property bool actionEnabled: true

    signal clicked

    readonly property var luminaDesign: Theme.luminaTokens

    width: 38
    height: 38
    radius: actionMouse.pressed
        ? luminaDesign.shape.controlIconActivated
        : width / 2
    color: actionMouse.containsMouse || activeFocus
        ? destructive
            ? Qt.rgba(
                luminaDesign.color.urgent.r,
                luminaDesign.color.urgent.g,
                luminaDesign.color.urgent.b,
                0.15
            )
            : luminaDesign.color.accentContainer
        : luminaDesign.color.surfaceBase
    opacity: actionEnabled ? 1 : 0.38
    activeFocusOnTab: actionEnabled
    border.width: activeFocus ? 2 : 1
    border.color: activeFocus
        ? luminaDesign.color.primary
        : luminaDesign.color.outline

    Accessible.role: Accessible.Button
    Accessible.name: accessibleName
    Accessible.focusable: actionEnabled
    Accessible.focused: activeFocus
    Accessible.onPressAction: activate()

    function activate() {
        if (actionEnabled)
            clicked()
    }

    function activateFromPointer() {
        root.forceActiveFocus()
        root.focus = false
        root.activate()
    }

    Keys.onSpacePressed: event => {
        activate()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activate()
        event.accepted = true
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialFast
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    DashboardIcon {
        anchors.centerIn: parent
        iconName: root.iconName
        fallbackSymbol: root.fallbackSymbol
        iconColor: root.destructive
            ? root.luminaDesign.color.urgent
            : root.luminaDesign.color.onSurface
        iconSize: 18
    }

    MouseArea {
        id: actionMouse

        anchors.fill: parent
        enabled: root.actionEnabled
        hoverEnabled: true
        cursorShape: enabled
            ? Qt.PointingHandCursor
            : Qt.ArrowCursor
        onClicked: root.activateFromPointer()
    }

    Controls.ToolTip.visible:
        actionMouse.containsMouse && root.accessibleName.length > 0
    Controls.ToolTip.text: root.accessibleName
    Controls.ToolTip.delay: 450
}

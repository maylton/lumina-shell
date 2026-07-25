pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    required property string label
    property string iconName: ""
    property string symbol: ""
    property real symbolScale: 1
    property bool checked: false
    property bool available: true
    property bool wide: false

    signal activated

    readonly property var luminaDesign: Theme.luminaTokens

    implicitWidth: wide ? Math.max(86, actionLabel.implicitWidth + 30) : 42
    implicitHeight: 42
    radius: luminaDesign.shape.full
    color: checked
        ? luminaDesign.color.accentContainer
        : actionMouse.containsMouse || activeFocus
            ? Qt.lighter(luminaDesign.color.surfaceMuted, 1.12)
            : luminaDesign.color.surfaceMuted
    opacity: available ? 1 : 0.45
    scale: actionMouse.pressed ? 0.94 : 1
    activeFocusOnTab: available
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: checked
        ? Accessible.CheckBox
        : Accessible.Button
    Accessible.name: label
    Accessible.checked: checked
    Accessible.focusable: available
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activated()

    Keys.onSpacePressed: event => {
        root.activated()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.activated()
        event.accepted = true
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: root.luminaDesign.spacing.small

        DashboardIcon {
            width: root.wide ? 16 : 18
            height: width
            iconName: root.iconName
            fallbackSymbol: root.symbol
            fallbackScale: root.symbolScale
            iconColor: root.checked
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            iconSize: 16
        }

        Text {
            id: actionLabel

            visible: root.wide
            text: root.label
            color: root.checked
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            font.pixelSize: root.luminaDesign.typography.labelMedium
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: actionMouse

        anchors.fill: parent
        enabled: root.available
        hoverEnabled: true
        cursorShape: root.available
            ? Qt.PointingHandCursor
            : Qt.ForbiddenCursor
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            root.activated()
        }
    }
}

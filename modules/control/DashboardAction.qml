pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    required property string symbol
    required property string label
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
            duration: root.luminaDesign.motion.fast
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: root.luminaDesign.spacing.small

        Text {
            width: root.wide ? 16 : 18
            horizontalAlignment: Text.AlignHCenter
            text: root.symbol
            color: root.checked
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            font.pixelSize: 16
            font.weight: Font.DemiBold
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

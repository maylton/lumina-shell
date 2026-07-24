pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    property string label: ""
    property bool selected: false
    property int horizontalPadding: 12

    signal clicked

    readonly property var luminaDesign: Theme.luminaTokens

    implicitWidth: buttonLabel.implicitWidth + horizontalPadding * 2
    implicitHeight: luminaDesign.size.chipHeight
    radius: selected
        ? luminaDesign.shape.full
        : luminaDesign.shape.medium
    scale: buttonMouse.pressed
        ? 0.92
        : buttonMouse.containsMouse
            ? 1.03
            : 1.0
    opacity: enabled ? 1.0 : 0.48
    activeFocusOnTab: enabled
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary
    color: selected
        ? luminaDesign.color.accentContainer
        : buttonMouse.pressed
            ? Qt.darker(luminaDesign.color.surfaceMuted, 1.12)
            : buttonMouse.containsMouse
                ? luminaDesign.color.surfaceMuted
                : "transparent"

    Accessible.role: Accessible.Button
    Accessible.name: label
    Accessible.focusable: enabled
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.clicked()

    Keys.onSpacePressed: event => {
        root.clicked()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.clicked()
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

    Text {
        id: buttonLabel

        anchors.centerIn: parent
        text: root.label
        color: root.selected
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        font.pixelSize: root.luminaDesign.typography.labelMedium
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: buttonMouse

        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            root.clicked()
        }
    }
}

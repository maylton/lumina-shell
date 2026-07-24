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
    color: selected
        ? luminaDesign.color.accentContainer
        : buttonMouse.pressed
            ? Qt.darker(luminaDesign.color.surfaceMuted, 1.12)
            : buttonMouse.containsMouse
                ? luminaDesign.color.surfaceMuted
                : "transparent"

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
        onClicked: root.clicked()
    }
}

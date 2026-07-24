pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.stores.time

Rectangle {
    id: root

    required property string outputName

    signal toggleRequested(Item anchorItem, string outputName)

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: CalendarStore.isOpenFor(outputName)

    implicitWidth: clockLabel.implicitWidth + 20
    implicitHeight: luminaDesign.size.chipHeight
    radius: expanded
        ? luminaDesign.shape.full
        : luminaDesign.shape.medium
    scale: clockMouse.pressed
        ? 0.94
        : clockMouse.containsMouse
            ? 1.03
            : 1.0
    color: expanded || clockMouse.containsMouse
        ? luminaDesign.color.accentContainer
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
        id: clockLabel

        anchors.centerIn: parent
        text: CalendarStore.formattedTime
        color: root.expanded
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        font.pixelSize: root.luminaDesign.typography.titleMedium
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: clockMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleRequested(root, root.outputName)
    }
}

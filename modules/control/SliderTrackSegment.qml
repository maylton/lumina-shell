pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property color segmentColor: "transparent"
    property bool outerAtStart: true
    property real insideRadius: 2

    readonly property real outerRadius: Math.min(
        width / 2,
        height / 2
    )
    readonly property real safeInsideRadius: Math.min(
        insideRadius,
        width / 2,
        height / 2
    )
    readonly property real startRadius: outerAtStart
        ? outerRadius
        : safeInsideRadius
    readonly property real endRadius: outerAtStart
        ? safeInsideRadius
        : outerRadius

    Shape {
        anchors.fill: parent

        ShapePath {
            fillColor: root.segmentColor
            strokeColor: "transparent"
            strokeWidth: -1
            startX: root.startRadius
            startY: 0

            PathLine {
                x: root.width - root.endRadius
                y: 0
            }

            PathQuad {
                x: root.width
                y: root.endRadius
                controlX: root.width
                controlY: 0
            }

            PathLine {
                x: root.width
                y: root.height - root.endRadius
            }

            PathQuad {
                x: root.width - root.endRadius
                y: root.height
                controlX: root.width
                controlY: root.height
            }

            PathLine {
                x: root.startRadius
                y: root.height
            }

            PathQuad {
                x: 0
                y: root.height - root.startRadius
                controlX: 0
                controlY: root.height
            }

            PathLine {
                x: 0
                y: root.startRadius
            }

            PathQuad {
                x: root.startRadius
                y: 0
                controlX: 0
                controlY: 0
            }
        }
    }
}

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
        antialiasing: true

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

            PathArc {
                x: root.width
                y: root.endRadius
                radiusX: root.endRadius
                radiusY: root.endRadius
                direction: PathArc.Clockwise
                useLargeArc: false
            }

            PathLine {
                x: root.width
                y: root.height - root.endRadius
            }

            PathArc {
                x: root.width - root.endRadius
                y: root.height
                radiusX: root.endRadius
                radiusY: root.endRadius
                direction: PathArc.Clockwise
                useLargeArc: false
            }

            PathLine {
                x: root.startRadius
                y: root.height
            }

            PathArc {
                x: 0
                y: root.height - root.startRadius
                radiusX: root.startRadius
                radiusY: root.startRadius
                direction: PathArc.Clockwise
                useLargeArc: false
            }

            PathLine {
                x: 0
                y: root.startRadius
            }

            PathArc {
                x: root.startRadius
                y: 0
                radiusX: root.startRadius
                radiusY: root.startRadius
                direction: PathArc.Clockwise
                useLargeArc: false
            }
        }
    }
}

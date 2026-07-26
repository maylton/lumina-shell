pragma ComponentBehavior: Bound

import QtQuick

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
        Math.max(0, insideRadius),
        width / 2,
        height / 2
    )
    readonly property real innerExtent: Math.min(
        width,
        outerRadius + safeInsideRadius + 1
    )
    readonly property color opaqueSegmentColor: Qt.rgba(
        segmentColor.r,
        segmentColor.g,
        segmentColor.b,
        1
    )

    opacity: segmentColor.a

    // Composite the two contour pieces before an unavailable parent reduces
    // opacity, preventing their overlap from becoming a visible alpha seam.
    layer.enabled: true
    layer.smooth: true

    Rectangle {
        anchors.fill: parent
        radius: root.outerRadius
        color: root.opaqueSegmentColor
        antialiasing: true
    }

    Rectangle {
        width: root.innerExtent
        height: parent.height
        x: root.outerAtStart
            ? parent.width - width
            : 0
        radius: root.safeInsideRadius
        color: root.opaqueSegmentColor
        antialiasing: true
        visible: width > 0
    }
}

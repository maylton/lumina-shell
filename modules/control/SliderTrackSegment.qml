pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property color segmentColor: "transparent"
    property bool outerAtStart: true
    property real insideRadius: 2

    clip: true

    Rectangle {
        readonly property real capInset: Math.min(
            root.width,
            root.height / 2
        )

        x: root.outerAtStart ? capInset : 0
        width: Math.max(0, root.width - capInset)
        height: root.height
        radius: Math.min(root.insideRadius, height / 2)
        color: root.segmentColor
        visible: width > 0
    }

    Rectangle {
        width: root.height
        height: root.height
        x: root.outerAtStart
            ? 0
            : root.width - width
        radius: width / 2
        color: root.segmentColor
    }
}

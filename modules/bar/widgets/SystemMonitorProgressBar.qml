import QtQuick
import qs.design

Rectangle {
    id: root

    property real value: 0
    property color fillColor: luminaDesign.color.primary

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real normalizedValue: Math.max(
        0,
        Math.min(1, Number(value) || 0)
    )

    implicitHeight: 12
    radius: height / 2
    color: luminaDesign.color.outlineVariant
    clip: true

    Rectangle {
        width: root.width * root.normalizedValue
        height: parent.height
        radius: parent.radius
        color: root.fillColor

        Behavior on width {
            NumberAnimation {
                duration: root.luminaDesign.motion.spatialDefault
                easing.type:
                    root.luminaDesign.motion.spatialEasing
                easing.overshoot:
                    root.luminaDesign.motion.spatialOvershoot
            }
        }
    }
}

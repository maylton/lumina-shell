pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    property string accessibleName: ""
    property bool emphasized: false

    readonly property var luminaDesign: Theme.luminaTokens

    radius: luminaDesign.shape.large
    color: emphasized
        ? Qt.lighter(luminaDesign.color.surfaceContainer, 1.06)
        : luminaDesign.color.surfaceBase
    border.width: 1
    border.color: emphasized
        ? luminaDesign.color.accentContainer
        : luminaDesign.color.outline

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialDefault
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsDefault
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Accessible.role: Accessible.Pane
    Accessible.name: accessibleName
}

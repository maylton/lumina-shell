pragma ComponentBehavior: Bound

import QtQuick
import qs.design

FocusScope {
    id: root

    required property string categoryId
    required property int categoryIndex
    required property int activeIndex
    property bool pageActive: false
    default property alias pageData: pageHost.data

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real travel: Math.min(
        40,
        Math.round(width * 0.04)
    )

    x: pageActive
        ? 0
        : categoryIndex < activeIndex
            ? -travel
            : travel
    opacity: pageActive ? 1 : 0
    visible: pageActive || opacity > 0.01
    enabled: pageActive
    focus: pageActive

    Behavior on x {
        NumberAnimation {
            duration: root.luminaDesign.motion.pageTransition
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: root.luminaDesign.motion.effectsDefault
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Item {
        id: pageHost

        anchors.fill: parent
    }
}

import QtQuick
import qs.design
import qs.stores.config

Row {
    readonly property var luminaDesign: Theme.luminaTokens
    property real clusterSpacing:
        luminaDesign.spacing.barConfiguredWidgetGap

    spacing: clusterSpacing

    Behavior on spacing {
        NumberAnimation {
            duration: luminaDesign.motion.spatialDefault
            easing.type: luminaDesign.motion.spatialEasing
            easing.overshoot: luminaDesign.motion.spatialOvershoot
        }
    }
}

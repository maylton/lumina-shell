import QtQuick
import qs.design
import qs.stores.config
import "BarSurfacePolicy.js" as BarSurfacePolicy

Rectangle {
    id: root

    default property alias contentData: content.data
    property string surfaceMode: "floating"
    property string barPosition: "top"
    property int outerMargin: 0

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool edgeToEdge: surfaceMode === "edge-to-edge"
    readonly property string backgroundMode:
        ConfigStore.barBackgroundMode
    readonly property real backgroundAlpha:
        BarSurfacePolicy.backgroundAlpha(
            backgroundMode,
            ConfigStore.barSurfaceOpacity
        )

    function colorWithAlpha(colorValue, alphaValue) {
        return Qt.rgba(
            colorValue.r,
            colorValue.g,
            colorValue.b,
            Math.max(0, Math.min(1, alphaValue))
        )
    }

    anchors.margins: edgeToEdge ? 0 : outerMargin
    radius: edgeToEdge ? 0 : luminaDesign.shape.large
    color: colorWithAlpha(
        luminaDesign.color.surfaceContainer,
        backgroundAlpha
    )
    border.width: edgeToEdge || backgroundMode === "transparent"
        ? 0
        : 1
    border.color: colorWithAlpha(
        luminaDesign.color.outline,
        BarSurfacePolicy.borderAlpha(
            backgroundMode,
            ConfigStore.barSurfaceOpacity
        )
    )

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsDefault
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsDefault
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Item {
        id: content

        anchors.fill: parent
    }

    Rectangle {
        visible: root.edgeToEdge
            && root.backgroundMode !== "transparent"
        anchors {
            left: parent.left
            right: parent.right
            top: root.barPosition === "bottom"
                ? parent.top
                : undefined
            bottom: root.barPosition === "top"
                ? parent.bottom
                : undefined
        }
        height: 1
        color: root.colorWithAlpha(
            root.luminaDesign.color.outline,
            BarSurfacePolicy.dividerAlpha(
                root.backgroundMode,
                ConfigStore.barSurfaceOpacity
            )
        )

        Behavior on color {
            ColorAnimation {
                duration: root.luminaDesign.motion.effectsDefault
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }
    }
}

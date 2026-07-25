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
    readonly property bool frosted:
        backgroundMode === "frosted"
    readonly property real backgroundAlpha:
        BarSurfacePolicy.backgroundAlpha(
            backgroundMode,
            ConfigStore.barSurfaceOpacity
        )
    readonly property string frostedNoiseSource:
        "data:image/svg+xml;utf8,"
        + encodeURIComponent(
            "<svg xmlns='http://www.w3.org/2000/svg' "
            + "width='48' height='48' viewBox='0 0 48 48'>"
            + "<g fill='#ffffff'>"
            + "<circle cx='5' cy='7' r='.55' opacity='.34'/>"
            + "<circle cx='22' cy='4' r='.4' opacity='.22'/>"
            + "<circle cx='39' cy='12' r='.5' opacity='.28'/>"
            + "<circle cx='14' cy='25' r='.45' opacity='.2'/>"
            + "<circle cx='31' cy='31' r='.6' opacity='.3'/>"
            + "<circle cx='44' cy='41' r='.4' opacity='.2'/>"
            + "<circle cx='7' cy='43' r='.5' opacity='.25'/>"
            + "</g><g fill='#000000'>"
            + "<circle cx='29' cy='15' r='.45' opacity='.16'/>"
            + "<circle cx='3' cy='33' r='.4' opacity='.14'/>"
            + "<circle cx='42' cy='26' r='.5' opacity='.12'/>"
            + "</g></svg>"
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
    radius: edgeToEdge ? 0 : luminaDesign.shape.barLarge
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

    Rectangle {
        anchors.fill: parent
        visible: root.frosted
        opacity: root.frosted ? 1 : 0
        radius: root.radius
        color: "transparent"
        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0
                color: root.colorWithAlpha(
                    root.luminaDesign.color.onSurface,
                    Theme.lightMode ? 0.055 : 0.075
                )
            }

            GradientStop {
                position: 0.46
                color: root.colorWithAlpha(
                    root.luminaDesign.color.surfaceContainer,
                    0.025
                )
            }

            GradientStop {
                position: 1
                color: root.colorWithAlpha(
                    root.luminaDesign.color.primary,
                    Theme.lightMode ? 0.035 : 0.05
                )
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.luminaDesign.motion.effectsDefault
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }
    }

    Image {
        anchors {
            fill: parent
            margins: root.edgeToEdge
                ? 0
                : Math.max(2, Math.round(root.radius * 0.45))
        }
        visible: root.frosted
        opacity: root.frosted
            ? (Theme.lightMode ? 0.22 : 0.3)
            : 0
        source: root.frostedNoiseSource
        sourceSize.width: 48
        sourceSize.height: 48
        fillMode: Image.Tile
        smooth: false
        asynchronous: true

        Behavior on opacity {
            NumberAnimation {
                duration: root.luminaDesign.motion.effectsDefault
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }
    }

    Item {
        id: content

        anchors.fill: parent
    }

    Rectangle {
        visible: root.frosted
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: root.edgeToEdge ? 0 : root.radius
            rightMargin: root.edgeToEdge ? 0 : root.radius
            top: root.barPosition === "top"
                ? parent.top
                : undefined
            bottom: root.barPosition === "bottom"
                ? parent.bottom
                : undefined
        }
        height: 1
        color: root.colorWithAlpha(
            root.luminaDesign.color.onSurface,
            Theme.lightMode ? 0.18 : 0.14
        )
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

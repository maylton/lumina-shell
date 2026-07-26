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
        BarSurfacePolicy.normalizeMode(
            ConfigStore.barBackgroundMode
        )
    readonly property bool frosted:
        backgroundMode === "frosted"
    readonly property color tintColor: frosted
        ? luminaDesign.color.barFrostedTint
        : luminaDesign.color.barBlurTint
    readonly property string frostedNoiseSource:
        "data:image/svg+xml;utf8,"
        + encodeURIComponent(
            "<svg xmlns='http://www.w3.org/2000/svg' "
            + "width='160' height='128' viewBox='0 0 160 128'>"
            + "<g fill='#ffffff'>"
            + "<circle cx='7' cy='11' r='.55' opacity='.30'/>"
            + "<circle cx='31' cy='5' r='.35' opacity='.18'/>"
            + "<circle cx='68' cy='17' r='.5' opacity='.24'/>"
            + "<circle cx='119' cy='8' r='.4' opacity='.19'/>"
            + "<circle cx='151' cy='29' r='.55' opacity='.25'/>"
            + "<circle cx='19' cy='53' r='.4' opacity='.17'/>"
            + "<circle cx='83' cy='44' r='.6' opacity='.23'/>"
            + "<circle cx='137' cy='69' r='.35' opacity='.16'/>"
            + "<circle cx='48' cy='91' r='.5' opacity='.22'/>"
            + "<circle cx='103' cy='116' r='.45' opacity='.19'/>"
            + "<circle cx='157' cy='101' r='.4' opacity='.17'/>"
            + "</g><g fill='#000000'>"
            + "<circle cx='51' cy='32' r='.4' opacity='.12'/>"
            + "<circle cx='111' cy='57' r='.5' opacity='.11'/>"
            + "<circle cx='8' cy='108' r='.45' opacity='.10'/>"
            + "<circle cx='73' cy='123' r='.35' opacity='.09'/>"
            + "<circle cx='145' cy='121' r='.5' opacity='.10'/>"
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
    color: "transparent"

    Rectangle {
        id: baseLayer

        anchors.fill: parent
        radius: root.radius
        color: root.colorWithAlpha(
            root.backgroundMode === "solid"
                ? root.luminaDesign.color.barSolidBackground
                : root.luminaDesign.color.barTranslucentBackground,
            root.luminaDesign.effect.barBackgroundAlpha
        )

        Behavior on color {
            ColorAnimation {
                duration:
                    root.luminaDesign.motion.effectsDefault
                easing.type:
                    root.luminaDesign.motion.effectsEasing
            }
        }
    }

    Rectangle {
        id: tintLayer

        anchors.fill: parent
        radius: root.radius
        color: root.colorWithAlpha(
            root.tintColor,
            root.luminaDesign.effect.barTintAlpha
        )

        Behavior on color {
            ColorAnimation {
                duration:
                    root.luminaDesign.motion.effectsDefault
                easing.type:
                    root.luminaDesign.motion.effectsEasing
            }
        }
    }

    Rectangle {
        id: contrastProtectionLayer

        anchors.fill: parent
        radius: root.radius
        color: root.colorWithAlpha(
            root.luminaDesign.color.barBlurContrastProtection,
            root.luminaDesign.effect
                .barContrastProtectionAlpha
        )

        Behavior on color {
            ColorAnimation {
                duration:
                    root.luminaDesign.motion.effectsDefault
                easing.type:
                    root.luminaDesign.motion.effectsEasing
            }
        }
    }

    Rectangle {
        id: frostedHighlightLayer

        anchors.fill: parent
        visible: opacity > 0
        opacity:
            root.luminaDesign.effect.barFrostedHighlightAlpha
        radius: root.radius
        color: "transparent"
        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0
                color:
                    root.luminaDesign.color.barFrostedHighlight
            }

            GradientStop {
                position: 0.38
                color: root.colorWithAlpha(
                    root.luminaDesign.color.barFrostedHighlight,
                    0.24
                )
            }

            GradientStop {
                position: 1
                color: "transparent"
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration:
                    root.luminaDesign.motion.effectsDefault
                easing.type:
                    root.luminaDesign.motion.effectsEasing
            }
        }
    }

    Image {
        id: frostedGrainLayer

        anchors {
            fill: parent
            margins: root.edgeToEdge
                ? 0
                : Math.max(2, Math.round(root.radius * 0.45))
        }
        visible: opacity > 0
        opacity: root.luminaDesign.effect.barFrostedGrainAlpha
        source: root.frostedNoiseSource
        sourceSize.width: 160
        sourceSize.height: 128
        fillMode: Image.Tile
        smooth: false
        asynchronous: true

        Behavior on opacity {
            NumberAnimation {
                duration:
                    root.luminaDesign.motion.effectsDefault
                easing.type:
                    root.luminaDesign.motion.effectsEasing
            }
        }
    }

    Item {
        id: content

        anchors.fill: parent
    }

    Rectangle {
        id: frostedEdgeHighlight

        visible: opacity > 0
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
        opacity:
            root.luminaDesign.effect.barFrostedHighlightAlpha
        color: root.luminaDesign.color.barFrostedHighlight

        Behavior on opacity {
            NumberAnimation {
                duration:
                    root.luminaDesign.motion.effectsDefault
                easing.type:
                    root.luminaDesign.motion.effectsEasing
            }
        }
    }

    Rectangle {
        id: edgeDivider

        visible: root.edgeToEdge && opacity > 0
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
        opacity: root.luminaDesign.effect.barDividerAlpha
        color: root.luminaDesign.color.outline

        Behavior on opacity {
            NumberAnimation {
                duration:
                    root.luminaDesign.motion.effectsDefault
                easing.type:
                    root.luminaDesign.motion.effectsEasing
            }
        }
    }

    Rectangle {
        id: floatingBorder

        anchors.fill: parent
        visible: border.width > 0
        radius: root.radius
        color: "transparent"
        border.width: root.edgeToEdge
            || root.luminaDesign.effect.barBorderAlpha <= 0
                ? 0
                : 1
        border.color: root.colorWithAlpha(
            root.luminaDesign.color.outline,
            root.luminaDesign.effect.barBorderAlpha
        )

        Behavior on border.color {
            ColorAnimation {
                duration:
                    root.luminaDesign.motion.effectsDefault
                easing.type:
                    root.luminaDesign.motion.effectsEasing
            }
        }
    }
}

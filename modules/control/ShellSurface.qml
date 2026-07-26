pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.stores.config
import "ShellSurfacePolicy.js" as ShellSurfacePolicy

Rectangle {
    id: root

    default property alias contentData: content.data

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property string backgroundMode:
        ShellSurfacePolicy.normalizeMode(
  ConfigStore.shellBackgroundMode
        )
    readonly property real configuredOpacity:
        ConfigStore.shellSurfaceOpacity
    readonly property bool frosted:
        backgroundMode === "frosted"
    readonly property color tintColor: frosted
        ? Theme.surfaceMutedColor
        : Theme.surfaceContainerColor
    readonly property color highlightColor: Theme.lightMode
        ? Theme.surfaceBaseColor
        : Theme.onSurfaceColor
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
  + "</g><g fill='#000000'>"
  + "<circle cx='51' cy='32' r='.4' opacity='.12'/>"
  + "<circle cx='111' cy='57' r='.5' opacity='.11'/>"
  + "<circle cx='8' cy='108' r='.45' opacity='.10'/>"
  + "<circle cx='145' cy='121' r='.5' opacity='.10'/>"
  + "</g></svg>"
        )

    function withAlpha(colorValue, alphaValue) {
        return Qt.rgba(
  colorValue.r,
  colorValue.g,
  colorValue.b,
  Math.max(0, Math.min(1, alphaValue))
        )
    }

    color: "transparent"
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.withAlpha(
  Theme.surfaceContainerColor,
  ShellSurfacePolicy.baseAlpha(root.backgroundMode)
        )

        Behavior on color {
  ColorAnimation {
      duration: root.luminaDesign.motion.effectsDefault
      easing.type: root.luminaDesign.motion.effectsEasing
  }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.withAlpha(
  root.tintColor,
  ShellSurfacePolicy.tintAlpha(
      root.backgroundMode,
      root.configuredOpacity,
      Theme.lightMode
  )
        )

        Behavior on color {
  ColorAnimation {
      duration: root.luminaDesign.motion.effectsDefault
      easing.type: root.luminaDesign.motion.effectsEasing
  }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.withAlpha(
  Theme.surfaceBaseColor,
  ShellSurfacePolicy.contrastProtectionAlpha(
      root.backgroundMode,
      Theme.lightMode
  )
        )

        Behavior on color {
  ColorAnimation {
      duration: root.luminaDesign.motion.effectsDefault
      easing.type: root.luminaDesign.motion.effectsEasing
  }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: opacity > 0
        opacity: ShellSurfacePolicy.highlightAlpha(
  root.backgroundMode,
  Theme.lightMode
        )
        radius: root.radius
        color: "transparent"
        gradient: Gradient {
  orientation: Gradient.Horizontal

  GradientStop {
      position: 0
      color: root.highlightColor
  }

  GradientStop {
      position: 0.42
      color: root.withAlpha(root.highlightColor, 0.22)
  }

  GradientStop {
      position: 1
      color: "transparent"
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
  margins: Math.max(2, Math.round(root.radius * 0.38))
        }
        visible: opacity > 0
        opacity: ShellSurfacePolicy.grainAlpha(
  root.backgroundMode,
  Theme.lightMode
        )
        source: root.frostedNoiseSource
        sourceSize.width: 160
        sourceSize.height: 128
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
        z: 10
    }

    Rectangle {
        anchors.fill: parent
        z: 20
        radius: root.radius
        color: "transparent"
        border.width: 1
        border.color: root.withAlpha(
  root.luminaDesign.color.outline,
  ShellSurfacePolicy.borderAlpha(root.backgroundMode)
        )

        Behavior on border.color {
  ColorAnimation {
      duration: root.luminaDesign.motion.effectsDefault
      easing.type: root.luminaDesign.motion.effectsEasing
  }
        }
    }
}

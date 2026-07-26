pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.impl as ControlsImpl
import Quickshell
import qs.design

Item {
    id: root

    property string iconName: ""
    property string customSource: ""
    property string fallbackSymbol: ""
    property color iconColor: luminaDesign.color.onSurface
    property real iconSize: 18
    property real fallbackScale: 1
    property bool loading: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool forceFallback:
        iconName === "view-visible-symbolic"
        || iconName === "view-hidden-symbolic"
    readonly property bool refreshAnimationActive:
        iconName === "view-refresh-symbolic"
        && Math.abs(rotation) > 0.01
    readonly property bool showExpressiveLoading:
        loading || refreshAnimationActive
    readonly property string iconSource: customSource.length > 0
        ? customSource
        : iconName.length > 0 && !forceFallback
            ? Quickshell.iconPath(iconName, "")
            : ""
    readonly property bool iconReady: iconSource.length > 0
        && sourceIcon.status === Image.Ready

    implicitWidth: iconSize
    implicitHeight: iconSize

    Behavior on iconColor {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    ControlsImpl.IconImage {
        id: sourceIcon

        anchors.fill: parent
        source: root.iconSource
        color: root.iconColor
        asynchronous: false
        visible: !root.showExpressiveLoading && root.iconReady
        sourceSize.width: root.iconSize
        sourceSize.height: root.iconSize
    }

    ExpressiveLoadingIndicator {
        anchors.centerIn: parent
        visible: root.showExpressiveLoading
        running: visible
        indicatorColor: root.iconColor
        indicatorSize: root.iconSize
        rotation: -root.rotation
    }

    Text {
        anchors.centerIn: parent
        visible: !root.showExpressiveLoading && !root.iconReady
        text: root.fallbackSymbol
        color: root.iconColor
        font.pixelSize: root.iconSize * root.fallbackScale
        font.weight: Font.DemiBold
    }
}

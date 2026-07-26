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

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property string iconSource: customSource.length > 0
        ? customSource
        : iconName.length > 0
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
        visible: root.iconReady
        sourceSize.width: root.iconSize
        sourceSize.height: root.iconSize
    }

    Text {
        anchors.centerIn: parent
        visible: !root.iconReady
        text: root.fallbackSymbol
        color: root.iconColor
        font.pixelSize: root.iconSize * root.fallbackScale
        font.weight: Font.DemiBold
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    property string iconName: ""
    property string fallbackSymbol: ""
    property color iconColor: "white"
    property real iconSize: 18

    readonly property string iconSource: iconName.length > 0
        ? Quickshell.iconPath(iconName, "")
        : ""
    readonly property bool iconReady: iconSource.length > 0
        && sourceIcon.status === Image.Ready

    implicitWidth: iconSize
    implicitHeight: iconSize

    IconImage {
        id: sourceIcon

        anchors.fill: parent
        source: root.iconSource
        asynchronous: true
        mipmap: true
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: sourceIcon
        visible: root.iconReady
        colorization: 1
        colorizationColor: root.iconColor
    }

    Text {
        anchors.centerIn: parent
        visible: !root.iconReady
        text: root.fallbackSymbol
        color: root.iconColor
        font.pixelSize: root.iconSize
        font.weight: Font.DemiBold
    }
}

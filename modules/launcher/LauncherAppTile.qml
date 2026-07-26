pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design

Rectangle {
    id: root

    required property var result
    required property bool selected
    property int iconSize: 48

    signal activated
    signal contextMenuRequested(var sourceItem)

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool supportsDockPinning:
        result
        && result.kind === "application"
        && result.entry
        && String(result.entry.id || "").length > 0

    implicitWidth: 92
    implicitHeight: 96
    radius: luminaDesign.shape.large
    color: selected
        ? luminaDesign.color.accentContainer
        : "transparent"
    scale: tileMouse.pressed ? 0.98 : 1

    Accessible.role: Accessible.ListItem
    Accessible.name: String(result && result.title || "")
    Accessible.description: String(result && result.subtitle || "")
    Accessible.selected: selected
    Accessible.onPressAction: root.activated()

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Image {
        id: applicationIcon

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 8
        }
        width: root.iconSize
        height: width
        scale: tileMouse.containsMouse
            ? tileMouse.pressed ? 0.96 : 1.05
            : 1
        source: Quickshell.iconPath(
            String(root.result && root.result.icon
                || "application-x-executable"),
            "application-x-executable"
        )
        sourceSize.width: width
        sourceSize.height: height
        asynchronous: false
        fillMode: Image.PreserveAspectFit
        smooth: true

        Behavior on scale {
            NumberAnimation {
                duration: root.luminaDesign.motion.press
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }
    }

    Text {
        anchors {
            left: parent.left
            right: parent.right
            top: applicationIcon.bottom
            topMargin: 6
            leftMargin: 4
            rightMargin: 4
        }
        height: 32
        text: String(root.result && root.result.title || "")
        color: root.selected
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
        font.pixelSize: root.luminaDesign.typography.labelSmall
        font.weight: Font.Medium
    }

    MouseArea {
        id: tileMouse

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (root.supportsDockPinning)
                    root.contextMenuRequested(root)
                return
            }

            root.activated()
        }
    }
}

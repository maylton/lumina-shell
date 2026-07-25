pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design

Rectangle {
    id: root

    required property var result
    required property bool selected

    signal activated

    readonly property var luminaDesign: Theme.luminaTokens

    implicitHeight: root.luminaDesign.size.launcherRowHeight
    radius: selected
        ? root.luminaDesign.shape.large
        : root.luminaDesign.shape.medium
    scale: resultMouse.pressed ? 0.98 : 1.0
    color: selected || resultMouse.containsMouse
        ? root.luminaDesign.color.accentContainer
        : "transparent"

    Accessible.role: Accessible.ListItem
    Accessible.name: String(result.title || "")
    Accessible.description: String(result.subtitle || "")
    Accessible.selected: selected
    Accessible.onPressAction: root.activated()

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.fast
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.fast
            easing.type: Easing.OutCubic
        }
    }

    Image {
        id: resultIcon

        anchors {
            left: parent.left
            leftMargin: root.luminaDesign.spacing.medium
            verticalCenter: parent.verticalCenter
        }

        width: root.luminaDesign.size.launcherIcon
        height: width
        source: Quickshell.iconPath(
            String(root.result.icon || "application-x-executable"),
            "application-x-executable"
        )
        sourceSize.width: width
        sourceSize.height: height
        asynchronous: true
        fillMode: Image.PreserveAspectFit
    }

    Column {
        anchors {
            left: resultIcon.right
            right: kindLabel.left
            leftMargin: root.luminaDesign.spacing.medium
            rightMargin: root.luminaDesign.spacing.medium
            verticalCenter: parent.verticalCenter
        }

        spacing: 2

        Text {
            width: parent.width
            text: String(root.result.title || "")
            color: root.selected
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.bodyMedium
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: String(root.result.subtitle || "")
            visible: text.length > 0
            color: root.selected
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.textMuted
            opacity: 0.82
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.labelSmall
        }
    }

    Rectangle {
        id: kindLabel

        anchors {
            right: parent.right
            rightMargin: root.luminaDesign.spacing.medium
            verticalCenter: parent.verticalCenter
        }

        width: kindText.implicitWidth + 12
        height: 22
        radius: root.luminaDesign.shape.full
        color: root.selected
            ? root.luminaDesign.color.pressedState
            : root.luminaDesign.color.surfaceMuted

        Text {
            id: kindText

            anchors.centerIn: parent
            text: root.result.kind === "application"
                ? "APP"
                : root.result.kind === "window"
                    ? "WINDOW"
                    : "ACTION"
            color: root.selected
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.textMuted
            font.pixelSize: root.luminaDesign.typography.labelSmall
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: resultMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}

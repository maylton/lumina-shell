pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    required property string title
    required property string description
    required property string symbol
    property bool destructive: false

    signal activated

    readonly property var luminaDesign: Theme.luminaTokens

    implicitHeight: 82
    radius: root.luminaDesign.shape.large
    color: actionMouse.containsMouse
        ? destructive
            ? Qt.rgba(1, 0.35, 0.32, 0.18)
            : root.luminaDesign.color.accentContainer
        : root.luminaDesign.color.surfaceMuted
    border.width: destructive ? 1 : 0
    border.color: root.luminaDesign.color.urgent
    scale: actionMouse.pressed ? 0.97 : 1.0

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

    Text {
        anchors {
            left: parent.left
            leftMargin: root.luminaDesign.spacing.large
            verticalCenter: parent.verticalCenter
        }

        text: root.symbol
        color: root.destructive
            ? root.luminaDesign.color.urgent
            : actionMouse.containsMouse
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.primary
        font.pixelSize: 26
        font.weight: Font.DemiBold
    }

    Column {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 54
            rightMargin: root.luminaDesign.spacing.medium
            verticalCenter: parent.verticalCenter
        }

        spacing: 2

        Text {
            width: parent.width
            text: root.title
            color: actionMouse.containsMouse && !root.destructive
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.bodyMedium
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: root.description
            color: root.luminaDesign.color.textMuted
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.labelSmall
        }
    }

    MouseArea {
        id: actionMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}

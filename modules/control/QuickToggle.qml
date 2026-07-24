pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    required property string title
    required property string detail
    required property string symbol
    property bool checked: false
    property bool available: true

    signal toggled

    readonly property var luminaDesign: Theme.luminaTokens

    implicitHeight: 68
    radius: checked
        ? luminaDesign.shape.extraLarge
        : luminaDesign.shape.large
    color: checked
        ? luminaDesign.color.accentContainer
        : luminaDesign.color.surfaceMuted
    opacity: available ? 1 : 0.5
    scale: toggleMouse.pressed ? 0.97 : 1

    Accessible.role: Accessible.CheckBox
    Accessible.name: title
    Accessible.description: detail
    Accessible.checked: checked

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.medium
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.fast
        }
    }

    Row {
        anchors {
            fill: parent
            margins: root.luminaDesign.spacing.large
        }

        spacing: root.luminaDesign.spacing.medium

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            text: root.symbol
            color: root.checked
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.primary
            font.pixelSize: 20
            font.weight: Font.DemiBold
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 40
            spacing: 1

            Text {
                width: parent.width
                text: root.title
                color: root.checked
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.onSurface
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.bodyMedium
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: root.detail
                color: root.luminaDesign.color.textMuted
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.labelSmall
            }
        }
    }

    MouseArea {
        id: toggleMouse

        anchors.fill: parent
        enabled: root.available
        hoverEnabled: true
        cursorShape: root.available
            ? Qt.PointingHandCursor
            : Qt.ForbiddenCursor
        onClicked: root.toggled()
    }
}

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
    activeFocusOnTab: true
    radius: root.luminaDesign.shape.large
    color: actionMouse.containsMouse
        ? destructive
            ? root.luminaDesign.color.errorContainer
            : root.luminaDesign.color.accentContainer
        : root.luminaDesign.color.surfaceMuted
    border.width: activeFocus ? 2 : destructive ? 1 : 0
    border.color: activeFocus
        ? root.luminaDesign.color.primary
        : root.luminaDesign.color.urgent
    scale: actionMouse.pressed ? 0.97 : 1.0

    Accessible.role: Accessible.Button
    Accessible.name: title
    Accessible.description: description
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activated()

    Keys.onSpacePressed: event => {
        root.activated()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.activated()
        event.accepted = true
    }

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
            ? actionMouse.containsMouse
                ? root.luminaDesign.color.onErrorContainer
                : root.luminaDesign.color.urgent
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
            color: actionMouse.containsMouse
                ? root.destructive
                    ? root.luminaDesign.color.onErrorContainer
                    : root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.bodyMedium
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: root.description
            color: actionMouse.containsMouse && root.destructive
                ? root.luminaDesign.color.onErrorContainer
                : root.luminaDesign.color.textMuted
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.labelSmall
        }
    }

    MouseArea {
        id: actionMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            root.activated()
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control

Rectangle {
    id: root

    required property string title
    required property string description
    property string iconName: ""
    property string fallbackSymbol: ""
    property bool destructive: false

    signal activated

    function mixColors(baseColor, tintColor, tintAmount) {
        const amount = Math.max(0, Math.min(1, Number(tintAmount)))
        return Qt.rgba(
            baseColor.r + (tintColor.r - baseColor.r) * amount,
            baseColor.g + (tintColor.g - baseColor.g) * amount,
            baseColor.b + (tintColor.b - baseColor.b) * amount,
            1
        )
    }

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property color destructiveBackgroundColor: mixColors(
        luminaDesign.color.surfaceMuted,
        luminaDesign.color.errorContainer,
        0.34
    )
    readonly property color destructiveHoverColor: mixColors(
        luminaDesign.color.surfaceMuted,
        luminaDesign.color.errorContainer,
        0.54
    )
    readonly property color destructiveBorderColor: Qt.rgba(
        luminaDesign.color.urgent.r,
        luminaDesign.color.urgent.g,
        luminaDesign.color.urgent.b,
        actionMouse.containsMouse ? 0.84 : 0.62
    )

    implicitHeight: 82
    activeFocusOnTab: true
    radius: root.luminaDesign.shape.large
    color: destructive
        ? actionMouse.containsMouse
            ? root.destructiveHoverColor
            : root.destructiveBackgroundColor
        : actionMouse.containsMouse
            ? root.luminaDesign.color.accentContainer
            : root.luminaDesign.color.surfaceMuted
    border.width: activeFocus ? 2 : destructive ? 1 : 0
    border.color: activeFocus
        ? root.luminaDesign.color.primary
        : root.destructiveBorderColor
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

    Rectangle {
        id: iconContainer

        anchors {
            left: parent.left
            leftMargin: root.luminaDesign.spacing.large
            verticalCenter: parent.verticalCenter
        }
        width: 38
        height: 38
        radius: root.luminaDesign.shape.full
        color: root.destructive
            ? actionMouse.containsMouse
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.errorContainer
            : actionMouse.containsMouse
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.accentContainer

        DashboardIcon {
            anchors.centerIn: parent
            iconName: root.iconName
            fallbackSymbol: root.fallbackSymbol
            iconColor: root.destructive
                ? actionMouse.containsMouse
                    ? root.luminaDesign.color.surfaceBase
                    : root.luminaDesign.color.onErrorContainer
                : actionMouse.containsMouse
                    ? root.luminaDesign.color.surfaceBase
                    : root.luminaDesign.color.onAccentContainer
            iconSize: 19
        }
    }

    Column {
        anchors {
            left: iconContainer.right
            right: parent.right
            leftMargin: root.luminaDesign.spacing.medium
            rightMargin: root.luminaDesign.spacing.medium
            verticalCenter: parent.verticalCenter
        }

        spacing: 2

        Text {
            width: parent.width
            text: root.title
            color: !root.destructive && actionMouse.containsMouse
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
        onClicked: {
            root.focus = false
            root.activated()
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control

Rectangle {
    id: root

    required property string label
    required property string description
    required property string iconName
    property string symbol: ""
    property bool selected: false
    property bool compact: false

    signal activated

    readonly property var luminaDesign: Theme.luminaTokens

    implicitHeight: compact ? 44 : 50
    radius: selected
        ? luminaDesign.shape.extraLarge
        : luminaDesign.shape.large
    color: selected
        ? luminaDesign.color.accentContainer
        : navigationMouse.pressed
            ? Qt.lighter(luminaDesign.color.surfaceMuted, 1.12)
            : navigationMouse.containsMouse || activeFocus
                ? luminaDesign.color.surfaceMuted
                : "transparent"
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.PageTab
    Accessible.name: label
    Accessible.description: description
    Accessible.selected: selected
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
            margins: root.luminaDesign.spacing.medium
        }

        spacing: root.luminaDesign.spacing.medium

        DashboardIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            iconName: root.iconName
            fallbackSymbol: root.symbol
            iconColor: root.selected
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.primary
            iconSize: 18
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.compact
            width: parent.width - 40
            spacing: 1

            Text {
                width: parent.width
                text: root.label
                color: root.selected
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.onSurface
                elide: Text.ElideRight
                font.pixelSize:
                    root.luminaDesign.typography.bodyMedium
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: root.description
                color: root.selected
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.textMuted
                opacity: 0.76
                elide: Text.ElideRight
                font.pixelSize:
                    root.luminaDesign.typography.labelSmall
            }
        }
    }

    MouseArea {
        id: navigationMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            root.activated()
        }
    }
}

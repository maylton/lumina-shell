pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    required property string title
    required property string detail
    property string iconName: ""
    property string symbol: ""
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
    activeFocusOnTab: available
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.CheckBox
    Accessible.name: title
    Accessible.description: detail
    Accessible.checked: checked
    Accessible.focusable: available
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.toggled()

    Keys.onSpacePressed: event => {
        root.toggled()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.toggled()
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
            margins: root.luminaDesign.spacing.large
        }

        spacing: root.luminaDesign.spacing.medium

        DashboardIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 22
            iconName: root.iconName
            fallbackSymbol: root.symbol
            iconColor: root.checked
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.primary
            iconSize: 18
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
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            root.toggled()
        }
    }
}

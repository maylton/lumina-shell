pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control

Rectangle {
    id: root

    property string title: ""
    property string description: ""
    property string iconName: "network-wireless-symbolic"
    property string fallbackSymbol: "◉"
    property string actionLabel: ""
    property bool connected: false
    property bool available: true
    property bool busy: false

    signal activated()

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool hasAction: actionLabel.length > 0
    readonly property bool actionable: available && !busy && hasAction

    implicitHeight: 64
    radius: luminaDesign.shape.large
    color: rowMouse.containsMouse
        ? luminaDesign.color.surfaceMuted
        : connected
            ? luminaDesign.color.accentContainer
            : luminaDesign.color.surfaceContainerHigh
    opacity: available ? 1 : 0.5
    activeFocusOnTab: actionable
    border.width: activeFocus ? 2 : connected ? 1 : 0
    border.color: activeFocus
        ? luminaDesign.color.primary
        : luminaDesign.color.outlineVariant

    Accessible.role: hasAction ? Accessible.Button : Accessible.StaticText
    Accessible.name: title
    Accessible.description: description
    Accessible.focusable: actionable
    Accessible.focused: activeFocus
    Accessible.onPressAction: {
        if (root.actionable)
            root.activated()
    }

    Keys.onSpacePressed: event => {
        if (root.actionable)
            root.activated()
        event.accepted = true
    }
    Keys.onReturnPressed: event => {
        if (root.actionable)
            root.activated()
        event.accepted = true
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        z: 0
        hoverEnabled: true
        enabled: root.actionable
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            root.focus = false
            root.activated()
        }
    }

    Row {
        z: 1
        anchors {
            fill: parent
            leftMargin: root.luminaDesign.spacing.medium
            rightMargin: root.luminaDesign.spacing.medium
        }
        spacing: root.luminaDesign.spacing.medium

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40
            radius: root.luminaDesign.shape.full
            color: root.connected
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.surfaceMuted

            DashboardIcon {
                anchors.centerIn: parent
                iconName: root.iconName
                fallbackSymbol: root.fallbackSymbol
                iconColor: root.connected
                    ? root.luminaDesign.color.onPrimary
                    : root.luminaDesign.color.onSurface
                iconSize: 20
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 40 - actionButton.width
                - parent.spacing * (root.hasAction ? 2 : 1)
            spacing: 2

            Text {
                width: parent.width
                text: root.title
                color: root.connected
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

        Rectangle {
            id: actionButton

            anchors.verticalCenter: parent.verticalCenter
            visible: root.hasAction
            width: visible ? Math.max(94, actionText.implicitWidth + 24) : 0
            height: 36
            radius: root.luminaDesign.shape.full
            color: root.actionable
                ? actionMouse.containsMouse
                    ? root.luminaDesign.color.primary
                    : root.luminaDesign.color.surfaceMuted
                : "transparent"
            border.width: root.actionable ? 1 : 0
            border.color: root.luminaDesign.color.outline

            Text {
                id: actionText
                anchors.centerIn: parent
                text: root.busy ? "…" : root.actionLabel
                color: actionMouse.containsMouse && root.actionable
                    ? root.luminaDesign.color.onPrimary
                    : root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.labelMedium
                font.weight: Font.DemiBold
            }

            MouseArea {
                id: actionMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.actionable
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    root.focus = false
                    root.activated()
                }
            }
        }
    }
}

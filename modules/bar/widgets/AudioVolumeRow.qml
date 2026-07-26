pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.i18n

Rectangle {
    id: root

    required property var node
    required property string title
    property string subtitle: ""
    property string iconName: "audio-card-symbolic"
    property string fallbackSymbol: "♪"
    property bool selected: false
    property bool selectable: false

    signal selectedRequested()
    signal volumeRequested(real value)
    signal muteRequested()

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool available:
        node !== null && node.ready && node.audio !== null
    readonly property real volume: available
        ? Math.max(0, Math.min(1, Number(node.audio.volume) || 0))
        : 0
    readonly property bool muted: available
        ? Boolean(node.audio.muted)
        : false
    readonly property string percentage:
        Math.round(volume * 100) + "%"

    implicitHeight: 96
    radius: luminaDesign.shape.large
    color: selected
        ? luminaDesign.color.accentContainer
        : rowMouse.containsMouse
            ? luminaDesign.color.surfaceMuted
            : luminaDesign.color.surfaceBase
    opacity: available ? 1 : 0.5
    activeFocusOnTab: available
    border.width: activeFocus || selected ? 2 : 1
    border.color: activeFocus || selected
        ? luminaDesign.color.primary
        : luminaDesign.color.outline

    Accessible.role: Accessible.Slider
    Accessible.name: title
    Accessible.description: subtitle + ". " + percentage
        + (muted
            ? ". " + I18n.tr("bar.audio.muted", "Muted")
            : "")
    Accessible.focusable: available
    Accessible.focused: activeFocus
    Accessible.onIncreaseAction: root.adjustBy(0.05)
    Accessible.onDecreaseAction: root.adjustBy(-0.05)
    Accessible.onPressAction: {
        if (root.selectable)
            root.selectedRequested()
    }

    function adjustBy(delta) {
        if (!available)
            return

        volumeRequested(Math.max(
            0,
            Math.min(1, volume + Number(delta || 0))
        ))
    }

    Keys.onLeftPressed: event => {
        root.adjustBy(-0.05)
        event.accepted = true
    }

    Keys.onRightPressed: event => {
        root.adjustBy(0.05)
        event.accepted = true
    }

    Keys.onSpacePressed: event => {
        if (root.selectable)
            root.selectedRequested()
        else
            root.muteRequested()

        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        if (root.selectable)
            root.selectedRequested()
        else
            root.muteRequested()

        event.accepted = true
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Row {
        id: headerRow

        z: 1
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: root.luminaDesign.spacing.medium
            rightMargin: root.luminaDesign.spacing.medium
            topMargin: root.luminaDesign.spacing.small
        }
        height: 48
        spacing: root.luminaDesign.spacing.medium

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 38
            height: 38
            radius: root.luminaDesign.shape.full
            color: root.selected
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.surfaceMuted

            DashboardIcon {
                anchors.centerIn: parent
                iconName: root.iconName
                fallbackSymbol: root.fallbackSymbol
                iconColor: root.selected
                    ? root.luminaDesign.color.surfaceBase
                    : root.luminaDesign.color.onSurface
                iconSize: 18
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(
                80,
                parent.width
                    - 38
                    - muteButton.width
                    - (defaultPill.visible ? defaultPill.width : 0)
                    - parent.spacing * (defaultPill.visible ? 3 : 2)
            )
            spacing: 2

            Text {
                width: parent.width
                text: root.title
                color: root.luminaDesign.color.onSurface
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.bodyMedium
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: root.subtitle
                visible: text.length > 0
                color: root.luminaDesign.color.textMuted
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.labelSmall
            }
        }

        Rectangle {
            id: defaultPill

            anchors.verticalCenter: parent.verticalCenter
            visible: root.selected
            width: defaultLabel.implicitWidth + 18
            height: 26
            radius: root.luminaDesign.shape.full
            color: root.luminaDesign.color.primary

            Text {
                id: defaultLabel

                anchors.centerIn: parent
                text: I18n.tr("bar.audio.default", "Default")
                color: root.luminaDesign.color.surfaceBase
                font.pixelSize: root.luminaDesign.typography.labelSmall
                font.weight: Font.Bold
            }
        }

        Rectangle {
            id: muteButton

            anchors.verticalCenter: parent.verticalCenter
            width: 38
            height: 38
            radius: root.luminaDesign.shape.full
            color: muteMouse.containsMouse || activeFocus
                ? root.luminaDesign.color.accentContainer
                : root.muted
                    ? root.luminaDesign.color.errorContainer
                    : root.luminaDesign.color.surfaceMuted
            activeFocusOnTab: root.available
            border.width: activeFocus ? 2 : 0
            border.color: root.luminaDesign.color.primary

            Accessible.role: Accessible.Button
            Accessible.name: root.muted
                ? I18n.tr("bar.audio.unmute", "Unmute")
                : I18n.tr("bar.audio.mute", "Mute")
            Accessible.focusable: root.available
            Accessible.focused: activeFocus
            Accessible.onPressAction: root.muteRequested()

            Keys.onSpacePressed: event => {
                root.muteRequested()
                event.accepted = true
            }

            Keys.onReturnPressed: event => {
                root.muteRequested()
                event.accepted = true
            }

            DashboardIcon {
                anchors.centerIn: parent
                iconName: root.muted
                    ? "audio-volume-muted-symbolic"
                    : "audio-volume-high-symbolic"
                fallbackSymbol: root.muted ? "×" : "♪"
                iconColor: root.muted
                    ? root.luminaDesign.color.onErrorContainer
                    : root.luminaDesign.color.onSurface
                iconSize: 17
            }

            MouseArea {
                id: muteMouse

                anchors.fill: parent
                hoverEnabled: true
                enabled: root.available
                cursorShape: enabled
                    ? Qt.PointingHandCursor
                    : Qt.ArrowCursor
                onClicked: {
                    muteButton.focus = false
                    root.muteRequested()
                }
            }
        }
    }

    Text {
        anchors {
            right: parent.right
            rightMargin: root.luminaDesign.spacing.medium
            bottom: parent.bottom
            bottomMargin: 8
        }
        text: root.percentage
        color: root.muted
            ? root.luminaDesign.color.urgent
            : root.luminaDesign.color.textMuted
        font.pixelSize: root.luminaDesign.typography.labelSmall
        font.weight: Font.DemiBold
    }

    MaterialSlider {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: root.luminaDesign.spacing.medium
            rightMargin: root.luminaDesign.spacing.medium + 46
            bottom: parent.bottom
            bottomMargin: 8
        }
        height: implicitHeight
        value: root.volume
        available: root.available
        activeColor: root.muted
            ? root.luminaDesign.color.outline
            : root.luminaDesign.color.primary
        handleColor: activeColor
        onInteractionStarted:
            root.forceActiveFocus(Qt.MouseFocusReason)
        onValueRequested: value => root.volumeRequested(value)
    }

    MouseArea {
        id: rowMouse

        z: 0
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: headerRow.height + root.luminaDesign.spacing.small * 2
        enabled: root.available && root.selectable
        hoverEnabled: true
        cursorShape: enabled
            ? Qt.PointingHandCursor
            : Qt.ArrowCursor
        onClicked: {
            root.focus = false
            root.selectedRequested()
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    required property string title
    property string iconName: ""
    property string symbol: ""
    property string detail: ""
    property real value: 0
    property bool available: true

    signal valueRequested(real value)

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real clampedValue: Math.max(
        0,
        Math.min(1, Number(value) || 0)
    )

    function requestAt(position) {
        if (!available)
            return

        const nextValue = Math.max(
            0,
            Math.min(1, Number(position) / sliderTrack.width)
        )

        valueRequested(nextValue)
    }

    implicitHeight: 72
    radius: luminaDesign.shape.large
    color: luminaDesign.color.surfaceMuted
    opacity: available ? 1 : 0.55
    activeFocusOnTab: available
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Slider
    Accessible.name: title
    Accessible.description: detail
    Accessible.focusable: available
    Accessible.focused: activeFocus
    Accessible.onIncreaseAction:
        root.valueRequested(Math.min(1, root.clampedValue + 0.05))
    Accessible.onDecreaseAction:
        root.valueRequested(Math.max(0, root.clampedValue - 0.05))

    Keys.onLeftPressed: event => {
        root.valueRequested(Math.max(0, root.clampedValue - 0.05))
        event.accepted = true
    }

    Keys.onRightPressed: event => {
        root.valueRequested(Math.min(1, root.clampedValue + 0.05))
        event.accepted = true
    }

    Row {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: root.luminaDesign.spacing.large
        }

        DashboardIcon {
            width: 28
            height: 18
            iconName: root.iconName
            fallbackSymbol: root.symbol
            iconColor: root.available
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.textMuted
            iconSize: 16
        }

        Text {
            width: parent.width - 88
            text: root.title
            color: root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.bodyMedium
            font.weight: Font.DemiBold
        }

        Text {
            width: 60
            horizontalAlignment: Text.AlignRight
            text: root.detail
            color: root.luminaDesign.color.textMuted
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.labelSmall
        }
    }

    Rectangle {
        id: sliderTrack

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: root.luminaDesign.spacing.large
            rightMargin: root.luminaDesign.spacing.large
            bottom: parent.bottom
            bottomMargin: root.luminaDesign.spacing.medium
        }

        height: 10
        radius: 5
        color: root.luminaDesign.color.surfaceContainer
        clip: true

        Rectangle {
            width: parent.width * root.clampedValue
            height: parent.height
            radius: parent.radius
            color: root.available
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.outline

            Behavior on width {
                NumberAnimation {
                    duration:
                        root.luminaDesign.motion.spatialFast
                    easing.type:
                        root.luminaDesign.motion.spatialEasing
                    easing.overshoot:
                        root.luminaDesign.motion.spatialOvershoot
                }
            }
        }

        MouseArea {
            anchors {
                fill: parent
                topMargin: -8
                bottomMargin: -8
            }

            enabled: root.available
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => {
                root.forceActiveFocus(Qt.MouseFocusReason)
                root.requestAt(mouse.x)
            }
            onPositionChanged: mouse => {
                if (pressed)
                    root.requestAt(mouse.x)
            }
        }
    }
}

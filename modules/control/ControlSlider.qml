pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import "SliderGeometry.js" as Geometry

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
    readonly property var sliderTokens: luminaDesign.slider
    readonly property real clampedValue: Math.max(
        0,
        Math.min(1, Number(value) || 0)
    )

    function requestAt(position) {
        if (!available)
            return

        const nextValue = Geometry.progressFromPosition(
            sliderTrack.width,
            sliderTokens.handleWidth,
            position
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
            leftMargin: root.luminaDesign.spacing.large
            rightMargin: root.luminaDesign.spacing.large
            topMargin: root.luminaDesign.spacing.small
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

    Item {
        id: sliderTrack

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: root.luminaDesign.spacing.large
            rightMargin: root.luminaDesign.spacing.large
            bottom: parent.bottom
            bottomMargin: root.luminaDesign.spacing.small
        }

        height: root.sliderTokens.handleHeight

        SliderTrackSegment {
            anchors.verticalCenter: parent.verticalCenter
            width: Geometry.activeWidth(
                sliderTrack.width,
                sliderHandle.width,
                root.sliderTokens.handleGap,
                root.clampedValue
            )
            height: root.sliderTokens.trackHeight
            outerAtStart: true
            insideRadius: root.sliderTokens.trackInsideRadius
            segmentColor: root.available
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.outline
            visible: width > 0

            Behavior on width {
                NumberAnimation {
                    duration: root.luminaDesign.motion.effectsFast
                    easing.type: root.luminaDesign.motion.effectsEasing
                }
            }
        }

        SliderTrackSegment {
            id: inactiveTrack

            anchors.verticalCenter: parent.verticalCenter
            x: Geometry.inactiveX(
                sliderTrack.width,
                sliderHandle.width,
                root.sliderTokens.handleGap,
                root.clampedValue
            )
            width: Geometry.inactiveWidth(
                sliderTrack.width,
                sliderHandle.width,
                root.sliderTokens.handleGap,
                root.clampedValue
            )
            height: root.sliderTokens.trackHeight
            outerAtStart: false
            insideRadius: root.sliderTokens.trackInsideRadius
            segmentColor: root.luminaDesign.color.surfaceContainer
            visible: width > 0

            Behavior on x {
                NumberAnimation {
                    duration: root.luminaDesign.motion.effectsFast
                    easing.type: root.luminaDesign.motion.effectsEasing
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: root.luminaDesign.motion.effectsFast
                    easing.type: root.luminaDesign.motion.effectsEasing
                }
            }
        }

        Rectangle {
            id: stopIndicator

            readonly property real endCenter:
                sliderTrack.width - root.sliderTokens.trackHeight / 2

            width: root.sliderTokens.stopSize
            height: width
            radius: root.luminaDesign.shape.full
            x: endCenter - width / 2
            anchors.verticalCenter: parent.verticalCenter
            color: root.available
                ? root.luminaDesign.color.onSurface
                : root.luminaDesign.color.textMuted
            opacity: 0.62
            visible: inactiveTrack.width
                >= root.sliderTokens.trackHeight
        }

        Rectangle {
            id: handleStateLayer

            width: root.sliderTokens.stateLayerSize
            height: width
            radius: root.luminaDesign.shape.full
            x: sliderHandle.x
                + sliderHandle.width / 2
                - width / 2
            anchors.verticalCenter: parent.verticalCenter
            color: root.luminaDesign.color.primary
            opacity: sliderPointer.pressed
                ? 0.16
                : sliderPointer.containsMouse || root.activeFocus
                    ? 0.1
                    : 0

            Behavior on x {
                NumberAnimation {
                    duration: root.luminaDesign.motion.effectsFast
                    easing.type: root.luminaDesign.motion.effectsEasing
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: root.luminaDesign.motion.effectsFast
                    easing.type: root.luminaDesign.motion.effectsEasing
                }
            }
        }

        Rectangle {
            id: sliderHandle

            width: root.sliderTokens.handleWidth
            height: root.sliderTokens.handleHeight
            radius: root.luminaDesign.shape.full
            x: Geometry.handleX(
                sliderTrack.width,
                width,
                root.clampedValue
            )
            anchors.verticalCenter: parent.verticalCenter
            color: root.available
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.outline

            Behavior on x {
                NumberAnimation {
                    duration: root.luminaDesign.motion.effectsFast
                    easing.type: root.luminaDesign.motion.effectsEasing
                }
            }
        }

        MouseArea {
            id: sliderPointer

            anchors {
                fill: parent
                topMargin: -4
                bottomMargin: -4
            }

            enabled: root.available
            hoverEnabled: true
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

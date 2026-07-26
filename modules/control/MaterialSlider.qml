pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import "SliderGeometry.js" as Geometry

Item {
    id: root

    property real value: 0
    property bool available: true
    property color activeColor: available
        ? luminaDesign.color.primary
        : luminaDesign.color.outline
    property color inactiveColor: luminaDesign.color.surfaceBase
    property color handleColor: activeColor

    signal valueRequested(real value)
    signal interactionStarted

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var sliderTokens: luminaDesign.slider
    readonly property real clampedValue: Math.max(
        0,
        Math.min(1, Number(value) || 0)
    )

    implicitHeight: sliderTokens.handleHeight

    function requestAt(position) {
        if (!available)
            return

        valueRequested(Geometry.progressFromPosition(
            width,
            sliderTokens.handleWidth,
            position
        ))
    }

    SliderTrackSegment {
        id: activeTrack

        anchors.verticalCenter: parent.verticalCenter
        width: Geometry.activeWidth(
            root.width,
            handle.width,
            root.sliderTokens.handleGap,
            root.clampedValue
        )
        height: root.sliderTokens.trackHeight
        outerAtStart: true
        insideRadius: root.sliderTokens.trackInsideRadius
        segmentColor: root.activeColor
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
            root.width,
            handle.width,
            root.sliderTokens.handleGap,
            root.clampedValue
        )
        width: Geometry.inactiveWidth(
            root.width,
            handle.width,
            root.sliderTokens.handleGap,
            root.clampedValue
        )
        height: root.sliderTokens.trackHeight
        outerAtStart: false
        insideRadius: root.sliderTokens.trackInsideRadius
        segmentColor: root.inactiveColor
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
        id: handle

        width: root.sliderTokens.handleWidth
        height: root.sliderTokens.handleHeight
        radius: root.luminaDesign.shape.full
        x: Geometry.handleX(
            root.width,
            width,
            root.clampedValue
        )
        anchors.verticalCenter: parent.verticalCenter
        color: root.handleColor
        antialiasing: true

        Behavior on x {
            NumberAnimation {
                duration: root.luminaDesign.motion.effectsFast
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }
    }

    MouseArea {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: Math.max(36, root.height)
        enabled: root.available
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        cursorShape: root.available
            ? Qt.PointingHandCursor
            : Qt.ArrowCursor

        onPressed: mouse => {
            root.interactionStarted()
            root.requestAt(mouse.x)
        }

        onPositionChanged: mouse => {
            if (pressed)
                root.requestAt(mouse.x)
        }
    }
}

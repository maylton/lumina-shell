pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.stores.config
import "WavyProgressGeometry.js" as Geometry

Item {
    id: root

    property real progress: 0
    property bool wavy: true
    property bool moving: false
    property color indicatorColor:
        luminaDesign.color.primary
    property color trackColor:
        luminaDesign.color.surfaceMuted

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var progressTokens:
        luminaDesign.progress
    readonly property real clampedProgress:
        Geometry.normalizedProgress(progress)
    property real renderedProgress: clampedProgress
    property real renderedAmplitude:
        wavy ? progressTokens.waveAmplitude : 0
    property real phase: 0

    implicitHeight: progressTokens.waveHeight

    Accessible.role: Accessible.ProgressBar
    Accessible.name: "Media progress"
    Accessible.description:
        Math.round(clampedProgress * 100) + " percent"

    onRenderedProgressChanged: progressCanvas.requestPaint()
    onRenderedAmplitudeChanged: progressCanvas.requestPaint()
    onPhaseChanged: progressCanvas.requestPaint()
    onIndicatorColorChanged: progressCanvas.requestPaint()
    onTrackColorChanged: progressCanvas.requestPaint()

    Behavior on renderedProgress {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialDefault
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on renderedAmplitude {
        NumberAnimation {
            duration: root.luminaDesign.motion.mediaProgressMorph
            easing.type: root.luminaDesign.motion.continuousEasing
        }
    }

    NumberAnimation on phase {
        from: 0
        to: root.progressTokens.waveLength
        duration: root.luminaDesign.motion.mediaWaveCycle
        loops: Animation.Infinite
        running: root.moving
            && ConfigStore.animationsEnabled
            && !ConfigStore.reduceMotion
    }

    Canvas {
        id: progressCanvas

        anchors.fill: parent
        antialiasing: true

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const context = getContext("2d")
            const strokeWidth = root.progressTokens.trackThickness
            const centerY = height / 2
            const startX = Geometry.contentStart(strokeWidth)
            const endX = Geometry.contentEnd(width, strokeWidth)
            const activeEnd = Geometry.activeEnd(
                width,
                strokeWidth,
                root.renderedProgress
            )
            const trackStart = Geometry.trackStart(
                width,
                strokeWidth,
                root.renderedProgress,
                root.progressTokens.trackGap
            )
            const stopIndicator = Geometry.stopIndicator(
                width,
                strokeWidth,
                root.progressTokens.stopSize,
                root.renderedProgress
            )
            const stopRadius = stopIndicator.size / 2

            context.clearRect(0, 0, width, height)
            context.lineCap = "round"
            context.lineJoin = "round"
            context.lineWidth = strokeWidth

            if (trackStart < endX) {
                context.beginPath()
                context.moveTo(trackStart, centerY)
                context.lineTo(endX, centerY)
                context.strokeStyle = root.trackColor
                context.stroke()
            }

            if (stopRadius > 0) {
                context.beginPath()
                context.arc(
                    stopIndicator.center,
                    centerY,
                    stopRadius,
                    0,
                    Math.PI * 2
                )
                context.fillStyle = root.indicatorColor
                context.fill()
            }

            if (activeEnd <= startX)
                return

            context.beginPath()
            context.moveTo(
                startX,
                Geometry.waveY(
                    startX,
                    centerY,
                    root.renderedAmplitude,
                    root.progressTokens.waveLength,
                    root.phase
                )
            )

            for (var x = startX + 1; x < activeEnd; x += 1) {
                context.lineTo(
                    x,
                    Geometry.waveY(
                        x,
                        centerY,
                        root.renderedAmplitude,
                        root.progressTokens.waveLength,
                        root.phase
                    )
                )
            }

            context.lineTo(
                activeEnd,
                Geometry.waveY(
                    activeEnd,
                    centerY,
                    root.renderedAmplitude,
                    root.progressTokens.waveLength,
                    root.phase
                )
            )
            context.strokeStyle = root.indicatorColor
            context.stroke()
        }
    }
}

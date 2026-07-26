pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Item {
    id: root

    property bool running: false
    property real progress: -1
    property color indicatorColor: luminaDesign.color.primary
    property real indicatorSize: 18

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property int shapeCount: 7
    readonly property real visualProgress: progress >= 0
        ? Math.max(0, Math.min(shapeCount, progress))
        : animatedProgress

    property real animatedProgress: 0
    property real spin: 0

    implicitWidth: indicatorSize
    implicitHeight: indicatorSize

    function shapeRadius(shapeIndex, angle) {
        switch (shapeIndex % shapeCount) {
        case 0:
            return 0.88 + 0.12 * Math.cos(4 * angle)
        case 1:
            return 1.0
        case 2:
            return 0.84 + 0.16 * Math.cos(3 * angle)
        case 3:
            return 0.82 + 0.18 * Math.cos(5 * angle)
        case 4:
            return 0.86 + 0.14 * Math.cos(6 * angle)
        case 5:
            return 0.84
                + 0.11 * Math.cos(4 * angle + Math.PI / 4)
                + 0.05 * Math.cos(2 * angle)
        default:
            return 0.89 + 0.11 * Math.cos(8 * angle)
        }
    }

    function eased(value) {
        const clamped = Math.max(0, Math.min(1, value))
        return clamped * clamped * (3 - 2 * clamped)
    }

    function resetAnimation() {
        animatedProgress = 0
        spin = 0
        indicator.requestPaint()
    }

    onRunningChanged: {
        if (!running)
            resetAnimation()
    }
    onVisualProgressChanged: indicator.requestPaint()
    onIndicatorColorChanged: indicator.requestPaint()
    onIndicatorSizeChanged: indicator.requestPaint()

    NumberAnimation {
        target: root
        property: "animatedProgress"
        from: 0
        to: root.shapeCount
        duration: 2100
        loops: Animation.Infinite
        running: root.running && root.progress < 0
        easing.type: Easing.Linear
    }

    NumberAnimation {
        target: root
        property: "spin"
        from: 0
        to: 360
        duration: 1750
        loops: Animation.Infinite
        running: root.running && root.progress < 0
        easing.type: Easing.Linear
    }

    Canvas {
        id: indicator

        anchors.centerIn: parent
        width: root.indicatorSize
        height: root.indicatorSize
        rotation: root.progress < 0 ? root.spin : 0

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const context = getContext("2d")
            context.clearRect(0, 0, width, height)

            const count = 20
            const progressValue = root.visualProgress
            const baseIndex = Math.floor(progressValue) % root.shapeCount
            const nextIndex = (baseIndex + 1) % root.shapeCount
            const fraction = root.eased(progressValue - Math.floor(progressValue))
            const centerX = width / 2
            const centerY = height / 2
            const scale = Math.min(width, height) * 0.44
            const points = []

            for (let index = 0; index < count; ++index) {
                const angle = -Math.PI / 2 + index * Math.PI * 2 / count
                const firstRadius = root.shapeRadius(baseIndex, angle)
                const secondRadius = root.shapeRadius(nextIndex, angle)
                const radius = firstRadius
                    + (secondRadius - firstRadius) * fraction
                points.push({
                    x: centerX + Math.cos(angle) * scale * radius,
                    y: centerY + Math.sin(angle) * scale * radius
                })
            }

            const firstPoint = points[0]
            const lastPoint = points[points.length - 1]
            context.beginPath()
            context.moveTo(
                (lastPoint.x + firstPoint.x) / 2,
                (lastPoint.y + firstPoint.y) / 2
            )

            for (let index = 0; index < points.length; ++index) {
                const point = points[index]
                const nextPoint = points[(index + 1) % points.length]
                context.quadraticCurveTo(
                    point.x,
                    point.y,
                    (point.x + nextPoint.x) / 2,
                    (point.y + nextPoint.y) / 2
                )
            }

            context.closePath()
            context.fillStyle = root.indicatorColor
            context.fill()
        }
    }
}

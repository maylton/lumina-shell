import QtQuick
import qs.design

Canvas {
    id: root

    property var history: []
    property color lineColor: luminaDesign.color.primary
    property color pointFillColor: luminaDesign.color.surfaceLow

    readonly property var luminaDesign: Theme.luminaTokens

    antialiasing: true
    renderStrategy: Canvas.Cooperative

    onHistoryChanged: requestPaint()
    onLineColorChanged: requestPaint()
    onPointFillColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    function colorWithAlpha(colorValue, alphaValue) {
        return Qt.rgba(
            colorValue.r,
            colorValue.g,
            colorValue.b,
            alphaValue
        ).toString()
    }

    onPaint: {
        const context = getContext("2d")
        const values = root.history || []
        const count = values.length

        context.clearRect(0, 0, width, height)

        if (count < 2 || width <= 0 || height <= 0)
            return

        const padding = 10
        const drawHeight = Math.max(1, height - padding * 2)
        const stepX = width / (count - 1)
        const gradient = context.createLinearGradient(
            0,
            0,
            0,
            height
        )

        gradient.addColorStop(
            0,
            root.colorWithAlpha(root.lineColor, 0.42)
        )
        gradient.addColorStop(
            1,
            root.colorWithAlpha(root.lineColor, 0)
        )

        context.beginPath()
        context.moveTo(0, height)

        for (var index = 0; index < count; ++index) {
            const value = Math.max(
                0,
                Math.min(100, Number(values[index]) || 0)
            )
            const x = index * stepX
            const y = padding
                + drawHeight
                - value / 100 * drawHeight
            context.lineTo(x, y)
        }

        context.lineTo(width, height)
        context.closePath()
        context.fillStyle = gradient
        context.fill()

        context.beginPath()

        for (var lineIndex = 0; lineIndex < count; ++lineIndex) {
            const lineValue = Math.max(
                0,
                Math.min(100, Number(values[lineIndex]) || 0)
            )
            const lineX = lineIndex * stepX
            const lineY = padding
                + drawHeight
                - lineValue / 100 * drawHeight

            if (lineIndex === 0)
                context.moveTo(lineX, lineY)
            else
                context.lineTo(lineX, lineY)
        }

        context.strokeStyle = root.lineColor.toString()
        context.lineWidth = 4
        context.lineCap = "round"
        context.lineJoin = "round"
        context.stroke()

        const lastValue = Math.max(
            0,
            Math.min(100, Number(values[count - 1]) || 0)
        )
        const lastY = padding
            + drawHeight
            - lastValue / 100 * drawHeight

        context.beginPath()
        context.arc(width - 3, lastY, 6, 0, Math.PI * 2)
        context.fillStyle = root.pointFillColor.toString()
        context.fill()
        context.strokeStyle = root.lineColor.toString()
        context.lineWidth = 3
        context.stroke()
    }
}

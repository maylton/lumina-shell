.pragma library

function clamp(value, minimum, maximum) {
    return Math.max(minimum, Math.min(maximum, Number(value || 0)))
}

function normalizedProgress(value) {
    return clamp(value, 0, 1)
}

function contentStart(strokeWidth) {
    return Math.max(0, Number(strokeWidth || 0) / 2)
}

function contentEnd(width, strokeWidth) {
    return Math.max(
        contentStart(strokeWidth),
        Number(width || 0) - contentStart(strokeWidth)
    )
}

function activeEnd(width, strokeWidth, progress) {
    const start = contentStart(strokeWidth)
    const end = contentEnd(width, strokeWidth)

    return start + (end - start) * normalizedProgress(progress)
}

function trackStart(width, strokeWidth, progress, gapSize) {
    return Math.min(
        contentEnd(width, strokeWidth),
        activeEnd(width, strokeWidth, progress)
            + Math.max(0, Number(gapSize || 0))
    )
}

function stopIndicator(width, strokeWidth, maximumSize, progress) {
    var size = Math.min(
        Math.max(0, Number(strokeWidth || 0)),
        Math.max(0, Number(maximumSize || 0))
    )
    var start = Math.max(0, Number(width || 0) - size)
    const progressX = Number(width || 0) * normalizedProgress(progress)
        + contentStart(strokeWidth)

    if (start <= progressX) {
        size = Math.max(0, size - (progressX - start))
        start = progressX
    }

    return {
        size: size,
        center: start + size / 2
    }
}

function waveY(x, centerY, amplitude, wavelength, phase) {
    const safeWavelength = Math.max(1, Number(wavelength || 0))
    const angle = (
        (Number(x || 0) + Number(phase || 0))
        / safeWavelength
    ) * Math.PI * 2

    return Number(centerY || 0)
        + Math.sin(angle) * Math.max(0, Number(amplitude || 0))
}

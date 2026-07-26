.pragma library

function clampProgress(progress) {
    return Math.max(0, Math.min(1, Number(progress) || 0))
}

function normalizedValue(value, from, to) {
    const range = Math.max(0.001, to - from)

    return clampProgress((value - from) / range)
}

function handleX(width, handleWidth, progress) {
    const availableWidth = Math.max(0, width - handleWidth)

    return availableWidth * clampProgress(progress)
}

function activeWidth(width, handleWidth, gap, progress) {
    return Math.max(
        0,
        handleX(width, handleWidth, progress) - gap
    )
}

function inactiveX(width, handleWidth, gap, progress) {
    return Math.min(
        width,
        handleX(width, handleWidth, progress)
            + handleWidth
            + gap
    )
}

function inactiveWidth(width, handleWidth, gap, progress) {
    return Math.max(
        0,
        width - inactiveX(width, handleWidth, gap, progress)
    )
}

function progressFromPosition(width, handleWidth, position) {
    const availableWidth = Math.max(1, width - handleWidth)
    const handleCenter = Math.max(
        handleWidth / 2,
        Math.min(width - handleWidth / 2, Number(position) || 0)
    )

    return clampProgress((handleCenter - handleWidth / 2) / availableWidth)
}

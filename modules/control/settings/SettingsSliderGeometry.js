.pragma library

function normalizedValue(value, from, to) {
    const range = Math.max(0.001, to - from)

    return Math.max(0, Math.min(1, (value - from) / range))
}

function handleX(width, handleWidth, progress) {
    const availableWidth = Math.max(0, width - handleWidth)

    return availableWidth * Math.max(0, Math.min(1, progress))
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

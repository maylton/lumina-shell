.pragma library

function initialIndex(currentIndex, optionCount) {
    if (optionCount <= 0)
        return -1

    return currentIndex >= 0 && currentIndex < optionCount
        ? currentIndex
        : 0
}

function offsetIndex(currentIndex, offset, optionCount) {
    if (optionCount <= 0)
        return -1

    const base = initialIndex(currentIndex, optionCount)

    return (
        base + offset % optionCount + optionCount
    ) % optionCount
}

function popupY(
    belowY,
    aboveY,
    menuHeight,
    viewportHeight,
    inset
) {
    if (belowY + menuHeight <= viewportHeight - inset)
        return belowY

    return Math.max(inset, aboveY)
}

.pragma library

function profile(width) {
    var availableWidth = Math.max(0, Number(width) || 0)

    return {
        wide: availableWidth >= 1440,
        compact: availableWidth < 1280,
        narrow: availableWidth < 960,
        veryNarrow: availableWidth < 760
    }
}

function centerAvailableWidth(
    totalWidth,
    leftExtent,
    rightExtent,
    sideGap
) {
    var width = Math.max(0, Number(totalWidth) || 0)
    var left = Math.max(0, Number(leftExtent) || 0)
    var right = Math.max(0, Number(rightExtent) || 0)
    var gap = Math.max(0, Number(sideGap) || 0)
    var clearance = Math.max(
        0,
        Math.min(width / 2 - left, width / 2 - right)
    )

    return Math.max(0, clearance * 2 - gap * 2)
}

function loadedWidgetVisible(active, item) {
    if (!Boolean(active))
        return false

    if (!item || item.layoutAvailable === undefined)
        return true

    return Boolean(item.layoutAvailable)
}

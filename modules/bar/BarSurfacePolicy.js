.pragma library

function clampOpacity(value) {
    var opacity = Number(value)

    if (!isFinite(opacity))
        opacity = 1

    return Math.max(0, Math.min(1, opacity))
}

function backgroundAlpha(mode, opacity) {
    if (mode === "transparent")
        return 0

    if (mode === "translucent")
        return clampOpacity(opacity)

    return 1
}

function dividerAlpha(mode, opacity) {
    if (mode === "transparent")
        return 0

    if (mode === "translucent")
        return 0.24 * clampOpacity(opacity)

    return 0.24
}

function borderAlpha(mode, opacity) {
    if (mode === "transparent")
        return 0

    if (mode === "translucent")
        return 0.42 * clampOpacity(opacity)

    return 1
}

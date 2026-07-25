.pragma library

var BACKGROUND_MODES = [
    "solid",
    "translucent",
    "blur",
    "frosted",
    "transparent"
]

function clampOpacity(value) {
    var opacity = Number(value)

    if (!isFinite(opacity))
        opacity = 1

    return Math.max(0, Math.min(1, opacity))
}

function normalizeMode(mode) {
    var requested = String(mode || "")

    return BACKGROUND_MODES.indexOf(requested) >= 0
        ? requested
        : "solid"
}

function requestsBackdropBlur(mode) {
    var normalized = normalizeMode(mode)

    return normalized === "blur"
        || normalized === "frosted"
}

function fallbackMode(mode, blurAvailable) {
    var normalized = normalizeMode(mode)

    if (!blurAvailable && requestsBackdropBlur(normalized))
        return "translucent"

    return normalized
}

function nonNegative(value, fallback) {
    var numeric = Number(value)

    if (!isFinite(numeric))
        numeric = Number(fallback) || 0

    return Math.max(0, numeric)
}

function blurRegionGeometry(
    width,
    height,
    surfaceMode,
    outerMargin,
    surfaceRadius
) {
    var floating = String(surfaceMode) === "floating"
    var margin = floating ? nonNegative(outerMargin, 0) : 0
    var surfaceWidth = nonNegative(width, 0)
    var surfaceHeight = nonNegative(height, 0)

    return {
        x: margin,
        y: margin,
        width: Math.max(0, surfaceWidth - margin * 2),
        height: Math.max(0, surfaceHeight - margin * 2),
        radius: floating
            ? nonNegative(surfaceRadius, 0)
            : 0
    }
}

function backgroundAlpha(mode, opacity) {
    var normalized = normalizeMode(mode)

    if (normalized === "transparent")
        return 0

    if (normalized === "blur"
        || normalized === "frosted"
        || normalized === "translucent")
        return clampOpacity(opacity)

    return 1
}

function dividerAlpha(mode, opacity) {
    var normalized = normalizeMode(mode)

    if (normalized === "transparent")
        return 0

    if (normalized === "blur" || normalized === "translucent")
        return 0.24 * clampOpacity(opacity)

    if (normalized === "frosted")
        return 0.12 + 0.18 * clampOpacity(opacity)

    return 0.24
}

function borderAlpha(mode, opacity) {
    var normalized = normalizeMode(mode)

    if (normalized === "transparent")
        return 0

    if (normalized === "blur" || normalized === "translucent")
        return 0.42 * clampOpacity(opacity)

    if (normalized === "frosted")
        return 0.28 + 0.36 * clampOpacity(opacity)

    return 1
}

function showsFrostedHighlight(mode) {
    return normalizeMode(mode) === "frosted"
}

function showsFrostedGrain(mode) {
    return normalizeMode(mode) === "frosted"
}

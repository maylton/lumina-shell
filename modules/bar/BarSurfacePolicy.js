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
    var configured = clampOpacity(opacity)

    if (normalized === "transparent"
        || normalized === "blur"
        || normalized === "frosted") {
        return 0
    }

    if (normalized === "translucent")
        return Math.max(0.28, configured)

    return 1
}

function tintAlpha(mode, opacity, lightMode) {
    var normalized = normalizeMode(mode)
    var configured = clampOpacity(opacity)

    if (normalized === "blur") {
        return lightMode
            ? 0.18 + 0.24 * configured
            : 0.24 + 0.22 * configured
    }

    if (normalized === "frosted") {
        return lightMode
            ? 0.30 + 0.24 * configured
            : 0.34 + 0.24 * configured
    }

    return 0
}

function contrastProtectionAlpha(mode, opacity, lightMode) {
    var normalized = normalizeMode(mode)
    var configured = clampOpacity(opacity)

    if (normalized === "blur") {
        return lightMode
            ? 0.04 + 0.04 * configured
            : 0.08 + 0.06 * configured
    }

    if (normalized === "frosted") {
        return lightMode
            ? 0.05 + 0.04 * configured
            : 0.09 + 0.06 * configured
    }

    return 0
}

function fallbackAlpha(mode, opacity, lightMode) {
    var normalized = normalizeMode(mode)
    var configured = clampOpacity(opacity)

    if (normalized === "solid")
        return 1

    if (normalized === "transparent")
        return 0

    if (normalized === "translucent")
        return backgroundAlpha(normalized, configured)

    if (normalized === "blur") {
        return lightMode
            ? 0.62 + 0.22 * configured
            : 0.66 + 0.22 * configured
    }

    return lightMode
        ? 0.68 + 0.20 * configured
        : 0.72 + 0.18 * configured
}

function dividerAlpha(mode, opacity) {
    var normalized = normalizeMode(mode)
    var configured = clampOpacity(opacity)

    if (normalized === "transparent")
        return 0

    if (normalized === "translucent")
        return 0.16 + 0.12 * configured

    if (normalized === "blur")
        return 0.10 + 0.10 * configured

    if (normalized === "frosted")
        return 0.18 + 0.16 * configured

    return 0.24
}

function borderAlpha(mode, opacity) {
    var normalized = normalizeMode(mode)
    var configured = clampOpacity(opacity)

    if (normalized === "transparent")
        return 0

    if (normalized === "translucent")
        return 0.25 + 0.25 * configured

    if (normalized === "blur")
        return 0.20 + 0.20 * configured

    if (normalized === "frosted")
        return 0.32 + 0.28 * configured

    return 0.72
}

function showsFrostedHighlight(mode) {
    return normalizeMode(mode) === "frosted"
}

function showsFrostedGrain(mode) {
    return normalizeMode(mode) === "frosted"
}

function frostedHighlightAlpha(mode, opacity, lightMode) {
    if (!showsFrostedHighlight(mode))
        return 0

    var configured = clampOpacity(opacity)

    return lightMode
        ? 0.035 + 0.025 * configured
        : 0.045 + 0.035 * configured
}

function frostedGrainAlpha(mode, opacity, lightMode) {
    if (!showsFrostedGrain(mode))
        return 0

    var configured = clampOpacity(opacity)

    return lightMode
        ? 0.018 + 0.014 * configured
        : 0.025 + 0.018 * configured
}

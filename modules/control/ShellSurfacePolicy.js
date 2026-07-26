.pragma library

var MINIMUM_OPACITY = 0.55
var MAXIMUM_OPACITY = 0.95

function clamp(value, minimum, maximum) {
    var numeric = Number(value)

    if (!isFinite(numeric))
        numeric = minimum

    return Math.max(minimum, Math.min(maximum, numeric))
}

function normalizeMode(mode) {
    var requested = String(mode || "")

    return ["solid", "blur", "frosted"].indexOf(requested) >= 0
        ? requested
        : "solid"
}

function configuredOpacity(value) {
    return clamp(value, MINIMUM_OPACITY, MAXIMUM_OPACITY)
}

function requestsBackdropBlur(mode) {
    var normalized = normalizeMode(mode)
    return normalized === "blur" || normalized === "frosted"
}

function baseAlpha(mode) {
    return normalizeMode(mode) === "solid" ? 1 : 0
}

function tintAlpha(mode, opacity, lightMode) {
    var normalized = normalizeMode(mode)
    var level = configuredOpacity(opacity)

    if (normalized === "blur")
        return clamp(level * (lightMode ? 0.78 : 0.68), 0.48, 0.76)

    if (normalized === "frosted")
        return clamp(level * (lightMode ? 0.88 : 0.80), 0.55, 0.84)

    return 0
}

function contrastProtectionAlpha(mode, lightMode) {
    var normalized = normalizeMode(mode)

    if (normalized === "blur")
        return lightMode ? 0.12 : 0.10

    if (normalized === "frosted")
        return lightMode ? 0.14 : 0.12

    return 0
}

function highlightAlpha(mode, lightMode) {
    return normalizeMode(mode) === "frosted"
        ? lightMode ? 0.10 : 0.07
        : 0
}

function grainAlpha(mode, lightMode) {
    return normalizeMode(mode) === "frosted"
        ? lightMode ? 0.016 : 0.012
        : 0
}

function borderAlpha(mode) {
    var normalized = normalizeMode(mode)

    if (normalized === "frosted")
        return 0.56

    if (normalized === "blur")
        return 0.36

    return 0.42
}

function renderedCompositeAlpha(mode, opacity, lightMode) {
    var normalized = normalizeMode(mode)

    if (!requestsBackdropBlur(normalized))
        return baseAlpha(normalized)

    var tint = tintAlpha(normalized, opacity, lightMode)
    var protection = contrastProtectionAlpha(normalized, lightMode)
    return 1 - (1 - tint) * (1 - protection)
}

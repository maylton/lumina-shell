.pragma library

var REFERENCE_HEIGHT = 56
var MINIMUM_HEIGHT = 40
var MAXIMUM_HEIGHT = 80
var MINIMUM_MANUAL_SCALE = 0.8
var MAXIMUM_MANUAL_SCALE = 1.4
var COMPACT_FACTOR = 0.94

function clamp(value, minimum, maximum) {
    var numeric = Number(value)

    if (!isFinite(numeric))
        numeric = minimum

    return Math.max(minimum, Math.min(maximum, numeric))
}

function contentScale(height, automatic, manualScale) {
    if (automatic) {
        return clamp(
            Number(height),
            MINIMUM_HEIGHT,
            MAXIMUM_HEIGHT
        ) / REFERENCE_HEIGHT
    }

    return clamp(
        manualScale,
        MINIMUM_MANUAL_SCALE,
        MAXIMUM_MANUAL_SCALE
    )
}

function effectiveScale(height, automatic, manualScale, compact) {
    var scale = contentScale(height, automatic, manualScale)

    if (compact)
        scale *= COMPACT_FACTOR

    return clamp(scale, 0.65, 1.45)
}

function scaled(baseValue, scale, minimum, maximum) {
    var base = Number(baseValue)

    if (!isFinite(base))
        base = 0

    return Math.round(
        clamp(base * Number(scale), minimum, maximum)
    )
}

.pragma library

function clamp(value, minimum, maximum) {
    var numeric = Number(value)

    if (!isFinite(numeric))
        numeric = minimum

    return Math.max(minimum, Math.min(maximum, numeric))
}

function contentScale(height, automatic, manualScale) {
    if (automatic)
        return clamp(Number(height) / 56, 0.8, 1.4)

    return clamp(manualScale, 0.8, 1.4)
}

function effectiveScale(height, automatic, manualScale, compact) {
    var scale = contentScale(height, automatic, manualScale)

    if (compact)
        scale *= 0.94

    return clamp(scale, 0.8, 1.4)
}

function moderatedScale(scale, influence) {
    var safeScale = clamp(scale, 0.8, 1.4)
    var safeInfluence = clamp(influence, 0, 1)

    return 1 + ((safeScale - 1) * safeInfluence)
}

function scaled(baseValue, scale, minimum, maximum) {
    var base = Number(baseValue)

    if (!isFinite(base))
        base = 0

    return Math.round(
        clamp(base * Number(scale), minimum, maximum)
    )
}

.pragma library

var NEAR_WIDGET = "near-widget"
var CENTERED = "centered"

function finiteNumber(value, fallback) {
    var numeric = Number(value)
    return isFinite(numeric) ? numeric : Number(fallback || 0)
}

function clamp(value, minimum, maximum) {
    var lower = finiteNumber(minimum, 0)
    var upper = Math.max(lower, finiteNumber(maximum, lower))
    return Math.max(lower, Math.min(upper, finiteNumber(value, lower)))
}

function normalize(value, fallback) {
    var requested = String(value || "")

    if (requested === NEAR_WIDGET || requested === CENTERED)
        return requested

    return String(fallback || "") === NEAR_WIDGET
        ? NEAR_WIDGET
        : CENTERED
}

function hasAnchorGeometry(anchorTop, anchorBottom) {
    var top = Number(anchorTop)
    var bottom = Number(anchorBottom)

    return isFinite(top)
        && isFinite(bottom)
        && top >= 0
        && bottom >= top
}

function barWindowHeight(barHeight, surfaceMode, margin) {
    return Math.max(
        0,
        finiteNumber(barHeight, 0)
            + (String(surfaceMode) === "floating"
                ? finiteNumber(margin, 0)
                : 0)
    )
}

function horizontalX(
    placement,
    anchorX,
    surfaceWidth,
    viewportWidth,
    margin
) {
    var width = Math.max(0, finiteNumber(surfaceWidth, 0))
    var viewport = Math.max(width, finiteNumber(viewportWidth, width))
    var inset = Math.max(0, finiteNumber(margin, 0))
    var maximum = Math.max(inset, viewport - width - inset)
    var centered = (viewport - width) / 2

    if (normalize(placement) !== NEAR_WIDGET
        || !isFinite(Number(anchorX))
        || Number(anchorX) < 0) {
        return clamp(centered, inset, maximum)
    }

    return clamp(Number(anchorX) - width / 2, inset, maximum)
}

function verticalY(
    _placement,
    barPosition,
    surfaceHeight,
    viewportHeight,
    barHeight,
    gap,
    margin,
    anchorTop,
    anchorBottom
) {
    var height = Math.max(0, finiteNumber(surfaceHeight, 0))
    var viewport = Math.max(height, finiteNumber(viewportHeight, height))
    var inset = Math.max(0, finiteNumber(margin, 0))
    var maximum = Math.max(inset, viewport - height - inset)
    var adjacentGap = Math.max(0, finiteNumber(gap, 0))
    var adjacent

    if (hasAnchorGeometry(anchorTop, anchorBottom)) {
        adjacent = String(barPosition) === "bottom"
            ? Number(anchorTop) - adjacentGap - height
            : Number(anchorBottom) + adjacentGap
    } else {
        adjacent = String(barPosition) === "bottom"
            ? viewport
                - Math.max(0, finiteNumber(barHeight, 0))
                - adjacentGap
                - height
            : Math.max(0, finiteNumber(barHeight, 0))
                + adjacentGap
    }

    return clamp(adjacent, inset, maximum)
}

.pragma library

function finiteNumber(value, fallback) {
    var number = Number(value)
    return isFinite(number) ? number : Number(fallback || 0)
}

function clamp(value, minimum, maximum) {
    return Math.max(
        finiteNumber(minimum, 0),
        Math.min(
            finiteNumber(maximum, 100),
            finiteNumber(value, 0)
        )
    )
}

function percentage(used, total) {
    var safeTotal = finiteNumber(total, 0)

    if (safeTotal <= 0)
        return 0

    return clamp(finiteNumber(used, 0) / safeTotal * 100, 0, 100)
}

function cpuUsage(previousTotal, previousIdle, total, idle) {
    var totalDelta = finiteNumber(total, 0)
        - finiteNumber(previousTotal, 0)
    var idleDelta = finiteNumber(idle, 0)
        - finiteNumber(previousIdle, 0)

    if (totalDelta <= 0)
        return 0

    return clamp((totalDelta - idleDelta) / totalDelta * 100, 0, 100)
}

function transferRate(previousBytes, bytes, elapsedMilliseconds) {
    var elapsed = finiteNumber(elapsedMilliseconds, 0)

    if (elapsed <= 0)
        return 0

    var delta = Math.max(
        0,
        finiteNumber(bytes, 0) - finiteNumber(previousBytes, 0)
    )
    return delta / (elapsed / 1000)
}

function appendHistory(history, value, maximumSize) {
    var source = history
        && typeof history.length === "number"
        ? history
        : []
    var maximum = Math.max(1, Math.round(
        finiteNumber(maximumSize, 40)
    ))
    var result = []
    var start = Math.max(0, source.length - maximum + 1)

    for (var index = start; index < source.length; ++index)
        result.push(clamp(source[index], 0, 100))

    result.push(clamp(value, 0, 100))
    return result
}

function initialHistory(size) {
    var count = Math.max(1, Math.round(finiteNumber(size, 40)))
    var result = []

    for (var index = 0; index < count; ++index)
        result.push(0)

    return result
}

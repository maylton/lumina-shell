.pragma library

function list(value) {
    if (!value
        || typeof value === "string"
        || typeof value.length !== "number")
        return []

    var result = []

    for (var index = 0; index < value.length; ++index)
        result.push(String(value[index]))

    return result
}

function uniqueKnown(value, allowed) {
    var input = list(value)
    var valid = list(allowed)
    var result = []

    for (var index = 0; index < input.length; ++index) {
        var id = input[index]

        if (valid.indexOf(id) >= 0 && result.indexOf(id) < 0)
            result.push(id)
    }

    return result
}

function activeOrder(order, activeIds) {
    var active = list(activeIds)
    var result = []

    list(order).forEach(function(id) {
        if (active.indexOf(id) >= 0 && result.indexOf(id) < 0)
            result.push(id)
    })

    return result
}

function removedIds(allowed, activeIds) {
    var active = list(activeIds)
    return list(allowed).filter(function(id) {
        return active.indexOf(id) < 0
    })
}

function moveActive(order, activeIds, widgetId, offset) {
    var result = list(order)
    var active = activeOrder(result, activeIds)
    var requested = String(widgetId || "")
    var activeIndex = active.indexOf(requested)
    var delta = Number(offset || 0)
    var targetActiveIndex = Math.max(
        0,
        Math.min(active.length - 1, activeIndex + delta)
    )

    if (activeIndex < 0 || activeIndex === targetActiveIndex)
        return result

    var otherId = active[targetActiveIndex]
    var currentIndex = result.indexOf(requested)
    var targetIndex = result.indexOf(otherId)

    if (currentIndex < 0 || targetIndex < 0)
        return result

    result[currentIndex] = otherId
    result[targetIndex] = requested
    return result
}

function addAtEnd(order, widgetId, allowed) {
    var valid = list(allowed)
    var requested = String(widgetId || "")
    var result = uniqueKnown(order, valid).filter(function(id) {
        return id !== requested
    })

    if (valid.indexOf(requested) >= 0)
        result.push(requested)

    return result
}

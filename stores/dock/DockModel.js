.pragma library

function normalizeIdentifier(value) {
    var result = String(value || "").trim().toLowerCase()

    if (result.slice(-8) === ".desktop")
        result = result.slice(0, -8)

    return result
}

function groupWindows(windows) {
    var source = Array.isArray(windows) ? windows : []
    var groups = {}
    var order = []

    for (var index = 0; index < source.length; ++index) {
        var windowItem = source[index] || {}
        var rawAppId = String(windowItem.app_id || "").trim()
        var key = normalizeIdentifier(rawAppId)

        if (!key)
            continue

        if (!groups[key]) {
            groups[key] = {
                key: key,
                appId: rawAppId,
                windowIds: [],
                focused: false,
                urgent: false
            }
            order.push(key)
        }

        groups[key].windowIds.push(windowItem.id)
        groups[key].focused = groups[key].focused
            || Boolean(windowItem.is_focused)
        groups[key].urgent = groups[key].urgent
            || Boolean(windowItem.is_urgent)
    }

    var result = []
    for (var orderIndex = 0; orderIndex < order.length; ++orderIndex)
        result.push(groups[order[orderIndex]])

    return result
}

function nextWindowId(windowIds, focusedWindowId) {
    var ids = Array.isArray(windowIds) ? windowIds : []

    if (ids.length === 0)
        return null

    var currentIndex = ids.indexOf(focusedWindowId)
    return currentIndex >= 0
        ? ids[(currentIndex + 1) % ids.length]
        : ids[0]
}

function uniqueIdentifiers(values) {
    var source = Array.isArray(values) ? values : []
    var result = []

    for (var index = 0; index < source.length; ++index) {
        var value = String(source[index] || "").trim()

        if (!value || result.indexOf(value) >= 0)
            continue

        result.push(value)
    }

    return result
}

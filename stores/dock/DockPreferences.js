.pragma library

var CURRENT_VERSION = 1

function defaults() {
    return {
        schemaVersion: CURRENT_VERSION,
        enabled: false,
        autoHide: true,
        showRunning: true,
        reserveSpace: false,
        iconSize: 50,
        margin: 10,
        favoriteAppIds: []
    }
}

function booleanValue(value, fallback) {
    return typeof value === "boolean" ? value : fallback
}

function boundedNumber(value, fallback, minimum, maximum) {
    var numeric = Number(value)

    if (!isFinite(numeric))
        numeric = fallback

    return Math.max(minimum, Math.min(maximum, numeric))
}

function normalizeIdentifier(value) {
    return String(value || "").trim()
}

function normalizeFavorites(value) {
    var input = Array.isArray(value) ? value : []
    var result = []

    for (var index = 0; index < input.length; ++index) {
        var identifier = normalizeIdentifier(input[index])

        if (!identifier || result.indexOf(identifier) >= 0)
            continue

        result.push(identifier)

        if (result.length >= 24)
            break
    }

    return result
}

function normalize(source) {
    var input = source && typeof source === "object" ? source : {}
    var base = defaults()

    return {
        schemaVersion: CURRENT_VERSION,
        enabled: booleanValue(input.enabled, base.enabled),
        autoHide: booleanValue(input.autoHide, base.autoHide),
        showRunning: booleanValue(input.showRunning, base.showRunning),
        reserveSpace: booleanValue(input.reserveSpace, base.reserveSpace),
        iconSize: Math.round(
            boundedNumber(input.iconSize, base.iconSize, 36, 72)
        ),
        margin: Math.round(
            boundedNumber(input.margin, base.margin, 0, 24)
        ),
        favoriteAppIds: normalizeFavorites(input.favoriteAppIds)
    }
}

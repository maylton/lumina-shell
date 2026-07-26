.pragma library

var CURRENT_VERSION = 2

function defaults() {
    return {
        schemaVersion: CURRENT_VERSION,
        enabled: false,
        mode: "floating",
        autoHide: true,
        showRunning: true,
        reserveSpace: false,
        iconSize: 36,
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

function choice(value, allowed, fallback) {
    var requested = String(value || "")
    return allowed.indexOf(requested) >= 0 ? requested : fallback
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

function normalizedIconSize(input, fallback) {
    var schemaVersion = Number(input.schemaVersion)
    var requested = Number(input.iconSize)

    // Version 1 used 50 px as its generated default. Move only that legacy
    // default to the new 36 px baseline; preserve every customized value.
    if ((!isFinite(schemaVersion) || schemaVersion < 2) && requested === 50)
        return fallback

    return Math.round(
        boundedNumber(input.iconSize, fallback, 30, 72)
    )
}

function normalize(source) {
    var input = source && typeof source === "object" ? source : {}
    var base = defaults()

    return {
        schemaVersion: CURRENT_VERSION,
        enabled: booleanValue(input.enabled, base.enabled),
        mode: choice(
            input.mode,
            ["floating", "task-panel"],
            base.mode
        ),
        autoHide: booleanValue(input.autoHide, base.autoHide),
        showRunning: booleanValue(input.showRunning, base.showRunning),
        reserveSpace: booleanValue(input.reserveSpace, base.reserveSpace),
        iconSize: normalizedIconSize(input, base.iconSize),
        margin: Math.round(
            boundedNumber(input.margin, base.margin, 0, 24)
        ),
        favoriteAppIds: normalizeFavorites(input.favoriteAppIds)
    }
}

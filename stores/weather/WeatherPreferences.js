.pragma library

var CURRENT_VERSION = 1

function defaults() {
    return {
        schemaVersion: CURRENT_VERSION,
        locationMode: "automatic-ip",
        manualCity: "",
        refreshInterval: 30
    }
}

function normalize(source) {
    const input = source && typeof source === "object" ? source : {}
    const base = defaults()
    const mode = String(input.locationMode || "")
    const interval = Number(input.refreshInterval)
    const allowedIntervals = [15, 30, 60, 120]

    return {
        schemaVersion: CURRENT_VERSION,
        locationMode: ["automatic-ip", "manual"].indexOf(mode) >= 0
            ? mode
            : base.locationMode,
        manualCity: String(input.manualCity || "").trim().slice(0, 120),
        refreshInterval: allowedIntervals.indexOf(interval) >= 0
            ? interval
            : base.refreshInterval
    }
}

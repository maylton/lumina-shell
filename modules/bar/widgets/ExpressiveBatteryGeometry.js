.pragma library

function clampPercentage(value) {
    const numberValue = Number(value)

    if (!isFinite(numberValue))
        return 0

    return Math.max(0, Math.min(100, numberValue))
}

function fillWidth(trackWidth, percentage, minimumWidth) {
    const availableWidth = Math.max(0, Number(trackWidth) || 0)
    const level = clampPercentage(percentage)

    if (availableWidth <= 0 || level <= 0)
        return 0

    return Math.min(
        availableWidth,
        Math.max(
            Math.max(0, Number(minimumWidth) || 0),
            availableWidth * level / 100
        )
    )
}

function isLowBattery(percentage, charging) {
    return !charging
        && clampPercentage(percentage) <= 20
}

function isChargingState(state) {
    const normalized = String(state || "")
        .trim()
        .toLowerCase()
        .replace(/[_-]+/g, " ")

    return normalized === "charging"
        || normalized === "pending charge"
        || normalized === "pendingcharge"
}

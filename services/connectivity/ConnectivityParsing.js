.pragma library

function splitEscaped(line, separator) {
    const value = String(line || "")
    const delimiter = String(separator || ":")
    const result = []
    let current = ""
    let escaped = false

    for (let index = 0; index < value.length; ++index) {
        const character = value[index]

        if (escaped) {
            current += character
            escaped = false
        } else if (character === "\\") {
            escaped = true
        } else if (character === delimiter) {
            result.push(current)
            current = ""
        } else {
            current += character
        }
    }

    if (escaped)
        current += "\\"

    result.push(current)
    return result
}

function lines(text) {
    return String(text || "")
        .split(/\r?\n/)
        .map(function(line) { return line.trim() })
        .filter(function(line) { return line.length > 0 })
}

function parseWifiNetworks(text) {
    const strongest = {}
    const input = lines(text)

    for (let index = 0; index < input.length; ++index) {
        const fields = splitEscaped(input[index], ":")
        const ssid = String(fields[1] || "").trim()

        if (!ssid)
            continue

        const entry = {
            active: String(fields[0] || "") === "*",
            ssid: ssid,
            signal: Math.max(0, Math.min(100, Number(fields[2]) || 0)),
            security: String(fields[3] || "").trim(),
            bars: String(fields[4] || "").trim()
        }

        if (!strongest[ssid]
            || entry.active
            || entry.signal > strongest[ssid].signal) {
            strongest[ssid] = entry
        }
    }

    return Object.keys(strongest)
        .map(function(key) { return strongest[key] })
        .sort(function(left, right) {
            if (left.active !== right.active)
                return left.active ? -1 : 1
            return right.signal - left.signal
        })
}

function parseConnections(text) {
    return lines(text).map(function(line) {
        const fields = splitEscaped(line, ":")
        return {
            name: String(fields[0] || ""),
            uuid: String(fields[1] || ""),
            type: String(fields[2] || ""),
            device: String(fields[3] || ""),
            autoconnect: String(fields[4] || "").toLowerCase() === "yes",
            active: String(fields[3] || "").length > 0
                && String(fields[3] || "") !== "--"
        }
    }).filter(function(entry) {
        return entry.name.length > 0 && entry.uuid.length > 0
    })
}

function parseDevices(text) {
    return lines(text).map(function(line) {
        const fields = splitEscaped(line, ":")
        return {
            device: String(fields[0] || ""),
            type: String(fields[1] || ""),
            state: String(fields[2] || ""),
            connection: String(fields[3] || ""),
            connected: String(fields[2] || "").toLowerCase() === "connected"
        }
    }).filter(function(entry) {
        return entry.device.length > 0
    })
}

function parseBluetoothDevices(text) {
    return lines(text).map(function(line) {
        const match = line.match(/^Device\s+([0-9A-Fa-f:]{17})\s+(.+)$/)
        return match
            ? { address: match[1].toUpperCase(), name: match[2].trim() }
            : null
    }).filter(function(entry) { return entry !== null })
}

function addressSet(text) {
    const result = {}
    const devices = parseBluetoothDevices(text)

    for (let index = 0; index < devices.length; ++index)
        result[devices[index].address] = true

    return result
}

function mergeBluetoothDevices(allText, pairedText, connectedText) {
    const devices = parseBluetoothDevices(allText)
    const paired = addressSet(pairedText)
    const connected = addressSet(connectedText)

    return devices.map(function(device) {
        return {
            address: device.address,
            name: device.name,
            paired: Boolean(paired[device.address]),
            connected: Boolean(connected[device.address])
        }
    }).sort(function(left, right) {
        if (left.connected !== right.connected)
            return left.connected ? -1 : 1
        if (left.paired !== right.paired)
            return left.paired ? -1 : 1
        return left.name.localeCompare(right.name)
    })
}

.pragma library

var OUTPUT_DEVICE = "output-device"
var INPUT_DEVICE = "input-device"
var PLAYBACK_STREAM = "playback-stream"
var CAPTURE_STREAM = "capture-stream"
var UNKNOWN = "unknown"

function properties(node) {
    return node && node.properties && typeof node.properties === "object"
        ? node.properties
        : {}
}

function propertyValue(node, keys) {
    var values = properties(node)
    var requested = Array.isArray(keys) ? keys : [keys]

    for (var index = 0; index < requested.length; ++index) {
        var value = String(values[String(requested[index])] || "").trim()

        if (value)
            return value
    }

    return ""
}

function mediaClass(node) {
    return propertyValue(node, "media.class")
}

function kind(node) {
    switch (mediaClass(node)) {
    case "Audio/Sink":
        return OUTPUT_DEVICE
    case "Audio/Source":
        return INPUT_DEVICE
    case "Stream/Output/Audio":
        return PLAYBACK_STREAM
    case "Stream/Input/Audio":
        return CAPTURE_STREAM
    default:
        return UNKNOWN
    }
}

function isOutputDevice(node) {
    return kind(node) === OUTPUT_DEVICE
}

function isInputDevice(node) {
    return kind(node) === INPUT_DEVICE
}

function isPlaybackStream(node) {
    return kind(node) === PLAYBACK_STREAM
}

function isCaptureStream(node) {
    return kind(node) === CAPTURE_STREAM
}

function isApplicationStream(node) {
    return isPlaybackStream(node) || isCaptureStream(node)
}

function firstText(values) {
    for (var index = 0; index < values.length; ++index) {
        var value = String(values[index] || "").trim()

        if (value)
            return value
    }

    return ""
}

function label(node) {
    var stream = isApplicationStream(node)
    var applicationName = propertyValue(node, [
        "application.name",
        "application.process.binary"
    ])
    var nodeDescription = node
        ? firstText([node.description, node.nickname])
        : ""
    var mediaName = propertyValue(node, "media.name")
    var nodeName = node ? String(node.name || "").trim() : ""

    return stream
        ? firstText([
            applicationName,
            nodeDescription,
            mediaName,
            nodeName,
            "Application"
        ])
        : firstText([
            nodeDescription,
            mediaName,
            nodeName,
            "Audio device"
        ])
}

function detail(node) {
    var mediaName = propertyValue(node, "media.name")
    var applicationName = propertyValue(node, "application.name")
    var nodeDescription = node
        ? firstText([node.description, node.nickname])
        : ""
    var primary = label(node)

    return firstText([
        mediaName !== primary ? mediaName : "",
        applicationName !== primary ? applicationName : "",
        nodeDescription !== primary ? nodeDescription : ""
    ])
}

function iconName(node) {
    var applicationIcon = propertyValue(node, [
        "application.icon-name",
        "application.icon_name"
    ])

    if (applicationIcon)
        return applicationIcon
    if (isInputDevice(node) || isCaptureStream(node))
        return "audio-input-microphone-symbolic"
    if (isOutputDevice(node))
        return "audio-speakers-symbolic"
    if (isPlaybackStream(node))
        return "audio-volume-high-symbolic"

    return "audio-card-symbolic"
}

.pragma library

function busctlValue(rawText) {
    var text = String(rawText || "").trim()
    var firstQuote = text.indexOf("\"")

    if (firstQuote < 0)
        return ""

    var quoted = text.slice(firstQuote)

    try {
        return String(JSON.parse(quoted))
    } catch (error) {
        var lastQuote = quoted.lastIndexOf("\"")

        return lastQuote > 0
            ? quoted.slice(1, lastQuote)
            : ""
    }
}

function initials(displayName, fallbackName) {
    var name = String(displayName || fallbackName || "").trim()

    if (!name)
        return ""

    var words = name.split(/\s+/)
    var result = words[0].charAt(0)

    if (words.length > 1)
        result += words[words.length - 1].charAt(0)

    return result.toLocaleUpperCase()
}

function avatarCandidates(accountIconPath, homeDirectory, customPath) {
    return uniquePaths([
        accountIconPath,
        homeDirectory ? homeDirectory + "/.face" : "",
        homeDirectory ? homeDirectory + "/.face.icon" : "",
        customPath
    ])
}

function uniquePaths(values) {
    var result = []

    for (var index = 0; index < values.length; ++index) {
        var value = String(values[index] || "").trim()

        if (value && result.indexOf(value) < 0)
            result.push(value)
    }

    return result
}

function sourceUrl(path) {
    var value = String(path || "").trim()

    if (!value)
        return ""

    if (/^[a-z][a-z0-9+.-]*:/i.test(value))
        return value

    return "file://" + encodeURI(value)
}

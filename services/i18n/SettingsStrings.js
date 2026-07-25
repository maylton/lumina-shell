.pragma library

var ENGLISH = {
    restart: "Restart",
    restartRequired: "Restart required"
}

var PORTUGUESE = {
    restart: "Reiniciar",
    restartRequired: "Reinicialização necessária"
}

function strings(locale) {
    var normalized = String(locale || "").toLowerCase()
    return normalized.indexOf("pt") === 0 ? PORTUGUESE : ENGLISH
}

function text(locale, key) {
    var values = strings(locale)
    return values[key] || ENGLISH[key] || String(key || "")
}

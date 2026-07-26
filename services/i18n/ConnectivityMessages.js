.pragma library

var MESSAGES = {
    "en-US": {
        "settings.connectivity.wired.state.connected": "Connected",
        "settings.connectivity.wired.state.connecting": "Connecting",
        "settings.connectivity.wired.state.disconnected": "Disconnected",
        "settings.connectivity.wired.state.disconnecting": "Disconnecting",
        "settings.connectivity.wired.state.unavailable": "Unavailable",
        "settings.connectivity.wired.state.unmanaged": "Unmanaged",
        "settings.connectivity.wired.state.unknown": "Unknown"
    },
    "pt-BR": {
        "settings.connectivity.wired.state.connected": "Conectada",
        "settings.connectivity.wired.state.connecting": "Conectando",
        "settings.connectivity.wired.state.disconnected": "Desconectada",
        "settings.connectivity.wired.state.disconnecting": "Desconectando",
        "settings.connectivity.wired.state.unavailable": "Indisponível",
        "settings.connectivity.wired.state.unmanaged": "Não gerenciada",
        "settings.connectivity.wired.state.unknown": "Desconhecido"
    }
}

function message(locale, key) {
    var requested = String(locale || "en-US")
    var catalog = MESSAGES[requested] || MESSAGES["en-US"]
    return typeof catalog[key] === "string" ? catalog[key] : ""
}

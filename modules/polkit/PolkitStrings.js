.pragma library

var ENGLISH = {
    windowTitle: "Authentication required",
    heading: "Administrator authentication",
    description: "An application is requesting permission to perform a privileged action.",
    identityLabel: "Authenticate as",
    groupIdentity: "group",
    actionLabel: "Requested action",
    showDetails: "Details",
    hideDetails: "Hide details",
    passwordFallback: "Password",
    waiting: "Waiting for authentication…",
    failed: "Authentication failed. Try again.",
    cancel: "Cancel",
    authenticate: "Authenticate"
}

var PORTUGUESE = {
    windowTitle: "Autenticação necessária",
    heading: "Autenticação administrativa",
    description: "Um aplicativo está solicitando permissão para realizar uma ação privilegiada.",
    identityLabel: "Autenticar como",
    groupIdentity: "grupo",
    actionLabel: "Ação solicitada",
    showDetails: "Detalhes",
    hideDetails: "Ocultar detalhes",
    passwordFallback: "Senha",
    waiting: "Aguardando autenticação…",
    failed: "Falha na autenticação. Tente novamente.",
    cancel: "Cancelar",
    authenticate: "Autenticar"
}

function strings(locale) {
    var normalized = String(locale || "").toLowerCase()
    return normalized.indexOf("pt") === 0 ? PORTUGUESE : ENGLISH
}

function text(locale, key) {
    var values = strings(locale)
    return values[key] || ENGLISH[key] || String(key || "")
}

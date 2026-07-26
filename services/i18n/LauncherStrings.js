.pragma library

var ENGLISH = {
    allApps: "All apps",
    pinnedApps: "Pinned apps",
    searchResults: "Search results",
    kindApplication: "App",
    kindWindow: "Window",
    kindAction: "Action",
    applicationFallback: "Application",
    openWindow: "Open window",
    toggleOverviewTitle: "Toggle overview",
    niriShellAction: "Niri shell action",
    focusColumnLeftTitle: "Focus column left",
    focusColumnRightTitle: "Focus column right",
    centerColumnTitle: "Center current column",
    toggleFloatingTitle: "Toggle floating window",
    toggleFullscreenTitle: "Toggle fullscreen",
    niriLayoutAction: "Niri layout action",
    sessionMenuTitle: "Open session menu",
    sessionMenuSubtitle: "Lock, suspend, log out, or power controls",
    appGridAccessibleName: "Installed applications",
    pinnedGridAccessibleName: "Pinned applications"
}

var PORTUGUESE = {
    allApps: "Todos os aplicativos",
    pinnedApps: "Aplicativos fixados",
    searchResults: "Resultados da pesquisa",
    kindApplication: "Aplicativo",
    kindWindow: "Janela",
    kindAction: "Ação",
    applicationFallback: "Aplicativo",
    openWindow: "Janela aberta",
    toggleOverviewTitle: "Alternar visão geral",
    niriShellAction: "Ação do shell do Niri",
    focusColumnLeftTitle: "Focar coluna à esquerda",
    focusColumnRightTitle: "Focar coluna à direita",
    centerColumnTitle: "Centralizar coluna atual",
    toggleFloatingTitle: "Alternar janela flutuante",
    toggleFullscreenTitle: "Alternar tela cheia",
    niriLayoutAction: "Ação de layout do Niri",
    sessionMenuTitle: "Abrir menu da sessão",
    sessionMenuSubtitle: "Bloquear, suspender, encerrar sessão ou controlar energia",
    appGridAccessibleName: "Aplicativos instalados",
    pinnedGridAccessibleName: "Aplicativos fixados"
}

function strings(locale) {
    var normalized = String(locale || "").toLowerCase()
    return normalized.indexOf("pt") === 0 ? PORTUGUESE : ENGLISH
}

function text(locale, key) {
    var values = strings(locale)
    return values[key] || ENGLISH[key] || String(key || "")
}

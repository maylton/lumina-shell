.pragma library

var ENGLISH = {
    launcher: "Launcher",
    openLauncher: "Open the application launcher",
    running: "Running",
    pinned: "Pinned",
    rightClickPin: "Right-click to pin",
    rightClickUnpin: "Right-click to unpin",
    categoryDescription: "Favorites and running applications",
    pageDescription: "Optional application dock behavior and appearance",
    visibility: "Visibility",
    visibilityDescription: "The dock is disabled by default and can run on every output",
    enable: "Enable dock",
    enableDescription: "Show the centered application dock on every monitor",
    autoHide: "Automatically hide",
    autoHideDescription: "Reveal the dock by moving the pointer to the bottom center",
    showRunning: "Show running applications",
    showRunningDescription: "Append grouped Niri applications after pinned favorites",
    reserveSpace: "Reserve workspace space",
    reserveSpaceDescription: "Keep tiled windows above an always-visible dock",
    reserveUnavailable: "Disable automatic hiding first",
    appearance: "Appearance",
    appearanceDescription: "The dock follows the shell Solid, Blur, or Frosted Glass style",
    iconSize: "Icon size",
    iconSizeDescription: "Size of application icons and interaction targets",
    margin: "Bottom margin",
    marginDescription: "Distance between the dock and the screen or bottom bar",
    favorites: "Pinned applications",
    favoritesDescription: "Right-click a running application in the dock to pin or unpin it",
    noFavorites: "No pinned applications",
    noFavoritesDescription: "Open an application, then right-click its dock icon to pin it",
    remove: "Remove",
    clear: "Clear favorites",
    clearDescription: "Remove every pinned application from the dock",
    reset: "Reset dock",
    resetDescription: "Restore dock visibility, behavior, size, and favorites"
}

var PORTUGUESE = {
    launcher: "Launcher",
    openLauncher: "Abrir o launcher de aplicativos",
    running: "Em execução",
    pinned: "Fixado",
    rightClickPin: "Clique com o botão direito para fixar",
    rightClickUnpin: "Clique com o botão direito para desafixar",
    categoryDescription: "Favoritos e aplicativos em execução",
    pageDescription: "Comportamento e aparência do dock opcional",
    visibility: "Visibilidade",
    visibilityDescription: "O dock vem desativado e pode aparecer em todas as saídas",
    enable: "Ativar dock",
    enableDescription: "Exibe o dock de aplicativos centralizado em todos os monitores",
    autoHide: "Ocultar automaticamente",
    autoHideDescription: "Revela o dock ao mover o ponteiro para o centro inferior da tela",
    showRunning: "Exibir aplicativos em execução",
    showRunningDescription: "Agrupa aplicativos do Niri depois dos favoritos fixados",
    reserveSpace: "Reservar espaço da área de trabalho",
    reserveSpaceDescription: "Mantém as janelas lado a lado acima de um dock sempre visível",
    reserveUnavailable: "Desative primeiro a ocultação automática",
    appearance: "Aparência",
    appearanceDescription: "O dock segue o estilo Sólido, Desfoque ou Vidro fosco do shell",
    iconSize: "Tamanho dos ícones",
    iconSizeDescription: "Tamanho dos ícones e dos alvos de interação",
    margin: "Margem inferior",
    marginDescription: "Distância entre o dock e a tela ou barra inferior",
    favorites: "Aplicativos fixados",
    favoritesDescription: "Clique com o botão direito em um aplicativo aberto para fixar ou desafixar",
    noFavorites: "Nenhum aplicativo fixado",
    noFavoritesDescription: "Abra um aplicativo e clique com o botão direito no ícone do dock",
    remove: "Remover",
    clear: "Limpar favoritos",
    clearDescription: "Remove todos os aplicativos fixados do dock",
    reset: "Restaurar dock",
    resetDescription: "Restaura visibilidade, comportamento, tamanho e favoritos do dock"
}

function strings(locale) {
    var normalized = String(locale || "").toLowerCase()
    return normalized.indexOf("pt") === 0 ? PORTUGUESE : ENGLISH
}

function text(locale, key) {
    var values = strings(locale)
    return values[key] || ENGLISH[key] || String(key || "")
}

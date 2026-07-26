.pragma library

var messages = {
    "en-US": {
        "settings.bar.surface.position.top": "Top",
        "settings.bar.surface.position.bottom": "Bottom",
        "settings.bar.surface.geometry.edgeDescription": "Fill the screen edge",
        "settings.bar.surface.geometry.floatingDescription": "Reserve space around the visible surface",
        "settings.bar.surface.geometry.edge": "Edge-to-edge",
        "settings.bar.surface.geometry.floating": "Floating",
        "settings.bar.surface.effectiveScale": "Effective content scale",
        "settings.bar.surface.contentScale": "Content scale",
        "settings.bar.surface.effectiveScaleDescription": "Calculated from the selected bar height",
        "settings.bar.surface.contentScaleDescription": "Manual scale for bar contents",
        "settings.bar.surface.autoScaleValue": "Calculated automatically from %1 px bar height",
        "settings.bar.surface.marginUnavailable": "Edge-to-edge mode does not use an outer margin"
    },
    "pt-BR": {
        "settings.bar.surface.position.top": "Superior",
        "settings.bar.surface.position.bottom": "Inferior",
        "settings.bar.surface.geometry.edgeDescription": "Preenche toda a borda da tela",
        "settings.bar.surface.geometry.floatingDescription": "Mantém espaço ao redor da superfície visível",
        "settings.bar.surface.geometry.edge": "De ponta a ponta",
        "settings.bar.surface.geometry.floating": "Flutuante",
        "settings.bar.surface.effectiveScale": "Escala efetiva do conteúdo",
        "settings.bar.surface.contentScale": "Escala do conteúdo",
        "settings.bar.surface.effectiveScaleDescription": "Calculada a partir da altura selecionada para a barra",
        "settings.bar.surface.contentScaleDescription": "Escala manual para o conteúdo da barra",
        "settings.bar.surface.autoScaleValue": "Calculada automaticamente para uma barra com %1 px de altura",
        "settings.bar.surface.marginUnavailable": "O modo de ponta a ponta não usa margem externa"
    }
}

function message(locale, key) {
    var localeMessages = messages[String(locale || "")] || messages["en-US"]
    return localeMessages && typeof localeMessages[key] === "string"
        ? localeMessages[key]
        : ""
}

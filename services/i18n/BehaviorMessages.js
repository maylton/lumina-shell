.pragma library

var messages = {
    "en-US": {
        "settings.behavior.controlCenter.section": "Control Center",
        "settings.behavior.closeOutside.title": "Close when clicking outside",
        "settings.behavior.closeOutside.description": "Keep the panel open when disabled",
        "settings.behavior.activeOutput.title": "Open on active output",
        "settings.behavior.activeOutput.description": "Invalid output requests fall back to Niri focus",
        "settings.behavior.confirmDestructive.title": "Confirm destructive actions",
        "settings.behavior.confirmDestructive.description": "Logout, restart, power off, and reset",
        "settings.behavior.motion.section": "Motion",
        "settings.behavior.reduceMotion.title": "Reduce motion",
        "settings.behavior.reduceMotion.description": "Replace long transitions with minimal feedback",
        "settings.behavior.transitionDuration.title": "Transition duration",
        "settings.behavior.transitionDuration.description": "Global scale applied to Material motion",
        "settings.behavior.animationsDisabled": "Animations are disabled"
    },
    "pt-BR": {
        "settings.behavior.controlCenter.section": "Central de Controle",
        "settings.behavior.closeOutside.title": "Fechar ao clicar fora",
        "settings.behavior.closeOutside.description": "Mantém o painel aberto quando desativado",
        "settings.behavior.activeOutput.title": "Abrir na saída ativa",
        "settings.behavior.activeOutput.description": "Solicitações de saída inválidas usam o foco do Niri como alternativa",
        "settings.behavior.confirmDestructive.title": "Confirmar ações destrutivas",
        "settings.behavior.confirmDestructive.description": "Encerrar sessão, reiniciar, desligar e restaurar",
        "settings.behavior.motion.section": "Movimento",
        "settings.behavior.reduceMotion.title": "Reduzir movimento",
        "settings.behavior.reduceMotion.description": "Substitui transições longas por feedback mínimo",
        "settings.behavior.transitionDuration.title": "Duração das transições",
        "settings.behavior.transitionDuration.description": "Escala global aplicada ao movimento Material",
        "settings.behavior.animationsDisabled": "As animações estão desativadas"
    }
}

function message(locale, key) {
    var resolvedLocale = messages[String(locale || "")] ? String(locale) : "en-US"
    var catalog = messages[resolvedLocale] || messages["en-US"]
    var value = catalog[String(key || "")]
    return typeof value === "string" ? value : ""
}

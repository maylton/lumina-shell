.pragma library

var EN = {
    "bar.launcher.accessibleName": "Open application launcher",
    "bar.launcher.label": "Apps",
    "bar.dashboard.accessibleName": "Open Dashboard for %1",
    "bar.dashboard.accessibleDescription": "Quick controls and session actions",
    "bar.dashboard.tooltipDescription": "Open Dashboard and session actions",
    "bar.wallpaper.accessibleName": "Open wallpaper picker",
    "bar.wallpaper.label": "Wallpaper",
    "bar.session.accessibleName": "Open session and layout controls",
    "bar.session.label": "Session",
    "bar.notifications.open": "Open notifications",
    "bar.notifications.close": "Close notifications",
    "bar.notifications.unread": "%1 unread notifications",
    "bar.notifications.dndDescription": "Do Not Disturb is enabled",
    "bar.notifications.tooltipDnd": "Notifications · DND",
    "bar.notifications.tooltip": "Notifications",
    "bar.notifications.unreadCount": "%1 unread",
    "bar.notifications.noneUnread": "No unread notifications",
    "notifications.center.title": "Notifications",
    "notifications.center.allCaughtUp": "All caught up",
    "notifications.center.recent.one": "%1 recent notification",
    "notifications.center.recent.other": "%1 recent notifications",
    "notifications.center.dnd": "Do Not Disturb",
    "notifications.center.dndShort": "DND",
    "notifications.center.clearAccessible": "Clear notification history",
    "notifications.center.clear": "Clear",
    "notifications.center.quietTitle": "Quiet mode is on",
    "notifications.center.quietDescription": "New notifications stay in history without interrupting you",
    "notifications.center.emptyDescription": "New notifications will appear here"
}

var PT = {
    "bar.launcher.accessibleName": "Abrir o Launcher de aplicativos",
    "bar.launcher.label": "Aplicativos",
    "bar.dashboard.accessibleName": "Abrir o Dashboard de %1",
    "bar.dashboard.accessibleDescription": "Controles rápidos e ações de sessão",
    "bar.dashboard.tooltipDescription": "Abrir o Dashboard e as ações de sessão",
    "bar.wallpaper.accessibleName": "Abrir o seletor de papel de parede",
    "bar.wallpaper.label": "Papel de parede",
    "bar.session.accessibleName": "Abrir os controles de sessão e layout",
    "bar.session.label": "Sessão",
    "bar.notifications.open": "Abrir notificações",
    "bar.notifications.close": "Fechar notificações",
    "bar.notifications.unread": "%1 notificações não lidas",
    "bar.notifications.dndDescription": "O modo Não perturbe está ativado",
    "bar.notifications.tooltipDnd": "Notificações · Não perturbe",
    "bar.notifications.tooltip": "Notificações",
    "bar.notifications.unreadCount": "%1 não lidas",
    "bar.notifications.noneUnread": "Nenhuma notificação não lida",
    "notifications.center.title": "Notificações",
    "notifications.center.allCaughtUp": "Tudo em dia",
    "notifications.center.recent.one": "%1 notificação recente",
    "notifications.center.recent.other": "%1 notificações recentes",
    "notifications.center.dnd": "Não perturbe",
    "notifications.center.dndShort": "NP",
    "notifications.center.clearAccessible": "Limpar histórico de notificações",
    "notifications.center.clear": "Limpar",
    "notifications.center.quietTitle": "O modo silencioso está ativado",
    "notifications.center.quietDescription": "Novas notificações permanecem no histórico sem interromper você",
    "notifications.center.emptyDescription": "Novas notificações aparecerão aqui"
}

function message(locale, key) {
    var catalog = String(locale || "en-US") === "pt-BR" ? PT : EN
    return typeof catalog[key] === "string" ? catalog[key] : ""
}

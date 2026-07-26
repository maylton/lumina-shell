.pragma library

var LEFT = "left"
var CENTER = "center"
var RIGHT = "right"

var entries = [
    {
        id: "launcher",
        title: "Launcher",
        description: "Search and open applications",
        icon: "system-search-symbolic",
        side: LEFT,
        configurable: true,
        available: true,
        unavailableReason: "",
        component: "LauncherWidgetSettings",
        defaults: {
            showBackground: false,
            surfacePlacement: "centered",
            showLabel: false
        }
    },
    {
        id: "overview",
        title: "Overview",
        description: "Niri workspaces and windows overview",
        icon: "view-grid-symbolic",
        side: LEFT,
        configurable: true,
        available: true,
        unavailableReason: "",
        component: "OverviewWidgetSettings",
        defaults: {
            showBackground: false,
            showLabel: false
        }
    },
    {
        id: "workspaces",
        title: "Workspaces",
        description: "Workspaces available on this output",
        icon: "view-paged-symbolic",
        side: LEFT,
        configurable: true,
        available: true,
        unavailableReason: "",
        component: "WorkspacesWidgetSettings",
        defaults: {
            showBackground: false,
            labelMode: "active",
            inactiveStyle: "dot"
        }
    },
    {
        id: "datetime",
        title: "Date and time",
        description: "Clock, date, and calendar",
        icon: "preferences-system-time-symbolic",
        side: LEFT,
        configurable: true,
        available: true,
        unavailableReason: "",
        component: "DateTimeWidgetSettings",
        defaults: {
            showBackground: true,
            surfacePlacement: "near-widget",
            clockLayout: "inline",
            hourFormat: "24",
            showSeconds: false,
            dateMode: "short",
            showSeparator: true
        }
    },
    {
        id: "context",
        title: "Window context",
        description: "Focused window and Niri layout context",
        icon: "view-grid-symbolic",
        side: CENTER,
        configurable: true,
        available: true,
        unavailableReason: "",
        component: "ContextWidgetSettings",
        defaults: {
            showBackground: true,
            mode: "contextual",
            timeout: 3500,
            showWindowTitle: true,
            showWorkspace: true,
            showApplicationId: true,
            showColumn: true
        }
    },
    {
        id: "tray",
        title: "System tray",
        description: "StatusNotifier application items",
        icon: "view-more-horizontal-symbolic",
        side: RIGHT,
        configurable: true,
        available: true,
        unavailableReason: "",
        component: "TrayWidgetSettings",
        defaults: {
            showBackground: false,
            surfacePlacement: "near-widget",
            mode: "grouped",
            showCount: false
        }
    },
    {
        id: "notifications",
        title: "Notifications",
        description: "Notification center and unread state",
        icon: "preferences-system-notifications-symbolic",
        side: RIGHT,
        configurable: true,
        available: true,
        unavailableReason: "",
        component: "NotificationsWidgetSettings",
        defaults: {
            showBackground: false,
            surfacePlacement: "near-widget",
            showUnreadBadge: true,
            showDoNotDisturbState: true
        }
    },
    {
        id: "system-status",
        title: "System status",
        description: "Network, audio, and battery",
        icon: "network-wireless-symbolic",
        side: RIGHT,
        configurable: true,
        available: true,
        unavailableReason: "",
        component: "SystemStatusWidgetSettings",
        defaults: {
            showBackground: true,
            layout: "grouped",
            showNetwork: true,
            networkTextMode: "summary",
            showAudio: true,
            audioTextMode: "percentage",
            showBattery: true,
            batteryTextMode: "percentage"
        }
    },
    {
        id: "dashboard",
        title: "User avatar",
        description: "Dashboard and session entry point",
        icon: "avatar-default-symbolic",
        side: RIGHT,
        configurable: true,
        available: true,
        unavailableReason: "",
        component: "UserAvatarWidgetSettings",
        defaults: {
            showBackground: false,
            surfacePlacement: "centered",
            avatarDisplay: "image",
            showUserName: false
        }
    },
    {
        id: "wallpaper",
        title: "Wallpaper",
        description: "Open the wallpaper picker",
        icon: "preferences-desktop-wallpaper-symbolic",
        side: RIGHT,
        configurable: true,
        available: true,
        unavailableReason: "",
        component: "WallpaperWidgetSettings",
        defaults: {
            showBackground: false,
            surfacePlacement: "centered",
            showLabel: false
        }
    },
    {
        id: "session",
        title: "Session",
        description: "Session and layout actions",
        icon: "system-shutdown-symbolic",
        side: RIGHT,
        configurable: true,
        available: true,
        unavailableReason: "",
        component: "SessionWidgetSettings",
        defaults: {
            showBackground: false,
            surfacePlacement: "centered",
            showLabel: false
        }
    }
]

function clone(value) {
    if (Array.isArray(value))
        return value.map(clone)

    if (value && typeof value === "object") {
        var result = {}

        for (var key in value)
            result[key] = clone(value[key])

        return result
    }

    return value
}

function all() {
    return entries.map(clone)
}

function forSide(side) {
    var requested = String(side || "")
    return entries.filter(function(entry) {
        return entry.side === requested
    }).map(clone)
}

function find(widgetId) {
    var requested = String(widgetId || "")

    for (var index = 0; index < entries.length; ++index) {
        if (entries[index].id === requested)
            return clone(entries[index])
    }

    return null
}

function idsForSide(side) {
    return forSide(side).map(function(entry) {
        return entry.id
    })
}

function defaultSettings() {
    var result = {}

    for (var index = 0; index < entries.length; ++index)
        result[entries[index].id] = clone(entries[index].defaults)

    return result
}

function withSetting(settings, widgetId, key, value) {
    var id = String(widgetId || "")
    var entry = find(id)
    var result = clone(settings || {})

    if (!entry)
        return result

    var widget = clone(result[id] || entry.defaults)
    widget[String(key || "")] = value
    result[id] = widget
    return result
}

function withReset(settings, widgetId) {
    var id = String(widgetId || "")
    var entry = find(id)
    var result = clone(settings || {})

    if (entry)
        result[id] = clone(entry.defaults)

    return result
}

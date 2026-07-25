.pragma library

var CURRENT_VERSION = 5

function defaults() {
    return {
        schemaVersion: CURRENT_VERSION,
        doNotDisturb: false,
        dynamicTheme: true,
        paletteStyle: "auto",
        wallpapers: {},
        defaultWallpaper:
            "/usr/share/wallpapers/cachyos-wallpapers/Abstract.png",
        wallpaperDirectory:
            "/usr/share/wallpapers/cachyos-wallpapers",
        osdEnabled: true,
        osdDuration: 1800,
        showStatusDetails: true,
        themeMode: "auto",
        transparencyEnabled: false,
        surfaceOpacity: 0.96,
        animationsEnabled: true,
        animationScale: 1,
        cornerRadiusScale: 1,
        compactMode: false,
        barSurfaceMode: "edge-to-edge",
        barContextMode: "contextual",
        barContextTimeout: 3500,
        barStatusLayout: "grouped",
        barPosition: "top",
        barHeight: 48,
        barMargin: 5,
        barWidgetSpacing: 10,
        barShowLauncher: true,
        barShowOverview: true,
        barShowWindowTitle: true,
        barCenterWindowTitle: true,
        barShowAppId: true,
        barShowWorkspaces: true,
        barShowColumnIndicator: true,
        barShowDate: true,
        barDateStyle: "short",
        barShowKeyboardLayout: true,
        barShowPrivacyIndicators: true,
        barShowTray: true,
        barShowNotifications: true,
        barShowDashboardButton: true,
        barShowAudioStatus: true,
        barShowNetworkStatus: true,
        barShowBatteryStatus: true,
        barShowWallpaperButton: false,
        barShowSessionButton: false,
        barShowClock: true,
        barClock24Hour: true,
        barShowSeconds: false,
        barLeftWidgetOrder: [
            "launcher",
            "overview",
            "workspaces",
            "datetime"
        ],
        barRightWidgetOrder: [
            "privacy",
            "keyboard",
            "tray",
            "notifications",
            "system-status",
            "dashboard"
        ],
        dashboardDefaultPage: "dashboard",
        dashboardRememberPage: true,
        dashboardRememberCategory: true,
        dashboardDensity: "comfortable",
        dashboardShowWeather: true,
        dashboardShowCalendar: true,
        dashboardShowMedia: true,
        dashboardShowNotifications: true,
        dashboardShowSystem: true,
        dashboardShowOverview: true,
        dashboardShowControls: true,
        dashboardShowSessionActions: true,
        dashboardCardOrder: [
            "overview",
            "controls",
            "notifications",
            "media",
            "system",
            "calendar"
        ],
        behaviorCloseOnOutside: true,
        behaviorCloseAfterAction: false,
        behaviorOpenOnActiveOutput: true,
        behaviorTransitionScale: 1,
        reduceMotion: false,
        destructiveConfirmations: true,
        notificationPopupPosition: "top-right",
        notificationPopupDuration: 6000,
        notificationPopupMaximum: 3,
        notificationShowImages: true,
        notificationKeepHistory: true,
        notificationClearHistoryOnExit: false,
        notificationPreferredOutput: "active",
        osdPosition: "bottom",
        osdSize: 1,
        osdShowPercentage: true,
        osdVolumeEnabled: true,
        osdMicrophoneEnabled: true,
        osdBrightnessEnabled: true,
        osdPowerEnabled: true,
        osdPreferredOutput: "active",
        sessionConfirmLogout: true,
        sessionConfirmReboot: true,
        sessionConfirmPoweroff: true,
        sessionShowSuspend: true,
        sessionShowLock: true,
        lastSettingsCategory: "appearance",
        lastControlPage: "dashboard"
    }
}

function clone(value) {
    if (Array.isArray(value))
        return value.slice()

    if (value && typeof value === "object") {
        var copy = {}

        for (var key in value)
            copy[key] = value[key]

        return copy
    }

    return value
}

function boundedNumber(value, fallback, minimum, maximum) {
    var numeric = Number(value)

    if (!isFinite(numeric))
        numeric = fallback

    return Math.max(minimum, Math.min(maximum, numeric))
}

function choice(value, allowed, fallback) {
    var text = String(value || "")
    return allowed.indexOf(text) >= 0 ? text : fallback
}

function settingsCategories() {
    return [
        "appearance",
        "bar",
        "dashboard",
        "behavior",
        "notifications",
        "osd",
        "session",
        "system",
        "about"
    ]
}

function normalizeSettingsCategory(value) {
    var requested = String(value || "")

    if (requested === "wallpaper")
        requested = "appearance"

    return choice(requested, settingsCategories(), "appearance")
}

function booleanValue(value, fallback) {
    return typeof value === "boolean" ? value : fallback
}

function normalizedOrder(value, requiredIds, optionalIds) {
    var input = Array.isArray(value) ? value : []
    var required = Array.isArray(requiredIds) ? requiredIds : []
    var optional = Array.isArray(optionalIds) ? optionalIds : []
    var allowed = required.concat(optional)
    var result = []

    for (var index = 0; index < input.length; ++index) {
        var id = String(input[index] || "")

        if (allowed.indexOf(id) < 0 || result.indexOf(id) >= 0)
            continue

        result.push(id)
    }

    for (var requiredIndex = 0;
        requiredIndex < required.length;
        ++requiredIndex) {
        var requiredId = required[requiredIndex]

        if (result.indexOf(requiredId) < 0)
            result.push(requiredId)
    }

    return result
}

function normalize(source) {
    var input = source && typeof source === "object" ? source : {}
    var result = {}
    var base = defaults()

    for (var key in base) {
        result[key] = input[key] === undefined
            ? clone(base[key])
            : clone(input[key])
    }

    if (typeof result.wallpapers === "string") {
        result.defaultWallpaper = result.wallpapers
        result.wallpapers = {}
    } else if (!result.wallpapers
        || Array.isArray(result.wallpapers)
        || typeof result.wallpapers !== "object") {
        result.wallpapers = {}
    }

    result.schemaVersion = CURRENT_VERSION
    result.themeMode = choice(
        result.themeMode,
        ["auto", "light", "dark"],
        base.themeMode
    )
    result.paletteStyle = choice(
        result.paletteStyle,
        [
            "auto",
            "content",
            "expressive",
            "fidelity",
            "fruit-salad",
            "monochrome",
            "neutral",
            "rainbow",
            "tonal-spot"
        ],
        base.paletteStyle
    )
    result.surfaceOpacity = boundedNumber(
        result.surfaceOpacity,
        base.surfaceOpacity,
        0.72,
        1
    )
    result.animationScale = boundedNumber(
        result.animationScale,
        base.animationScale,
        0,
        2
    )
    result.cornerRadiusScale = boundedNumber(
        result.cornerRadiusScale,
        base.cornerRadiusScale,
        0.6,
        1.5
    )
    result.barSurfaceMode = choice(
        result.barSurfaceMode,
        ["edge-to-edge", "floating"],
        base.barSurfaceMode
    )
    result.barContextMode = choice(
        result.barContextMode,
        ["always", "contextual", "hidden"],
        base.barContextMode
    )
    result.barContextTimeout = Math.round(
        boundedNumber(
            result.barContextTimeout,
            base.barContextTimeout,
            1000,
            15000
        )
    )
    result.barStatusLayout = choice(
        result.barStatusLayout,
        ["grouped", "individual"],
        base.barStatusLayout
    )
    result.barPosition = choice(
        result.barPosition,
        ["top", "bottom"],
        base.barPosition
    )
    result.barHeight = Math.round(
        boundedNumber(result.barHeight, base.barHeight, 40, 72)
    )
    result.barMargin = Math.round(
        boundedNumber(result.barMargin, base.barMargin, 0, 18)
    )
    result.barWidgetSpacing = Math.round(
        boundedNumber(
            result.barWidgetSpacing,
            base.barWidgetSpacing,
            2,
            24
        )
    )
    result.barDateStyle = choice(
        result.barDateStyle,
        ["short", "weekday", "full"],
        base.barDateStyle
    )
    result.dashboardDefaultPage = choice(
        result.dashboardDefaultPage,
        ["dashboard", "settings"],
        base.dashboardDefaultPage
    )
    result.dashboardDensity = choice(
        result.dashboardDensity,
        ["compact", "comfortable", "spacious"],
        base.dashboardDensity
    )
    result.behaviorTransitionScale = boundedNumber(
        result.behaviorTransitionScale,
        base.behaviorTransitionScale,
        0,
        2
    )
    result.notificationPopupPosition = choice(
        result.notificationPopupPosition,
        ["top-left", "top-right", "bottom-left", "bottom-right"],
        base.notificationPopupPosition
    )
    result.notificationPopupDuration = Math.round(
        boundedNumber(
            result.notificationPopupDuration,
            base.notificationPopupDuration,
            3000,
            15000
        )
    )
    result.notificationPopupMaximum = Math.round(
        boundedNumber(
            result.notificationPopupMaximum,
            base.notificationPopupMaximum,
            1,
            5
        )
    )
    result.osdDuration = Math.round(
        boundedNumber(
            result.osdDuration,
            base.osdDuration,
            800,
            5000
        )
    )
    result.osdPosition = choice(
        result.osdPosition,
        ["top", "center", "bottom"],
        base.osdPosition
    )
    result.osdSize = boundedNumber(
        result.osdSize,
        base.osdSize,
        0.8,
        1.4
    )
    result.lastSettingsCategory = normalizeSettingsCategory(
        result.lastSettingsCategory
    )
    result.lastControlPage = choice(
        result.lastControlPage,
        ["dashboard", "settings"],
        base.lastControlPage
    )

    var booleanKeys = [
        "doNotDisturb",
        "dynamicTheme",
        "osdEnabled",
        "showStatusDetails",
        "transparencyEnabled",
        "animationsEnabled",
        "compactMode",
        "barShowLauncher",
        "barShowOverview",
        "barShowWindowTitle",
        "barCenterWindowTitle",
        "barShowAppId",
        "barShowWorkspaces",
        "barShowColumnIndicator",
        "barShowDate",
        "barShowKeyboardLayout",
        "barShowPrivacyIndicators",
        "barShowTray",
        "barShowNotifications",
        "barShowDashboardButton",
        "barShowAudioStatus",
        "barShowNetworkStatus",
        "barShowBatteryStatus",
        "barShowWallpaperButton",
        "barShowSessionButton",
        "barShowClock",
        "barClock24Hour",
        "barShowSeconds",
        "dashboardRememberPage",
        "dashboardRememberCategory",
        "dashboardShowWeather",
        "dashboardShowCalendar",
        "dashboardShowMedia",
        "dashboardShowNotifications",
        "dashboardShowSystem",
        "dashboardShowOverview",
        "dashboardShowControls",
        "dashboardShowSessionActions",
        "behaviorCloseOnOutside",
        "behaviorCloseAfterAction",
        "behaviorOpenOnActiveOutput",
        "reduceMotion",
        "destructiveConfirmations",
        "notificationShowImages",
        "notificationKeepHistory",
        "notificationClearHistoryOnExit",
        "osdShowPercentage",
        "osdVolumeEnabled",
        "osdMicrophoneEnabled",
        "osdBrightnessEnabled",
        "osdPowerEnabled",
        "sessionConfirmLogout",
        "sessionConfirmReboot",
        "sessionConfirmPoweroff",
        "sessionShowSuspend",
        "sessionShowLock"
    ]

    for (var index = 0; index < booleanKeys.length; ++index) {
        var booleanKey = booleanKeys[index]
        result[booleanKey] = booleanValue(
            result[booleanKey],
            base[booleanKey]
        )
    }

    result.barLeftWidgetOrder = normalizedOrder(
        result.barLeftWidgetOrder,
        base.barLeftWidgetOrder,
        []
    )
    result.barRightWidgetOrder = normalizedOrder(
        result.barRightWidgetOrder,
        base.barRightWidgetOrder,
        ["wallpaper", "session"]
    )

    if (!Array.isArray(result.dashboardCardOrder))
        result.dashboardCardOrder = base.dashboardCardOrder.slice()

    if (!String(result.wallpaperDirectory || ""))
        result.wallpaperDirectory = base.wallpaperDirectory

    return result
}

function migrate(source) {
    return normalize(source)
}

function defaultsForCategory(categoryName) {
    var base = defaults()
    var category = String(categoryName || "")
    var prefixes = {
        appearance: [
            "themeMode",
            "dynamicTheme",
            "paletteStyle",
            "transparencyEnabled",
            "surfaceOpacity",
            "animationsEnabled",
            "animationScale",
            "cornerRadiusScale",
            "compactMode",
            "wallpapers",
            "defaultWallpaper",
            "wallpaperDirectory"
        ],
        bar: [
            "barSurfaceMode",
            "barContextMode",
            "barContextTimeout",
            "barStatusLayout",
            "barPosition",
            "barHeight",
            "barMargin",
            "barWidgetSpacing",
            "barShowLauncher",
            "barShowOverview",
            "barShowWindowTitle",
            "barCenterWindowTitle",
            "barShowAppId",
            "barShowWorkspaces",
            "barShowColumnIndicator",
            "barShowDate",
            "barDateStyle",
            "barShowKeyboardLayout",
            "barShowPrivacyIndicators",
            "barShowTray",
            "barShowNotifications",
            "barShowDashboardButton",
            "barShowAudioStatus",
            "barShowNetworkStatus",
            "barShowBatteryStatus",
            "barShowWallpaperButton",
            "barShowSessionButton",
            "barShowClock",
            "barClock24Hour",
            "barShowSeconds",
            "barLeftWidgetOrder",
            "barRightWidgetOrder",
            "showStatusDetails"
        ],
        dashboard: [
            "dashboardDefaultPage",
            "dashboardRememberPage",
            "dashboardRememberCategory",
            "dashboardDensity",
            "dashboardShowWeather",
            "dashboardShowCalendar",
            "dashboardShowMedia",
            "dashboardShowNotifications",
            "dashboardShowSystem",
            "dashboardShowOverview",
            "dashboardShowControls",
            "dashboardShowSessionActions",
            "dashboardCardOrder"
        ],
        behavior: [
            "behaviorCloseOnOutside",
            "behaviorCloseAfterAction",
            "behaviorOpenOnActiveOutput",
            "behaviorTransitionScale",
            "reduceMotion",
            "destructiveConfirmations"
        ],
        notifications: [
            "doNotDisturb",
            "notificationPopupPosition",
            "notificationPopupDuration",
            "notificationPopupMaximum",
            "notificationShowImages",
            "notificationKeepHistory",
            "notificationClearHistoryOnExit",
            "notificationPreferredOutput"
        ],
        osd: [
            "osdEnabled",
            "osdDuration",
            "osdPosition",
            "osdSize",
            "osdShowPercentage",
            "osdVolumeEnabled",
            "osdMicrophoneEnabled",
            "osdBrightnessEnabled",
            "osdPowerEnabled",
            "osdPreferredOutput"
        ],
        session: [
            "sessionConfirmLogout",
            "sessionConfirmReboot",
            "sessionConfirmPoweroff",
            "sessionShowSuspend",
            "sessionShowLock"
        ]
    }
    var keys = prefixes[category] || []
    var result = {}

    for (var index = 0; index < keys.length; ++index)
        result[keys[index]] = clone(base[keys[index]])

    return result
}

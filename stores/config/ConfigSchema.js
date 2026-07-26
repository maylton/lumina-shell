.pragma library
.import "../../modules/control/settings/bar/BarWidgetCatalog.js" as BarWidgetCatalog

var CURRENT_VERSION = 10

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
        shellBackgroundMode: "solid",
        shellSurfaceOpacity: 0.82,
        animationsEnabled: true,
        animationScale: 1,
        cornerRadiusScale: 1,
        compactMode: false,
        barSurfaceMode: "edge-to-edge",
        barBackgroundMode: "solid",
        barSurfaceOpacity: 0.86,
        barAutoScaleContents: true,
        barContentScale: 1,
        barPosition: "top",
        barHeight: 56,
        barMargin: 5,
        barPanelGap: 8,
        barWidgetSpacing: 10,
        barShowLauncher: true,
        barShowOverview: true,
        barShowWorkspaces: true,
        barShowKeyboardLayout: true,
        barShowPrivacyIndicators: true,
        barShowTray: true,
        barShowNotifications: true,
        barShowDashboardButton: true,
        barShowNetworkStatus: true,
        barShowAudioStatus: true,
        barShowBatteryStatus: true,
        barShowWallpaperButton: false,
        barShowSessionButton: false,
        barShowClock: true,
        barLeftWidgetOrder: [
            "launcher",
            "overview",
            "workspaces",
            "datetime"
        ],
        barRightWidgetOrder: [
            "tray",
            "notifications",
            "network",
            "audio",
            "battery",
            "dashboard"
        ],
        barWidgetSettings: BarWidgetCatalog.defaultSettings(),
        dashboardDefaultPage: "dashboard",
        dashboardRememberPage: true,
        dashboardRememberCategory: true,
        dashboardDensity: "comfortable",
        dashboardUseUserAvatarImage: true,
        dashboardUserAvatarPath: "",
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

function isArrayValue(value) {
    return Array.isArray(value)
        || (
            value
            && typeof value !== "string"
            && typeof value.length === "number"
        )
}

function arrayValue(value) {
    if (!isArrayValue(value))
        return []

    var result = []

    for (var index = 0; index < value.length; ++index)
        result.push(value[index])

    return result
}

function clone(value) {
    if (isArrayValue(value))
        return arrayValue(value).map(clone)

    if (value && typeof value === "object") {
        var copy = {}

        for (var key in value)
            copy[key] = clone(value[key])

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

function normalizeWidgetEntry(widgetId, value, fallback) {
    var input = value
        && !Array.isArray(value)
        && typeof value === "object"
        ? value
        : {}
    var result = clone(fallback)

    function bool(key) {
        result[key] = booleanValue(input[key], fallback[key])
    }

    function enumValue(key, allowed) {
        result[key] = choice(input[key], allowed, fallback[key])
    }

    bool("showBackground")

    if ([
        "launcher",
        "datetime",
        "tray",
        "notifications",
        "network",
        "audio",
        "battery",
        "dashboard",
        "wallpaper",
        "session"
    ].indexOf(widgetId) >= 0) {
        enumValue(
            "surfacePlacement",
            ["near-widget", "centered"]
        )
    }

    if (["launcher", "overview", "wallpaper", "session"]
        .indexOf(widgetId) >= 0) {
        bool("showLabel")
    } else if (widgetId === "workspaces") {
        enumValue("labelMode", ["active", "all", "none"])
        enumValue("inactiveStyle", ["dot", "number"])
    } else if (widgetId === "datetime") {
        enumValue("clockLayout", ["inline", "stacked"])
        enumValue("hourFormat", ["system", "12", "24"])
        bool("showSeconds")
        enumValue(
            "dateMode",
            ["hidden", "short", "weekday", "full"]
        )
        bool("showSeparator")
    } else if (widgetId === "context") {
        enumValue("mode", ["always", "contextual", "hidden"])
        result.timeout = Math.round(
            boundedNumber(
                input.timeout,
                fallback.timeout,
                1000,
                15000
            )
        )
        bool("showWindowTitle")
        bool("showWorkspace")
        bool("showApplicationId")
        bool("showColumn")
    } else if (widgetId === "tray") {
        enumValue("mode", ["grouped", "inline"])
        bool("showCount")
    } else if (widgetId === "notifications") {
        bool("showUnreadBadge")
        bool("showDoNotDisturbState")
    } else if (widgetId === "network") {
        enumValue(
            "textMode",
            ["icon", "summary", "name", "type"]
        )
    } else if (widgetId === "audio") {
        enumValue(
            "textMode",
            ["icon", "percentage", "state"]
        )
    } else if (widgetId === "battery") {
        enumValue(
            "textMode",
            ["icon", "percentage", "state"]
        )
    } else if (widgetId === "dashboard") {
        enumValue(
            "avatarDisplay",
            ["automatic", "image", "initials"]
        )
        bool("showUserName")
    }

    return result
}

function normalizeWidgetSettings(value) {
    var input = value
        && !Array.isArray(value)
        && typeof value === "object"
        ? value
        : {}
    var defaultsByWidget = BarWidgetCatalog.defaultSettings()
    var result = {}

    for (var widgetId in defaultsByWidget) {
        result[widgetId] = normalizeWidgetEntry(
            widgetId,
            input[widgetId],
            defaultsByWidget[widgetId]
        )
    }

    return result
}

function normalizedOrder(value, requiredIds, optionalIds) {
    var input = arrayValue(value)
    var required = arrayValue(requiredIds)
    var optional = arrayValue(optionalIds)
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
    result.shellBackgroundMode = choice(
        result.shellBackgroundMode,
        ["solid", "blur", "frosted"],
        base.shellBackgroundMode
    )
    result.shellSurfaceOpacity = boundedNumber(
        result.shellSurfaceOpacity,
        base.shellSurfaceOpacity,
        0.55,
        0.95
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
    result.barBackgroundMode = choice(
        result.barBackgroundMode,
        [
            "solid",
            "translucent",
            "blur",
            "frosted",
            "transparent"
        ],
        base.barBackgroundMode
    )
    result.barSurfaceOpacity = boundedNumber(
        result.barSurfaceOpacity,
        base.barSurfaceOpacity,
        0,
        1
    )
    result.barContentScale = boundedNumber(
        result.barContentScale,
        base.barContentScale,
        0.8,
        1.4
    )
    result.barPosition = choice(
        result.barPosition,
        ["top", "bottom"],
        base.barPosition
    )
    result.barHeight = Math.round(
        boundedNumber(result.barHeight, base.barHeight, 40, 80)
    )
    result.barMargin = Math.round(
        boundedNumber(result.barMargin, base.barMargin, 0, 18)
    )
    result.barPanelGap = Math.round(
        boundedNumber(result.barPanelGap, base.barPanelGap, 0, 48)
    )
    result.barWidgetSpacing = Math.round(
        boundedNumber(
            result.barWidgetSpacing,
            base.barWidgetSpacing,
            2,
            24
        )
    )
    result.barWidgetSettings = normalizeWidgetSettings(
        result.barWidgetSettings
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
    result.dashboardUserAvatarPath = String(
        result.dashboardUserAvatarPath || ""
    ).trim()
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
        "animationsEnabled",
        "compactMode",
        "barAutoScaleContents",
        "barShowLauncher",
        "barShowOverview",
        "barShowWorkspaces",
        "barShowKeyboardLayout",
        "barShowPrivacyIndicators",
        "barShowTray",
        "barShowNotifications",
        "barShowDashboardButton",
        "barShowNetworkStatus",
        "barShowAudioStatus",
        "barShowBatteryStatus",
        "barShowWallpaperButton",
        "barShowSessionButton",
        "barShowClock",
        "dashboardRememberPage",
        "dashboardRememberCategory",
        "dashboardUseUserAvatarImage",
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

    if (!isArrayValue(result.dashboardCardOrder))
        result.dashboardCardOrder = base.dashboardCardOrder.slice()
    else
        result.dashboardCardOrder = arrayValue(result.dashboardCardOrder)

    if (!String(result.wallpaperDirectory || ""))
        result.wallpaperDirectory = base.wallpaperDirectory

    return result
}

function migrate(source) {
    var input = source && typeof source === "object"
        ? clone(source)
        : {}
    var version = Number(input.schemaVersion)

    if (!isFinite(version))
        version = 0

    if (version < 6) {
        if (input.transparencyEnabled === true) {
            input.barBackgroundMode = "blur"
            input.barSurfaceOpacity = boundedNumber(
                input.surfaceOpacity,
                defaults().surfaceOpacity,
                0,
                1
            )
        } else {
            input.barBackgroundMode = "solid"
            input.barSurfaceOpacity = 0.86
        }

        input.barAutoScaleContents = true
        input.barContentScale = 1
    }

    if (version < 7) {
        if (String(input.barBackgroundMode) === "translucent")
            input.barBackgroundMode = "blur"

        var widgetSettings = BarWidgetCatalog.defaultSettings()
        var pillsEnabled = booleanValue(
            input.barWidgetPillsEnabled,
            true
        )
        var backgroundWidgets = [
            "launcher",
            "overview",
            "datetime",
            "context",
            "tray",
            "notifications",
            "network",
            "audio",
            "battery",
            "dashboard",
            "wallpaper",
            "session"
        ]

        for (var backgroundIndex = 0;
            backgroundIndex < backgroundWidgets.length;
            ++backgroundIndex) {
            widgetSettings[
                backgroundWidgets[backgroundIndex]
            ].showBackground = pillsEnabled
        }

        widgetSettings.context.mode = choice(
            input.barContextMode,
            ["always", "contextual", "hidden"],
            widgetSettings.context.mode
        )
        widgetSettings.context.timeout = Math.round(
            boundedNumber(
                input.barContextTimeout,
                widgetSettings.context.timeout,
                1000,
                15000
            )
        )
        widgetSettings.context.showWindowTitle = booleanValue(
            input.barShowWindowTitle,
            widgetSettings.context.showWindowTitle
        )
        widgetSettings.context.showApplicationId = booleanValue(
            input.barShowAppId,
            widgetSettings.context.showApplicationId
        )
        widgetSettings.context.showColumn = booleanValue(
            input.barShowColumnIndicator,
            widgetSettings.context.showColumn
        )
        widgetSettings.datetime.hourFormat = booleanValue(
            input.barClock24Hour,
            true
        ) ? "24" : "12"
        widgetSettings.datetime.showSeconds = booleanValue(
            input.barShowSeconds,
            widgetSettings.datetime.showSeconds
        )
        widgetSettings.datetime.dateMode = booleanValue(
            input.barShowDate,
            true
        )
            ? choice(
                input.barDateStyle,
                ["short", "weekday", "full"],
                widgetSettings.datetime.dateMode
            )
            : "hidden"
        widgetSettings.tray.mode = choice(
            input.barTrayMode,
            ["grouped", "inline"],
            widgetSettings.tray.mode
        )
        widgetSettings.network.textMode =
            booleanValue(input.barShowNetworkLabel, true)
                ? "summary"
                : "icon"
        widgetSettings.audio.textMode =
            booleanValue(input.barShowAudioLabel, true)
                ? "percentage"
                : "icon"
        widgetSettings.dashboard.avatarDisplay = booleanValue(
            input.dashboardUseUserAvatarImage,
            true
        ) ? "image" : "initials"

        input.barShowNetworkStatus = booleanValue(
            input.barShowNetworkStatus,
            true
        )
        input.barShowAudioStatus = booleanValue(
            input.barShowAudioStatus,
            true
        )
        input.barShowBatteryStatus = booleanValue(
            input.barShowBatteryStatus,
            true
        )
        input.barWidgetSettings = widgetSettings
    }

    if (version < 8) {
        input.shellBackgroundMode = booleanValue(
  input.transparencyEnabled,
  false
        ) ? "blur" : "solid"
        input.shellSurfaceOpacity = boundedNumber(
  input.surfaceOpacity,
  defaults().shellSurfaceOpacity,
  0.55,
  0.95
        )
        delete input.transparencyEnabled
        delete input.surfaceOpacity
    }

    if (version < 9 && input.barPanelGap === undefined)
        input.barPanelGap = defaults().barPanelGap

    if (version < 10) {
        var existingWidgetSettings = input.barWidgetSettings
            && !Array.isArray(input.barWidgetSettings)
            && typeof input.barWidgetSettings === "object"
                ? clone(input.barWidgetSettings)
                : {}
        var legacyStatus = existingWidgetSettings["system-status"]
            && !Array.isArray(existingWidgetSettings["system-status"])
            && typeof existingWidgetSettings["system-status"] === "object"
                ? existingWidgetSettings["system-status"]
                : null

        if (legacyStatus) {
            var legacyBackground = booleanValue(
                legacyStatus.showBackground,
                true
            )
            existingWidgetSettings.network = {
                showBackground: legacyBackground,
                surfacePlacement: "near-widget",
                textMode: choice(
                    legacyStatus.networkTextMode,
                    ["icon", "summary", "name", "type"],
                    "summary"
                )
            }
            existingWidgetSettings.audio = {
                showBackground: legacyBackground,
                surfacePlacement: "near-widget",
                textMode: choice(
                    legacyStatus.audioTextMode,
                    ["icon", "percentage", "state"],
                    "percentage"
                )
            }
            existingWidgetSettings.battery = {
                showBackground: legacyBackground,
                surfacePlacement: "near-widget",
                textMode: choice(
                    legacyStatus.batteryTextMode,
                    ["icon", "percentage", "state"],
                    "percentage"
                )
            }
        }

        if (legacyStatus || input.barShowSystemStatus !== undefined) {
            var legacyVisibility = legacyStatus || {}
            var legacyVisible = booleanValue(input.barShowSystemStatus, true)
            input.barShowNetworkStatus = legacyVisible
                && booleanValue(legacyVisibility.showNetwork, true)
            input.barShowAudioStatus = legacyVisible
                && booleanValue(legacyVisibility.showAudio, true)
            input.barShowBatteryStatus = legacyVisible
                && booleanValue(legacyVisibility.showBattery, true)
        }

        delete existingWidgetSettings["system-status"]
        input.barWidgetSettings = existingWidgetSettings

        var oldRightOrder = arrayValue(input.barRightWidgetOrder)
        var splitRightOrder = []

        for (var orderIndex = 0;
            orderIndex < oldRightOrder.length;
            ++orderIndex) {
            var orderedId = String(oldRightOrder[orderIndex] || "")

            if (orderedId === "system-status") {
                splitRightOrder.push("network")
                splitRightOrder.push("audio")
                splitRightOrder.push("battery")
            } else {
                splitRightOrder.push(orderedId)
            }
        }

        input.barRightWidgetOrder = splitRightOrder
        delete input.barShowSystemStatus
    }

    return normalize(input)
}

function defaultsForCategory(categoryName) {
    var base = defaults()
    var category = String(categoryName || "")
    var prefixes = {
        appearance: [
            "themeMode",
            "dynamicTheme",
            "paletteStyle",
            "shellBackgroundMode",
            "shellSurfaceOpacity",
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
            "barBackgroundMode",
            "barSurfaceOpacity",
            "barAutoScaleContents",
            "barContentScale",
            "barPosition",
            "barHeight",
            "barMargin",
            "barPanelGap",
            "barWidgetSpacing",
            "barShowLauncher",
            "barShowOverview",
            "barShowWorkspaces",
            "barShowKeyboardLayout",
            "barShowPrivacyIndicators",
            "barShowTray",
            "barShowNotifications",
            "barShowDashboardButton",
            "barShowNetworkStatus",
            "barShowAudioStatus",
            "barShowBatteryStatus",
            "barShowWallpaperButton",
            "barShowSessionButton",
            "barShowClock",
            "barLeftWidgetOrder",
            "barRightWidgetOrder",
            "barWidgetSettings",
            "showStatusDetails"
        ],
        dashboard: [
            "dashboardDefaultPage",
            "dashboardRememberPage",
            "dashboardRememberCategory",
            "dashboardDensity",
            "dashboardUseUserAvatarImage",
            "dashboardUserAvatarPath",
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

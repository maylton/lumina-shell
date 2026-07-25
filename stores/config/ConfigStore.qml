pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "ConfigSchema.js" as ConfigSchema

Singleton {
    id: root

    readonly property int currentSchemaVersion:
        ConfigSchema.CURRENT_VERSION
    readonly property string statePath: {
        const overridePath = Quickshell.env("LUMINA_STATE_PATH")
        return overridePath
            ? String(overridePath)
            : Quickshell.stateDir + "/lumina-state.json"
    }
    readonly property string recoveryBackupPath: statePath + ".invalid"
    readonly property string saveStatusLabel:
        lastError && !lastSaveSucceeded
        ? "Could not save"
        : saving || dirty
            ? "Saving…"
            : "Saved"

    property alias schemaVersion: stateAdapter.schemaVersion
    property alias doNotDisturb: stateAdapter.doNotDisturb
    property alias dynamicTheme: stateAdapter.dynamicTheme
    property alias paletteStyle: stateAdapter.paletteStyle
    property alias wallpapers: stateAdapter.wallpapers
    property alias defaultWallpaper: stateAdapter.defaultWallpaper
    property alias wallpaperDirectory: stateAdapter.wallpaperDirectory
    property alias osdEnabled: stateAdapter.osdEnabled
    property alias osdDuration: stateAdapter.osdDuration
    property alias showStatusDetails: stateAdapter.showStatusDetails
    property alias themeMode: stateAdapter.themeMode
    property alias transparencyEnabled:
        stateAdapter.transparencyEnabled
    property alias surfaceOpacity: stateAdapter.surfaceOpacity
    property alias animationsEnabled: stateAdapter.animationsEnabled
    property alias animationScale: stateAdapter.animationScale
    property alias cornerRadiusScale: stateAdapter.cornerRadiusScale
    property alias compactMode: stateAdapter.compactMode
    property alias barSurfaceMode: stateAdapter.barSurfaceMode
    property alias barContextMode: stateAdapter.barContextMode
    property alias barContextTimeout: stateAdapter.barContextTimeout
    property alias barStatusLayout: stateAdapter.barStatusLayout
    property alias barPosition: stateAdapter.barPosition
    property alias barHeight: stateAdapter.barHeight
    property alias barMargin: stateAdapter.barMargin
    property alias barWidgetSpacing: stateAdapter.barWidgetSpacing
    property alias barShowLauncher: stateAdapter.barShowLauncher
    property alias barShowOverview: stateAdapter.barShowOverview
    property alias barShowWindowTitle:
        stateAdapter.barShowWindowTitle
    property alias barCenterWindowTitle:
        stateAdapter.barCenterWindowTitle
    property alias barShowAppId: stateAdapter.barShowAppId
    property alias barShowWorkspaces: stateAdapter.barShowWorkspaces
    property alias barShowColumnIndicator:
        stateAdapter.barShowColumnIndicator
    property alias barShowDate: stateAdapter.barShowDate
    property alias barDateStyle: stateAdapter.barDateStyle
    property alias barShowKeyboardLayout:
        stateAdapter.barShowKeyboardLayout
    property alias barShowPrivacyIndicators:
        stateAdapter.barShowPrivacyIndicators
    property alias barShowTray: stateAdapter.barShowTray
    property alias barShowNotifications:
        stateAdapter.barShowNotifications
    property alias barShowDashboardButton:
        stateAdapter.barShowDashboardButton
    property alias barShowAudioStatus:
        stateAdapter.barShowAudioStatus
    property alias barShowNetworkStatus:
        stateAdapter.barShowNetworkStatus
    property alias barShowBatteryStatus:
        stateAdapter.barShowBatteryStatus
    property alias barShowWallpaperButton:
        stateAdapter.barShowWallpaperButton
    property alias barShowSessionButton:
        stateAdapter.barShowSessionButton
    property alias barShowClock: stateAdapter.barShowClock
    property alias barClock24Hour: stateAdapter.barClock24Hour
    property alias barShowSeconds: stateAdapter.barShowSeconds
    property alias barLeftWidgetOrder:
        stateAdapter.barLeftWidgetOrder
    property alias barRightWidgetOrder:
        stateAdapter.barRightWidgetOrder
    property alias dashboardDefaultPage:
        stateAdapter.dashboardDefaultPage
    property alias dashboardRememberPage:
        stateAdapter.dashboardRememberPage
    property alias dashboardRememberCategory:
        stateAdapter.dashboardRememberCategory
    property alias dashboardDensity: stateAdapter.dashboardDensity
    property alias dashboardShowWeather:
        stateAdapter.dashboardShowWeather
    property alias dashboardShowCalendar:
        stateAdapter.dashboardShowCalendar
    property alias dashboardShowMedia:
        stateAdapter.dashboardShowMedia
    property alias dashboardShowNotifications:
        stateAdapter.dashboardShowNotifications
    property alias dashboardShowSystem:
        stateAdapter.dashboardShowSystem
    property alias dashboardShowOverview:
        stateAdapter.dashboardShowOverview
    property alias dashboardShowControls:
        stateAdapter.dashboardShowControls
    property alias dashboardShowSessionActions:
        stateAdapter.dashboardShowSessionActions
    property alias dashboardCardOrder:
        stateAdapter.dashboardCardOrder
    property alias behaviorCloseOnOutside:
        stateAdapter.behaviorCloseOnOutside
    property alias behaviorCloseAfterAction:
        stateAdapter.behaviorCloseAfterAction
    property alias behaviorOpenOnActiveOutput:
        stateAdapter.behaviorOpenOnActiveOutput
    property alias behaviorTransitionScale:
        stateAdapter.behaviorTransitionScale
    property alias reduceMotion: stateAdapter.reduceMotion
    property alias destructiveConfirmations:
        stateAdapter.destructiveConfirmations
    property alias notificationPopupPosition:
        stateAdapter.notificationPopupPosition
    property alias notificationPopupDuration:
        stateAdapter.notificationPopupDuration
    property alias notificationPopupMaximum:
        stateAdapter.notificationPopupMaximum
    property alias notificationShowImages:
        stateAdapter.notificationShowImages
    property alias notificationKeepHistory:
        stateAdapter.notificationKeepHistory
    property alias notificationClearHistoryOnExit:
        stateAdapter.notificationClearHistoryOnExit
    property alias notificationPreferredOutput:
        stateAdapter.notificationPreferredOutput
    property alias osdPosition: stateAdapter.osdPosition
    property alias osdSize: stateAdapter.osdSize
    property alias osdShowPercentage:
        stateAdapter.osdShowPercentage
    property alias osdVolumeEnabled:
        stateAdapter.osdVolumeEnabled
    property alias osdMicrophoneEnabled:
        stateAdapter.osdMicrophoneEnabled
    property alias osdBrightnessEnabled:
        stateAdapter.osdBrightnessEnabled
    property alias osdPowerEnabled: stateAdapter.osdPowerEnabled
    property alias osdPreferredOutput:
        stateAdapter.osdPreferredOutput
    property alias sessionConfirmLogout:
        stateAdapter.sessionConfirmLogout
    property alias sessionConfirmReboot:
        stateAdapter.sessionConfirmReboot
    property alias sessionConfirmPoweroff:
        stateAdapter.sessionConfirmPoweroff
    property alias sessionShowSuspend:
        stateAdapter.sessionShowSuspend
    property alias sessionShowLock: stateAdapter.sessionShowLock
    property alias lastSettingsCategory:
        stateAdapter.lastSettingsCategory
    property alias lastControlPage: stateAdapter.lastControlPage

    property bool initialized: false
    property bool dirty: false
    property bool saving: false
    property double lastSavedAt: 0
    property bool lastSaveSucceeded: true
    property string lastError: ""
    property bool recoveredInvalidConfiguration: false

    function cloneMap(source) {
        const result = {}

        if (!source || typeof source !== "object")
            return result

        for (const key in source)
            result[key] = source[key]

        return result
    }

    function cloneList(source) {
        const result = []

        if (!source
            || typeof source === "string"
            || typeof source.length !== "number")
            return result

        for (var index = 0; index < source.length; ++index)
            result.push(source[index])

        return result
    }

    function snapshot() {
        const result = {}
        const defaults = ConfigSchema.defaults()

        for (const key in defaults)
            result[key] = stateAdapter[key]

        return result
    }

    function applyValues(values) {
        for (const key in values) {
            if (stateAdapter[key] !== undefined)
                stateAdapter[key] = values[key]
        }
    }

    function migrate() {
        const normalized = ConfigSchema.migrate(snapshot())
        const before = JSON.stringify(snapshot())

        applyValues(normalized)

        if (before !== JSON.stringify(snapshot()))
            scheduleSave()
    }

    function finishLoad() {
        initialized = true
        dirty = false
        migrate()
    }

    function validateLoadedState() {
        const rawText = stateFile.text()

        if (String(rawText || "").trim()) {
            try {
                JSON.parse(rawText)
            } catch (error) {
                recoverInvalidConfiguration("Invalid JSON: " + error)
                return
            }
        }

        finishLoad()
    }

    function scheduleSave() {
        if (!initialized)
            return

        dirty = true
        lastError = ""
        saveTimer.restart()
    }

    function saveNow() {
        if (!initialized)
            return

        saveTimer.stop()
        saving = true
        saveSettleTimer.restart()
        stateFile.writeAdapter()
    }

    function setValue(key, value) {
        const candidate = snapshot()
        candidate[key] = value
        const normalized = ConfigSchema.normalize(candidate)

        if (stateAdapter[key] === normalized[key])
            return

        stateAdapter[key] = normalized[key]
        scheduleSave()
    }

    function setDoNotDisturb(value) {
        setValue("doNotDisturb", Boolean(value))
    }

    function setDynamicTheme(value) {
        setValue("dynamicTheme", Boolean(value))
    }

    function setPaletteStyle(value) {
        setValue("paletteStyle", String(value || "auto"))
    }

    function setWallpapers(value) {
        setValue("wallpapers", cloneMap(value))
    }

    function setDefaultWallpaper(value) {
        setValue("defaultWallpaper", String(value || ""))
    }

    function setWallpaperDirectory(value) {
        setValue("wallpaperDirectory", String(value || ""))
    }

    function setOsdEnabled(value) {
        setValue("osdEnabled", Boolean(value))
    }

    function setOsdDuration(value) {
        setValue("osdDuration", Number(value))
    }

    function setShowStatusDetails(value) {
        setValue("showStatusDetails", Boolean(value))
    }

    function setThemeMode(value) {
        setValue("themeMode", value)
    }

    function setAppearanceValue(key, value) {
        if ([
            "transparencyEnabled",
            "surfaceOpacity",
            "animationsEnabled",
            "animationScale",
            "cornerRadiusScale",
            "compactMode"
        ].indexOf(String(key)) >= 0)
            setValue(key, value)
    }

    function setBarValue(key, value) {
        if (String(key).indexOf("bar") === 0
            || key === "showStatusDetails")
            setValue(key, value)
    }

    function barVisibilityKeys(widgetId) {
        const keys = {
            launcher: ["barShowLauncher"],
            overview: ["barShowOverview"],
            workspaces: ["barShowWorkspaces"],
            datetime: ["barShowClock"],
            privacy: ["barShowPrivacyIndicators"],
            keyboard: ["barShowKeyboardLayout"],
            tray: ["barShowTray"],
            notifications: ["barShowNotifications"],
            "system-status": [
                "barShowAudioStatus",
                "barShowNetworkStatus",
                "barShowBatteryStatus"
            ],
            dashboard: ["barShowDashboardButton"],
            wallpaper: ["barShowWallpaperButton"],
            session: ["barShowSessionButton"]
        }

        return keys[String(widgetId || "")] || []
    }

    function setBarWidgetVisible(widgetId, visible) {
        const id = String(widgetId || "")
        const keys = barVisibilityKeys(id)

        for (var index = 0; index < keys.length; ++index)
            setValue(keys[index], Boolean(visible))

        if (Boolean(visible)
            && ["wallpaper", "session"].indexOf(id) >= 0
            && barRightWidgetOrder.indexOf(id) < 0) {
            const next = cloneList(barRightWidgetOrder)
            next.push(id)
            setValue("barRightWidgetOrder", next)
        }
    }

    function barWidgetVisible(widgetId) {
        const keys = barVisibilityKeys(widgetId)

        if (keys.length === 0)
            return false

        for (var index = 0; index < keys.length; ++index) {
            if (Boolean(stateAdapter[keys[index]]))
                return true
        }

        return false
    }

    function moveBarWidget(side, widgetId, offset) {
        const key = String(side) === "left"
            ? "barLeftWidgetOrder"
            : String(side) === "right"
                ? "barRightWidgetOrder"
                : ""

        if (!key)
            return

        const order = cloneList(stateAdapter[key])
        const currentIndex = order.indexOf(String(widgetId || ""))
        const targetIndex = Math.max(
            0,
            Math.min(
                order.length - 1,
                currentIndex + Number(offset || 0)
            )
        )

        if (currentIndex < 0 || targetIndex === currentIndex)
            return

        const moved = order.splice(currentIndex, 1)[0]
        order.splice(targetIndex, 0, moved)
        setValue(key, order)
    }

    function setDashboardValue(key, value) {
        if (String(key).indexOf("dashboard") === 0)
            setValue(key, value)
    }

    function setBehaviorValue(key, value) {
        if (String(key).indexOf("behavior") === 0
            || key === "reduceMotion"
            || key === "destructiveConfirmations")
            setValue(key, value)
    }

    function setNotificationValue(key, value) {
        if (String(key).indexOf("notification") === 0
            || key === "doNotDisturb")
            setValue(key, value)
    }

    function setOsdValue(key, value) {
        if (String(key).indexOf("osd") === 0)
            setValue(key, value)
    }

    function setSessionValue(key, value) {
        if (String(key).indexOf("session") === 0)
            setValue(key, value)
    }

    function setLastSettingsCategory(value) {
        setValue("lastSettingsCategory", value)
    }

    function setLastControlPage(value) {
        setValue("lastControlPage", value)
    }

    function resetCategory(categoryName) {
        const values = ConfigSchema.defaultsForCategory(categoryName)

        applyValues(values)
        scheduleSave()
    }

    function resetAll() {
        applyValues(ConfigSchema.defaults())
        scheduleSave()
    }

    function reset() {
        resetAll()
    }

    function recoverInvalidConfiguration(error) {
        const rawText = stateFile.text()
        const errorText = typeof error === "string"
            ? error
            : FileViewError.toString(error)

        if (rawText)
            recoveryFile.setText(rawText)

        applyValues(ConfigSchema.defaults())
        initialized = true
        recoveredInvalidConfiguration = true
        lastError = "Invalid configuration recovered: " + errorText
        dirty = true
        saveTimer.restart()
        console.warn(
            "Lumina configuration:",
            lastError,
            "Backup:",
            recoveryBackupPath
        )
    }

    FileView {
        id: stateFile

        path: root.statePath
        preload: true
        atomicWrites: true
        watchChanges: false
        printErrors: false

        adapter: JsonAdapter {
            id: stateAdapter

            property int schemaVersion:
                ConfigSchema.CURRENT_VERSION
            property bool doNotDisturb: false
            property bool dynamicTheme: true
            property string paletteStyle: "auto"
            property var wallpapers: ({})
            property string defaultWallpaper:
                "/usr/share/wallpapers/cachyos-wallpapers/Abstract.png"
            property string wallpaperDirectory:
                "/usr/share/wallpapers/cachyos-wallpapers"
            property bool osdEnabled: true
            property int osdDuration: 1800
            property bool showStatusDetails: true
            property string themeMode: "auto"
            property bool transparencyEnabled: false
            property real surfaceOpacity: 0.96
            property bool animationsEnabled: true
            property real animationScale: 1
            property real cornerRadiusScale: 1
            property bool compactMode: false
            property string barSurfaceMode: "edge-to-edge"
            property string barContextMode: "contextual"
            property int barContextTimeout: 3500
            property string barStatusLayout: "grouped"
            property string barPosition: "top"
            property int barHeight: 48
            property int barMargin: 5
            property int barWidgetSpacing: 10
            property bool barShowLauncher: true
            property bool barShowOverview: true
            property bool barShowWindowTitle: true
            property bool barCenterWindowTitle: true
            property bool barShowAppId: true
            property bool barShowWorkspaces: true
            property bool barShowColumnIndicator: true
            property bool barShowDate: true
            property string barDateStyle: "short"
            property bool barShowKeyboardLayout: true
            property bool barShowPrivacyIndicators: true
            property bool barShowTray: true
            property bool barShowNotifications: true
            property bool barShowDashboardButton: true
            property bool barShowAudioStatus: true
            property bool barShowNetworkStatus: true
            property bool barShowBatteryStatus: true
            property bool barShowWallpaperButton: false
            property bool barShowSessionButton: false
            property bool barShowClock: true
            property bool barClock24Hour: true
            property bool barShowSeconds: false
            property var barLeftWidgetOrder:
                ConfigSchema.defaults().barLeftWidgetOrder
            property var barRightWidgetOrder:
                ConfigSchema.defaults().barRightWidgetOrder
            property string dashboardDefaultPage: "dashboard"
            property bool dashboardRememberPage: true
            property bool dashboardRememberCategory: true
            property string dashboardDensity: "comfortable"
            property bool dashboardShowWeather: true
            property bool dashboardShowCalendar: true
            property bool dashboardShowMedia: true
            property bool dashboardShowNotifications: true
            property bool dashboardShowSystem: true
            property bool dashboardShowOverview: true
            property bool dashboardShowControls: true
            property bool dashboardShowSessionActions: true
            property var dashboardCardOrder:
                ConfigSchema.defaults().dashboardCardOrder
            property bool behaviorCloseOnOutside: true
            property bool behaviorCloseAfterAction: false
            property bool behaviorOpenOnActiveOutput: true
            property real behaviorTransitionScale: 1
            property bool reduceMotion: false
            property bool destructiveConfirmations: true
            property string notificationPopupPosition: "top-right"
            property int notificationPopupDuration: 6000
            property int notificationPopupMaximum: 3
            property bool notificationShowImages: true
            property bool notificationKeepHistory: true
            property bool notificationClearHistoryOnExit: false
            property string notificationPreferredOutput: "active"
            property string osdPosition: "bottom"
            property real osdSize: 1
            property bool osdShowPercentage: true
            property bool osdVolumeEnabled: true
            property bool osdMicrophoneEnabled: true
            property bool osdBrightnessEnabled: true
            property bool osdPowerEnabled: true
            property string osdPreferredOutput: "active"
            property bool sessionConfirmLogout: true
            property bool sessionConfirmReboot: true
            property bool sessionConfirmPoweroff: true
            property bool sessionShowSuspend: true
            property bool sessionShowLock: true
            property string lastSettingsCategory: "appearance"
            property string lastControlPage: "dashboard"
        }

        onLoaded: root.validateLoadedState()

        onLoadFailed: error => {
            if (error !== FileViewError.FileNotFound) {
                root.recoverInvalidConfiguration(error)
                return
            }

            root.finishLoad()
            root.scheduleSave()
        }

        onSaveFailed: error => {
            saveSettleTimer.stop()
            root.saving = false
            root.dirty = true
            root.lastSaveSucceeded = false
            root.lastError = "Failed to save state: "
                + FileViewError.toString(error)
            console.warn("Lumina configuration:", root.lastError)
        }

        onSaved: {
            saveSettleTimer.stop()
            root.saving = false
            root.dirty = false
            root.lastSavedAt = Date.now()
            root.lastSaveSucceeded = true

            if (!root.recoveredInvalidConfiguration)
                root.lastError = ""
        }
    }

    FileView {
        id: recoveryFile

        path: root.recoveryBackupPath
        atomicWrites: true
        printErrors: false
    }

    Timer {
        id: saveTimer

        interval: 220
        repeat: false
        onTriggered: root.saveNow()
    }

    Timer {
        id: saveSettleTimer

        interval: 1200
        repeat: false
        onTriggered: {
            if (!root.saving || !root.lastSaveSucceeded)
                return

            // FileView may coalesce an unchanged adapter write without
            // emitting saved. Treat that no-op as settled, not perpetually
            // saving.
            root.saving = false
            root.dirty = false
            root.lastSavedAt = Date.now()
        }
    }

    IpcHandler {
        target: "config"

        function reset(): void {
            root.resetAll()
        }

        function resetCategory(categoryName: string): void {
            root.resetCategory(categoryName)
        }

        function save(): void {
            root.saveNow()
        }

        function osd(enabled: bool): void {
            root.setOsdEnabled(enabled)
        }

        function osdDuration(milliseconds: int): void {
            root.setOsdDuration(milliseconds)
        }

        function statusDetails(enabled: bool): void {
            root.setShowStatusDetails(enabled)
        }

        function status(): string {
            return JSON.stringify({
                schemaVersion: root.schemaVersion,
                path: root.statePath,
                initialized: root.initialized,
                dirty: root.dirty,
                saving: root.saving,
                lastSavedAt: root.lastSavedAt,
                lastSaveSucceeded: root.lastSaveSucceeded,
                saveStatus: root.saveStatusLabel,
                recovered: root.recoveredInvalidConfiguration,
                recoveryBackupPath:
                    root.recoveredInvalidConfiguration
                        ? root.recoveryBackupPath
                        : "",
                lastError: root.lastError,
                themeMode: root.themeMode,
                dynamicTheme: root.dynamicTheme,
                paletteStyle: root.paletteStyle,
                barPosition: root.barPosition,
                barSurfaceMode: root.barSurfaceMode,
                barContextMode: root.barContextMode,
                barStatusLayout: root.barStatusLayout,
                dashboardDefaultPage: root.dashboardDefaultPage,
                doNotDisturb: root.doNotDisturb,
                osdEnabled: root.osdEnabled,
                osdDuration: root.osdDuration,
                wallpaperDirectory: root.wallpaperDirectory
            })
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int currentSchemaVersion: 3
    readonly property string statePath: {
        const overridePath = Quickshell.env("LUMINA_STATE_PATH")

        return overridePath
            ? String(overridePath)
            : Quickshell.stateDir + "/lumina-state.json"
    }

    property alias schemaVersion: stateAdapter.schemaVersion
    property alias doNotDisturb: stateAdapter.doNotDisturb
    property alias dynamicTheme: stateAdapter.dynamicTheme
    property alias wallpapers: stateAdapter.wallpapers
    property alias defaultWallpaper: stateAdapter.defaultWallpaper
    property alias wallpaperDirectory: stateAdapter.wallpaperDirectory
    property alias osdEnabled: stateAdapter.osdEnabled
    property alias osdDuration: stateAdapter.osdDuration
    property alias showStatusDetails: stateAdapter.showStatusDetails
    property bool initialized: false
    property string lastError: ""
    property bool recoveredInvalidConfiguration: false
    readonly property string recoveryBackupPath: statePath + ".invalid"

    function cloneMap(source) {
        const result = {}

        if (!source || typeof source !== "object")
            return result

        for (const key in source)
            result[key] = source[key]

        return result
    }

    function migrate() {
        var changed = false

        if (typeof stateAdapter.wallpapers === "string") {
            stateAdapter.defaultWallpaper = stateAdapter.wallpapers
            stateAdapter.wallpapers = {}
            changed = true
        } else if (!stateAdapter.wallpapers
            || Array.isArray(stateAdapter.wallpapers)
            || typeof stateAdapter.wallpapers !== "object") {
            stateAdapter.wallpapers = {}
            changed = true
        }

        if (!stateAdapter.wallpaperDirectory) {
            stateAdapter.wallpaperDirectory =
                "/usr/share/wallpapers/cachyos-wallpapers"
            changed = true
        }

        if (stateAdapter.osdDuration < 800
            || stateAdapter.osdDuration > 5000) {
            stateAdapter.osdDuration = 1800
            changed = true
        }

        if (stateAdapter.schemaVersion !== currentSchemaVersion) {
            stateAdapter.schemaVersion = currentSchemaVersion
            changed = true
        }

        if (changed)
            saveTimer.restart()
    }

    function finishLoad() {
        initialized = true
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
        if (initialized)
            saveTimer.restart()
    }

    function setDoNotDisturb(enabled) {
        stateAdapter.doNotDisturb = Boolean(enabled)
        scheduleSave()
    }

    function setDynamicTheme(enabled) {
        stateAdapter.dynamicTheme = Boolean(enabled)
        scheduleSave()
    }

    function setWallpapers(value) {
        stateAdapter.wallpapers = cloneMap(value)
        scheduleSave()
    }

    function setDefaultWallpaper(value) {
        stateAdapter.defaultWallpaper = String(value || "")
        scheduleSave()
    }

    function setWallpaperDirectory(value) {
        stateAdapter.wallpaperDirectory = String(value || "")
        scheduleSave()
    }

    function setOsdEnabled(enabled) {
        stateAdapter.osdEnabled = Boolean(enabled)
        scheduleSave()
    }

    function setOsdDuration(value) {
        stateAdapter.osdDuration = Math.max(
            800,
            Math.min(5000, Math.round(Number(value) || 1800))
        )
        scheduleSave()
    }

    function setShowStatusDetails(enabled) {
        stateAdapter.showStatusDetails = Boolean(enabled)
        scheduleSave()
    }

    function applyDefaults() {
        stateAdapter.schemaVersion = currentSchemaVersion
        stateAdapter.doNotDisturb = false
        stateAdapter.dynamicTheme = true
        stateAdapter.wallpapers = {}
        stateAdapter.defaultWallpaper =
            "/usr/share/wallpapers/cachyos-wallpapers/Abstract.png"
        stateAdapter.wallpaperDirectory =
            "/usr/share/wallpapers/cachyos-wallpapers"
        stateAdapter.osdEnabled = true
        stateAdapter.osdDuration = 1800
        stateAdapter.showStatusDetails = true
    }

    function reset() {
        applyDefaults()
        scheduleSave()
    }

    function recoverInvalidConfiguration(error) {
        const rawText = stateFile.text()
        const errorText = typeof error === "string"
            ? error
            : FileViewError.toString(error)

        if (rawText)
            recoveryFile.setText(rawText)

        applyDefaults()
        initialized = true
        recoveredInvalidConfiguration = true
        lastError = "Invalid configuration recovered: "
            + errorText
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

            property int schemaVersion: root.currentSchemaVersion
            property bool doNotDisturb: false
            property bool dynamicTheme: true
            property var wallpapers: ({})
            property string defaultWallpaper:
                "/usr/share/wallpapers/cachyos-wallpapers/Abstract.png"
            property string wallpaperDirectory:
                "/usr/share/wallpapers/cachyos-wallpapers"
            property bool osdEnabled: true
            property int osdDuration: 1800
            property bool showStatusDetails: true
        }

        onLoaded: root.validateLoadedState()

        onLoadFailed: error => {
            if (error !== FileViewError.FileNotFound) {
                root.recoverInvalidConfiguration(error)
                return
            }

            root.finishLoad()
        }

        onSaveFailed: error => {
            root.lastError = "Failed to save state: "
                + FileViewError.toString(error)
            console.warn("Lumina configuration:", root.lastError)
        }

        onSaved: {
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

        interval: 120
        repeat: false
        onTriggered: stateFile.writeAdapter()
    }

    IpcHandler {
        target: "config"

        function reset(): void {
            root.reset()
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
                recovered: root.recoveredInvalidConfiguration,
                recoveryBackupPath: root.recoveredInvalidConfiguration
                    ? root.recoveryBackupPath
                    : "",
                lastError: root.lastError,
                doNotDisturb: root.doNotDisturb,
                dynamicTheme: root.dynamicTheme,
                osdEnabled: root.osdEnabled,
                osdDuration: root.osdDuration,
                showStatusDetails: root.showStatusDetails,
                wallpaperDirectory: root.wallpaperDirectory
            })
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int currentSchemaVersion: 2
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
    property bool initialized: false
    property string lastError: ""

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
        }

        onLoaded: root.finishLoad()

        onLoadFailed: error => {
            if (error !== FileViewError.FileNotFound) {
                root.lastError = "Failed to load state: "
                    + FileViewError.toString(error)
            }

            root.finishLoad()
        }

        onSaveFailed: error => {
            root.lastError = "Failed to save state: "
                + FileViewError.toString(error)
            console.warn("Lumina configuration:", root.lastError)
        }

        onSaved: root.lastError = ""
    }

    Timer {
        id: saveTimer

        interval: 120
        repeat: false
        onTriggered: stateFile.writeAdapter()
    }
}

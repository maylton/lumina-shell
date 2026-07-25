pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "DockPreferences.js" as DockPreferencesLogic

Singleton {
    id: root

    readonly property string statePath:
        Quickshell.stateDir + "/lumina-dock.json"

    property alias schemaVersion: adapter.schemaVersion
    property alias enabled: adapter.enabled
    property alias autoHide: adapter.autoHide
    property alias showRunning: adapter.showRunning
    property alias reserveSpace: adapter.reserveSpace
    property alias iconSize: adapter.iconSize
    property alias margin: adapter.margin
    property alias favoriteAppIds: adapter.favoriteAppIds

    property bool initialized: false
    property bool dirty: false
    property bool saving: false
    property string lastError: ""

    function snapshot() {
        return {
            schemaVersion: adapter.schemaVersion,
            enabled: adapter.enabled,
            autoHide: adapter.autoHide,
            showRunning: adapter.showRunning,
            reserveSpace: adapter.reserveSpace,
            iconSize: adapter.iconSize,
            margin: adapter.margin,
            favoriteAppIds: adapter.favoriteAppIds
        }
    }

    function equivalent(left, right) {
        if (Array.isArray(left) || Array.isArray(right))
            return JSON.stringify(left || []) === JSON.stringify(right || [])

        return left === right
    }

    function applyValues(values) {
        adapter.schemaVersion = values.schemaVersion
        adapter.enabled = values.enabled
        adapter.autoHide = values.autoHide
        adapter.showRunning = values.showRunning
        adapter.reserveSpace = values.reserveSpace
        adapter.iconSize = values.iconSize
        adapter.margin = values.margin
        adapter.favoriteAppIds = values.favoriteAppIds
    }

    function finishLoad(source) {
        applyValues(DockPreferencesLogic.normalize(source))
        initialized = true
        dirty = false
    }

    function scheduleSave() {
        if (!initialized)
            return

        dirty = true
        lastError = ""
        saveTimer.restart()
    }

    function setValue(key, value) {
        const candidate = snapshot()
        candidate[key] = value
        const normalized = DockPreferencesLogic.normalize(candidate)

        if (equivalent(adapter[key], normalized[key]))
            return

        adapter[key] = normalized[key]
        scheduleSave()
    }

    function setEnabled(value) {
        setValue("enabled", Boolean(value))
    }

    function setAutoHide(value) {
        setValue("autoHide", Boolean(value))
    }

    function setShowRunning(value) {
        setValue("showRunning", Boolean(value))
    }

    function setReserveSpace(value) {
        setValue("reserveSpace", Boolean(value))
    }

    function setIconSize(value) {
        setValue("iconSize", Number(value))
    }

    function setMargin(value) {
        setValue("margin", Number(value))
    }

    function pin(identifier) {
        const requested = String(identifier || "").trim()
        if (!requested)
            return

        setValue("favoriteAppIds", favoriteAppIds.concat([requested]))
    }

    function unpin(identifier) {
        const requested = String(identifier || "").trim()
        const next = []

        for (var index = 0; index < favoriteAppIds.length; ++index) {
            if (String(favoriteAppIds[index]) !== requested)
                next.push(favoriteAppIds[index])
        }

        setValue("favoriteAppIds", next)
    }

    function toggleFavorite(identifier) {
        const requested = String(identifier || "").trim()
        if (!requested)
            return

        if (favoriteAppIds.indexOf(requested) >= 0)
            unpin(requested)
        else
            pin(requested)
    }

    function clearFavorites() {
        setValue("favoriteAppIds", [])
    }

    function reset() {
        applyValues(DockPreferencesLogic.defaults())
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
            id: adapter

            property int schemaVersion: DockPreferencesLogic.CURRENT_VERSION
            property bool enabled: false
            property bool autoHide: true
            property bool showRunning: true
            property bool reserveSpace: false
            property int iconSize: 50
            property int margin: 10
            property var favoriteAppIds: []
        }

        onLoaded: {
            try {
                root.finishLoad(JSON.parse(text()))
            } catch (error) {
                root.lastError = "Invalid dock preferences: " + error
                root.finishLoad(DockPreferencesLogic.defaults())
                root.scheduleSave()
            }
        }

        onLoadFailed: error => {
            if (error !== FileViewError.FileNotFound)
                root.lastError = FileViewError.toString(error)

            root.finishLoad(DockPreferencesLogic.defaults())
            root.scheduleSave()
        }

        onSaveFailed: error => {
            root.saving = false
            root.dirty = true
            root.lastError = FileViewError.toString(error)
        }

        onSaved: {
            root.saving = false
            root.dirty = false
            root.lastError = ""
        }
    }

    Timer {
        id: saveTimer

        interval: 220
        repeat: false
        onTriggered: {
            root.saving = true
            stateFile.writeAdapter()
        }
    }
}

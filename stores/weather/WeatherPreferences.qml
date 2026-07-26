pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "WeatherPreferences.js" as WeatherLogic

Singleton {
    id: root

    readonly property string statePath:
        Quickshell.stateDir + "/lumina-weather.json"

    property alias schemaVersion: adapter.schemaVersion
    property alias locationMode: adapter.locationMode
    property alias manualCity: adapter.manualCity
    property alias refreshInterval: adapter.refreshInterval

    property bool initialized: false
    property bool dirty: false
    property bool saving: false
    property string lastError: ""

    function snapshot() {
        return {
            schemaVersion: adapter.schemaVersion,
            locationMode: adapter.locationMode,
            manualCity: adapter.manualCity,
            refreshInterval: adapter.refreshInterval
        }
    }

    function applyValues(values) {
        adapter.schemaVersion = values.schemaVersion
        adapter.locationMode = values.locationMode
        adapter.manualCity = values.manualCity
        adapter.refreshInterval = values.refreshInterval
    }

    function finishLoad(source) {
        applyValues(WeatherLogic.normalize(source))
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
        const normalized = WeatherLogic.normalize(candidate)

        if (adapter[key] === normalized[key])
            return

        adapter[key] = normalized[key]
        scheduleSave()
    }

    function setLocationMode(value) {
        setValue("locationMode", value)
    }

    function setManualCity(value) {
        setValue("manualCity", value)
    }

    function setRefreshInterval(value) {
        setValue("refreshInterval", Number(value))
    }

    function reset() {
        applyValues(WeatherLogic.defaults())
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

            property int schemaVersion: WeatherLogic.CURRENT_VERSION
            property string locationMode: "automatic-ip"
            property string manualCity: ""
            property int refreshInterval: 30
        }

        onLoaded: {
            try {
                root.finishLoad(JSON.parse(text()))
            } catch (error) {
                root.lastError = "Invalid weather preferences: " + error
                root.finishLoad(WeatherLogic.defaults())
                root.scheduleSave()
            }
        }

        onLoadFailed: error => {
            if (error !== FileViewError.FileNotFound) {
                root.lastError = FileViewError.toString(error)
            }

            root.finishLoad(WeatherLogic.defaults())
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

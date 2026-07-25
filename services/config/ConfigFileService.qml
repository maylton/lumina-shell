pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.stores.config

Singleton {
    id: root

    readonly property bool running: openProcess.running
    readonly property string configPath: ConfigStore.statePath
    readonly property string configDirectory: {
        const path = configPath
        const separator = path.lastIndexOf("/")
        return separator > 0 ? path.slice(0, separator) : path
    }

    property string lastError: ""

    function ensureConfigExists() {
        ConfigStore.saveNow()
    }

    function openConfigFile() {
        ensureConfigExists()
        openPath(configPath)
    }

    function openConfigDirectory() {
        ensureConfigExists()
        openPath(configDirectory)
    }

    function openPath(path) {
        if (running || !String(path || ""))
            return

        lastError = ""
        openProcess.exec(["xdg-open", String(path)])
    }

    Process {
        id: openProcess

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim())
                    root.lastError = text.trim()
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && !root.lastError)
                root.lastError = "xdg-open exited with code " + exitCode
        }
    }

    IpcHandler {
        target: "configFile"

        function open(): void {
            root.openConfigFile()
        }

        function directory(): void {
            root.openConfigDirectory()
        }

        function ensure(): void {
            root.ensureConfigExists()
        }

        function status(): string {
            return JSON.stringify({
                path: root.configPath,
                directory: root.configDirectory,
                running: root.running,
                lastError: root.lastError
            })
        }
    }
}

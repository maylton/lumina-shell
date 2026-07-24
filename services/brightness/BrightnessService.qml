pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool busy: refreshProcess.running || setProcess.running

    property bool available: false
    property int percentage: 0
    property string deviceName: ""
    property string lastError: ""

    signal adjusted(int percentage)

    function parseInfo(rawText) {
        const line = String(rawText || "").trim().split("\n")[0]
        const parts = line.split(",")

        if (parts.length < 5)
            return false

        const parsedPercentage = Number(
            String(parts[3]).replace("%", "")
        )

        if (!isFinite(parsedPercentage))
            return false

        deviceName = String(parts[0])
        percentage = Math.max(0, Math.min(100, parsedPercentage))
        available = true
        lastError = ""
        return true
    }

    function refresh() {
        if (busy)
            return

        refreshProcess.exec([
            "brightnessctl",
            "--class=backlight",
            "--machine-readable",
            "info"
        ])
    }

    function setPercentage(value) {
        if (!available || busy)
            return

        const nextValue = Math.max(
            1,
            Math.min(100, Math.round(Number(value) || 0))
        )

        percentage = nextValue
        adjusted(nextValue)
        setProcess.exec([
            "brightnessctl",
            "--class=backlight",
            "set",
            String(nextValue) + "%"
        ])
    }

    function change(delta) {
        setPercentage(percentage + Number(delta || 0))
    }

    Component.onCompleted: refresh()

    Process {
        id: refreshProcess

        stdout: StdioCollector {
            id: refreshOutput
        }

        stderr: StdioCollector {
            id: refreshError
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && root.parseInfo(refreshOutput.text))
                return

            root.available = false
            root.deviceName = ""
            root.lastError = String(refreshError.text || "").trim()
                || "No backlight device was found"
        }
    }

    Process {
        id: setProcess

        stdout: StdioCollector {
            id: setOutput
        }

        stderr: StdioCollector {
            id: setError
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.lastError = String(setError.text || "").trim()
                    || "Brightness adjustment failed"
            }

            Qt.callLater(root.refresh)
        }
    }

    IpcHandler {
        target: "brightness"

        function set(percent: int): void {
            root.setPercentage(percent)
        }

        function step(percent: int): void {
            root.change(percent)
        }

        function refresh(): void {
            root.refresh()
        }

        function status(): string {
            return JSON.stringify({
                available: root.available,
                busy: root.busy,
                device: root.deviceName,
                percentage: root.percentage,
                error: root.lastError
            })
        }
    }
}

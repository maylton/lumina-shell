pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.stores.shell

Singleton {
    id: root

    readonly property bool open: activeOutputName.length > 0
    readonly property string activeOutputName:
        OverlayStore.activeSurface === "control"
            ? OverlayStore.activeOutputName
            : ""
    readonly property string uptimeLabel: formatUptime(uptimeSeconds)

    property string activeTab: "home"
    property double uptimeSeconds: 0

    function formatUptime(seconds) {
        const totalMinutes = Math.max(
            0,
            Math.floor(Number(seconds || 0) / 60)
        )
        const days = Math.floor(totalMinutes / 1440)
        const hours = Math.floor((totalMinutes % 1440) / 60)
        const minutes = totalMinutes % 60
        const parts = []

        if (days > 0)
            parts.push(days + "d")

        if (hours > 0 || days > 0)
            parts.push(hours + "h")

        parts.push(minutes + "m")
        return parts.join(" ")
    }

    function updateUptime() {
        const value = Number(
            String(uptimeFile.text() || "").trim().split(/\s+/)[0]
        )

        if (isFinite(value))
            uptimeSeconds = value
    }

    function setTab(tabName) {
        const requested = String(tabName || "")

        if (["home", "notifications"].indexOf(requested) >= 0)
            activeTab = requested
    }

    function openFor(outputName) {
        activeTab = "home"
        OverlayStore.openFor("control", outputName)
    }

    function close() {
        OverlayStore.close("control")
    }

    function toggle(outputName) {
        OverlayStore.toggle("control", outputName)
    }

    FileView {
        id: uptimeFile

        path: "/proc/uptime"
        preload: true
        printErrors: false
        onLoaded: root.updateUptime()
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: uptimeFile.reload()
    }
}

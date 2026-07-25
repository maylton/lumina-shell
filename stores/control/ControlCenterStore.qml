pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.stores.config
import qs.stores.shell
import "../config/ConfigSchema.js" as ConfigSchema

Singleton {
    id: root

    readonly property bool open: activeOutputName.length > 0
    readonly property string activeOutputName:
        OverlayStore.activeSurface === "control"
            ? OverlayStore.activeOutputName
            : ""
    readonly property string uptimeLabel: formatUptime(uptimeSeconds)

    property string activePage: ConfigStore.dashboardRememberPage
        ? ConfigStore.lastControlPage
        : ConfigStore.dashboardDefaultPage
    property string settingsCategory:
        ConfigStore.dashboardRememberCategory
            ? ConfigStore.lastSettingsCategory
            : "appearance"
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

    function setPage(pageName) {
        const requested = String(pageName || "")
        const normalized = requested === "home"
            || requested === "notifications"
            ? "dashboard"
            : requested

        if (["dashboard", "settings"].indexOf(normalized) >= 0) {
            activePage = normalized

            if (ConfigStore.dashboardRememberPage)
                ConfigStore.setLastControlPage(normalized)
        }
    }

    function setTab(tabName) {
        setPage(tabName)
    }

    function setSettingsCategory(categoryName) {
        const requested = String(categoryName || "")
        const normalized =
            ConfigSchema.normalizeSettingsCategory(requested)

        if (requested !== "wallpaper"
            && ConfigSchema.settingsCategories()
                .indexOf(requested) < 0) {
            return
        }

        settingsCategory = normalized

        if (ConfigStore.dashboardRememberCategory)
            ConfigStore.setLastSettingsCategory(normalized)
    }

    function openFor(outputName, pageName, categoryName) {
        if (pageName) {
            setPage(pageName)
        } else if (!ConfigStore.dashboardRememberPage) {
            setPage(ConfigStore.dashboardDefaultPage)
        }

        if (categoryName) {
            setSettingsCategory(categoryName)
        } else if (!ConfigStore.dashboardRememberCategory) {
            settingsCategory = "appearance"
        }

        OverlayStore.openFor("control", outputName)
    }

    function close() {
        OverlayStore.close("control")
    }

    function toggle(outputName) {
        if (OverlayStore.isOpenFor("control", outputName)) {
            close()
        } else {
            openFor(outputName)
        }
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

    Connections {
        target: ConfigStore

        function onInitializedChanged() {
            if (!ConfigStore.initialized)
                return

            root.activePage = ConfigStore.dashboardRememberPage
                ? ConfigStore.lastControlPage
                : ConfigStore.dashboardDefaultPage
            root.settingsCategory =
                ConfigStore.dashboardRememberCategory
                    ? ConfigStore.lastSettingsCategory
                    : "appearance"
        }
    }
}

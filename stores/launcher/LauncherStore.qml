pragma Singleton

import QtQuick
import Quickshell
import qs.services.niri
import qs.stores.niri
import qs.stores.session
import qs.stores.shell
import "LauncherSearch.js" as LauncherSearch

Singleton {
    id: root

    readonly property bool open: activeOutputName.length > 0
    readonly property string activeOutputName:
        OverlayStore.activeSurface === "launcher"
            ? OverlayStore.activeOutputName
            : ""
    readonly property var applications: DesktopEntries.applications.values
    readonly property var windows: WindowStore.windows
    readonly property var results: buildResults(query, applications, windows)

    property string query: ""
    property int selectedIndex: 0

    function normalizedText(value) {
        return LauncherSearch.normalizedText(value)
    }

    function searchableText(parts) {
        return LauncherSearch.searchableText(parts)
    }

    function matchScore(needle, title, details) {
        return LauncherSearch.matchScore(needle, title, details)
    }

    function iconForWindow(windowItem) {
        const appId = WindowStore.appIdFor(windowItem)
        const desktopEntry = appId
            ? DesktopEntries.heuristicLookup(appId)
            : null

        return desktopEntry && desktopEntry.icon
            ? String(desktopEntry.icon)
            : "application-x-executable"
    }

    function buildResults(searchText, appEntries, windowEntries) {
        const needle = normalizedText(searchText)
        const matches = []
        const apps = appEntries || []
        const currentWindows = windowEntries || []

        for (var appIndex = 0; appIndex < apps.length; ++appIndex) {
            const entry = apps[appIndex]

            if (!entry || entry.noDisplay)
                continue

            const title = String(entry.name || entry.id || "Application")
            const details = searchableText([
                entry.genericName,
                entry.comment,
                entry.id,
                entry.keywords ? entry.keywords.join(" ") : ""
            ])
            const score = matchScore(needle, title, details)

            if (score < 0)
                continue

            matches.push({
                kind: "application",
                title: title,
                subtitle: String(entry.comment || entry.genericName || entry.id || ""),
                icon: String(entry.icon || "application-x-executable"),
                entry: entry,
                score: score
            })
        }

        if (needle) {
            for (var windowIndex = 0; windowIndex < currentWindows.length; ++windowIndex) {
                const windowItem = currentWindows[windowIndex]
                const windowTitle = WindowStore.titleFor(windowItem)
                const appId = WindowStore.appIdFor(windowItem)
                const windowScore = matchScore(needle, windowTitle, appId)

                if (windowScore < 0)
                    continue

                matches.push({
                    kind: "window",
                    title: windowTitle,
                    subtitle: appId || "Open window",
                    icon: iconForWindow(windowItem),
                    windowId: windowItem.id,
                    score: windowScore + 50
                })
            }
        }

        const shellActions = [
            {
                id: "toggle-overview",
                title: "Toggle overview",
                subtitle: "Niri shell action",
                icon: "view-grid-symbolic"
            },
            {
                id: "focus-column-left",
                title: "Focus column left",
                subtitle: "Niri layout action",
                icon: "go-previous-symbolic"
            },
            {
                id: "focus-column-right",
                title: "Focus column right",
                subtitle: "Niri layout action",
                icon: "go-next-symbolic"
            },
            {
                id: "center-column",
                title: "Center current column",
                subtitle: "Niri layout action",
                icon: "object-align-horizontal-center-symbolic"
            },
            {
                id: "toggle-floating",
                title: "Toggle floating window",
                subtitle: "Niri layout action",
                icon: "window-duplicate-symbolic"
            },
            {
                id: "toggle-fullscreen",
                title: "Toggle fullscreen",
                subtitle: "Niri layout action",
                icon: "view-fullscreen-symbolic"
            },
            {
                id: "session-menu",
                title: "Open session menu",
                subtitle: "Lock, suspend, log out, or power controls",
                icon: "system-shutdown-symbolic"
            }
        ]

        for (var actionIndex = 0; actionIndex < shellActions.length; ++actionIndex) {
            const action = shellActions[actionIndex]
            const actionScore = matchScore(
                needle,
                action.title,
                action.subtitle + " " + action.id
            )

            if (needle && actionScore >= 0) {
                matches.push({
                    kind: "action",
                    title: action.title,
                    subtitle: action.subtitle,
                    icon: action.icon,
                    actionId: action.id,
                    score: actionScore + 25
                })
            }
        }

        return LauncherSearch.finalizeResults(matches)
    }

    function defaultOutputName() {
        const screens = Quickshell.screens

        if (!screens || screens.length === 0)
            return ""

        return String(screens[0].name || "")
    }

    function resolvedOutputName(outputName) {
        const requested = String(outputName || "")
        const screens = Quickshell.screens || []

        for (var i = 0; i < screens.length; ++i) {
            if (String(screens[i].name || "") === requested)
                return requested
        }

        return defaultOutputName()
    }

    function openFor(outputName) {
        const targetOutput = resolvedOutputName(outputName)

        if (!targetOutput)
            return

        query = ""
        selectedIndex = 0
        OverlayStore.openFor("launcher", targetOutput)
    }

    function close() {
        OverlayStore.close("launcher")
        query = ""
        selectedIndex = 0
    }

    function toggle(outputName) {
        const targetOutput = resolvedOutputName(outputName)

        if (open && activeOutputName === targetOutput) {
            close()
            return
        }

        openFor(targetOutput)
    }

    function setQuery(value) {
        query = String(value || "")
        selectedIndex = 0
    }

    function selectNext() {
        if (results.length === 0)
            return

        selectedIndex = (selectedIndex + 1) % results.length
    }

    function selectPrevious() {
        if (results.length === 0)
            return

        selectedIndex = (selectedIndex - 1 + results.length) % results.length
    }

    function execute(result) {
        if (!result)
            return

        const outputName = activeOutputName

        close()

        if (result.kind === "application" && result.entry) {
            result.entry.execute()
        } else if (result.kind === "window") {
            NiriService.focusWindow(result.windowId)
        } else if (result.kind === "action") {
            switch (String(result.actionId)) {
            case "toggle-overview":
                NiriService.toggleOverview()
                break
            case "focus-column-left":
                NiriService.focusColumnLeft()
                break
            case "focus-column-right":
                NiriService.focusColumnRight()
                break
            case "center-column":
                NiriService.centerColumn()
                break
            case "toggle-floating":
                NiriService.toggleFloating()
                break
            case "toggle-fullscreen":
                NiriService.toggleFullscreen()
                break
            case "session-menu":
                SessionMenuStore.openFor(outputName)
                break
            default:
                break
            }
        }
    }

    function executeSelected() {
        if (results.length === 0)
            return

        execute(results[Math.min(selectedIndex, results.length - 1)])
    }

    Connections {
        target: OverlayStore

        function onActiveSurfaceChanged() {
            if (OverlayStore.activeSurface !== "launcher") {
                root.query = ""
                root.selectedIndex = 0
            }
        }
    }
}

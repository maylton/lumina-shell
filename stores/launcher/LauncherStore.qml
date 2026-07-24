pragma Singleton

import QtQuick
import Quickshell
import qs.services.niri
import qs.stores.niri
import qs.stores.session

Singleton {
    id: root

    readonly property bool open: activeOutputName.length > 0
    readonly property var applications: DesktopEntries.applications.values
    readonly property var windows: WindowStore.windows
    readonly property var results: buildResults(query, applications, windows)

    property string activeOutputName: ""
    property string query: ""
    property int selectedIndex: 0

    function normalizedText(value) {
        return String(value || "").toLocaleLowerCase().trim()
    }

    function searchableText(parts) {
        return normalizedText(parts.filter(part => Boolean(part)).join(" "))
    }

    function matchScore(needle, title, details) {
        if (!needle)
            return 1

        const titleText = normalizedText(title)
        const detailText = normalizedText(details)
        const haystack = titleText + " " + detailText
        const tokens = needle.split(/\s+/)

        for (var i = 0; i < tokens.length; ++i) {
            if (haystack.indexOf(tokens[i]) < 0)
                return -1
        }

        if (titleText === needle)
            return 1000

        if (titleText.indexOf(needle) === 0)
            return 800

        if (titleText.indexOf(needle) >= 0)
            return 600

        return 300
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

        matches.sort((left, right) => {
            if (left.score !== right.score)
                return right.score - left.score

            return left.title.localeCompare(right.title)
        })

        return matches.slice(0, 12)
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
        activeOutputName = targetOutput
    }

    function close() {
        activeOutputName = ""
        query = ""
        selectedIndex = 0
    }

    function toggle(outputName) {
        const targetOutput = resolvedOutputName(outputName)

        if (open && activeOutputName === targetOutput)
            close()
        else
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
}

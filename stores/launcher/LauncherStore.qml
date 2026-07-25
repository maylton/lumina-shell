pragma Singleton

import QtQuick
import Quickshell
import qs.services.i18n
import qs.services.niri
import qs.stores.dock
import qs.stores.niri
import qs.stores.session
import qs.stores.shell
import "../../services/i18n/LauncherStrings.js" as LauncherStrings
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
    readonly property var results: buildResults(
        query,
        applications,
        windows,
        I18n.locale
    )
    readonly property var favoriteResults: buildFavoriteResults(
        DockPreferences.favoriteAppIds,
        I18n.locale
    )

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

    function resultForEntry(entry, locale) {
        if (!entry)
            return null

        return {
            kind: "application",
            title: String(
                entry.name
                    || entry.id
                    || LauncherStrings.text(locale, "applicationFallback")
            ),
            subtitle: String(
                entry.comment
                    || entry.genericName
                    || entry.id
                    || ""
            ),
            icon: String(entry.icon || "application-x-executable"),
            entry: entry,
            score: 1
        }
    }

    function buildFavoriteResults(favoriteIds, locale) {
        const identifiers = favoriteIds || []
        const favorites = []

        for (var index = 0; index < identifiers.length; ++index) {
            const identifier = String(identifiers[index] || "").trim()
            const entry = identifier
                ? DesktopEntries.heuristicLookup(identifier)
                : null

            if (!entry || entry.noDisplay)
                continue

            const result = resultForEntry(entry, locale)
            if (result)
                favorites.push(result)

            if (favorites.length >= 8)
                break
        }

        return favorites
    }

    function localizedShellActions(locale) {
        return [
            {
                id: "toggle-overview",
                title: LauncherStrings.text(locale, "toggleOverviewTitle"),
                subtitle: LauncherStrings.text(locale, "niriShellAction"),
                icon: "view-grid-symbolic"
            },
            {
                id: "focus-column-left",
                title: LauncherStrings.text(locale, "focusColumnLeftTitle"),
                subtitle: LauncherStrings.text(locale, "niriLayoutAction"),
                icon: "go-previous-symbolic"
            },
            {
                id: "focus-column-right",
                title: LauncherStrings.text(locale, "focusColumnRightTitle"),
                subtitle: LauncherStrings.text(locale, "niriLayoutAction"),
                icon: "go-next-symbolic"
            },
            {
                id: "center-column",
                title: LauncherStrings.text(locale, "centerColumnTitle"),
                subtitle: LauncherStrings.text(locale, "niriLayoutAction"),
                icon: "object-align-horizontal-center-symbolic"
            },
            {
                id: "toggle-floating",
                title: LauncherStrings.text(locale, "toggleFloatingTitle"),
                subtitle: LauncherStrings.text(locale, "niriLayoutAction"),
                icon: "window-duplicate-symbolic"
            },
            {
                id: "toggle-fullscreen",
                title: LauncherStrings.text(locale, "toggleFullscreenTitle"),
                subtitle: LauncherStrings.text(locale, "niriLayoutAction"),
                icon: "view-fullscreen-symbolic"
            },
            {
                id: "session-menu",
                title: LauncherStrings.text(locale, "sessionMenuTitle"),
                subtitle: LauncherStrings.text(locale, "sessionMenuSubtitle"),
                icon: "system-shutdown-symbolic"
            }
        ]
    }

    function buildResults(searchText, appEntries, windowEntries, locale) {
        const needle = normalizedText(searchText)
        const matches = []
        const apps = appEntries || []
        const currentWindows = windowEntries || []

        for (var appIndex = 0; appIndex < apps.length; ++appIndex) {
            const entry = apps[appIndex]

            if (!entry || entry.noDisplay)
                continue

            const result = resultForEntry(entry, locale)
            const details = searchableText([
                entry.genericName,
                entry.comment,
                entry.id,
                entry.keywords ? entry.keywords.join(" ") : ""
            ])
            const score = matchScore(needle, result.title, details)

            if (score < 0)
                continue

            result.score = score
            matches.push(result)
        }

        if (needle) {
            for (var windowIndex = 0;
                 windowIndex < currentWindows.length;
                 ++windowIndex) {
                const windowItem = currentWindows[windowIndex]
                const windowTitle = WindowStore.titleFor(windowItem)
                const appId = WindowStore.appIdFor(windowItem)
                const windowScore = matchScore(
                    needle,
                    windowTitle,
                    appId
                )

                if (windowScore < 0)
                    continue

                matches.push({
                    kind: "window",
                    title: windowTitle,
                    subtitle: appId
                        || LauncherStrings.text(locale, "openWindow"),
                    icon: iconForWindow(windowItem),
                    windowId: windowItem.id,
                    score: windowScore + 50
                })
            }
        }

        const shellActions = localizedShellActions(locale)
        for (var actionIndex = 0;
             actionIndex < shellActions.length;
             ++actionIndex) {
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

    function selectOffset(offset) {
        if (results.length === 0)
            return

        selectedIndex = (
            selectedIndex + Number(offset || 0) + results.length
        ) % results.length
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

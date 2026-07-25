pragma Singleton

import QtQuick
import Quickshell
import qs.services.niri
import qs.stores.niri
import "DockModel.js" as DockModel

Singleton {
    id: root

    readonly property var applications: DesktopEntries.applications.values
    readonly property var windows: WindowStore.windows
    readonly property var items: buildItems()

    function entryFor(identifier) {
        const requested = String(identifier || "").trim()
        return requested ? DesktopEntries.heuristicLookup(requested) : null
    }

    function entryIdentifier(entry, fallback) {
        if (entry && entry.id)
            return String(entry.id)

        return String(fallback || "")
    }

    function titleForFavorite(identifier) {
        const entry = entryFor(identifier)
        return entry && entry.name
            ? String(entry.name)
            : String(identifier || "")
    }

    function iconFor(entry) {
        return entry && entry.icon
            ? String(entry.icon)
            : "application-x-executable"
    }

    function findRunningGroup(groups, identifier, entry) {
        const requestedKey = DockModel.normalizeIdentifier(identifier)
        const entryKey = DockModel.normalizeIdentifier(
            entry && entry.id ? entry.id : ""
        )

        for (var index = 0; index < groups.length; ++index) {
            const group = groups[index]
            const groupEntry = entryFor(group.appId)
            const groupEntryKey = DockModel.normalizeIdentifier(
                groupEntry && groupEntry.id ? groupEntry.id : ""
            )

            if (group.key === requestedKey
                || (entryKey && group.key === entryKey)
                || (groupEntryKey && groupEntryKey === requestedKey)
                || (entryKey && groupEntryKey === entryKey)) {
                return group
            }
        }

        return null
    }

    function itemFrom(identifier, entry, group, pinned) {
        const fallbackId = group ? group.appId : identifier
        const favoriteId = entryIdentifier(entry, fallbackId)
        const displayName = entry && entry.name
            ? String(entry.name)
            : String(group && group.appId || identifier || "Application")

        return {
            key: DockModel.normalizeIdentifier(favoriteId || fallbackId),
            favoriteId: favoriteId,
            title: displayName,
            icon: iconFor(entry),
            entry: entry,
            windowIds: group ? group.windowIds : [],
            running: Boolean(group),
            focused: group ? Boolean(group.focused) : false,
            urgent: group ? Boolean(group.urgent) : false,
            pinned: Boolean(pinned)
        }
    }

    function buildItems() {
        const groups = DockModel.groupWindows(windows)
        const favorites = DockModel.uniqueIdentifiers(
            DockPreferences.favoriteAppIds
        )
        const result = []
        const consumedGroups = {}

        for (var favoriteIndex = 0;
             favoriteIndex < favorites.length;
             ++favoriteIndex) {
            const identifier = favorites[favoriteIndex]
            const entry = entryFor(identifier)
            const group = findRunningGroup(groups, identifier, entry)

            if (!entry && !group)
                continue

            result.push(itemFrom(identifier, entry, group, true))

            if (group)
                consumedGroups[group.key] = true
        }

        if (DockPreferences.showRunning) {
            for (var groupIndex = 0;
                 groupIndex < groups.length;
                 ++groupIndex) {
                const group = groups[groupIndex]

                if (consumedGroups[group.key])
                    continue

                const entry = entryFor(group.appId)
                result.push(itemFrom(group.appId, entry, group, false))
            }
        }

        return result
    }

    function activate(item) {
        if (!item)
            return

        const windowIds = item.windowIds || []
        if (item.running && windowIds.length > 0) {
            const focusedId = WindowStore.focusedWindow
                ? WindowStore.focusedWindow.id
                : null
            const targetId = DockModel.nextWindowId(windowIds, focusedId)

            if (targetId !== null)
                NiriService.focusWindow(targetId)

            return
        }

        if (item.entry)
            item.entry.execute()
    }

    function togglePinned(item) {
        if (!item)
            return

        const identifier = String(item.favoriteId || "").trim()
        if (identifier)
            DockPreferences.toggleFavorite(identifier)
    }
}

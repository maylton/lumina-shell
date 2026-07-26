pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.stores.config
import qs.stores.niri
import qs.stores.shell

Singleton {
    id: root

    readonly property int historyLimit: 50
    readonly property int popupLimit:
        ConfigStore.notificationPopupMaximum
    readonly property bool doNotDisturb: ConfigStore.doNotDisturb
    readonly property string centerOutputName:
        OverlayStore.activeSurface === "notifications"
            ? OverlayStore.activeOutputName
            : ""
    readonly property int unreadCount: {
        var count = 0

        for (var i = 0; i < history.length; ++i) {
            if (!history[i].read)
                count += 1
        }

        return count
    }

    property var history: []
    property var popupEntries: []
    property string popupOutputName: ""
    property int generation: 0

    signal received(var entry)

    function outputExists(outputName) {
        const name = String(outputName || "")
        const screens = Quickshell.screens || []

        for (var i = 0; i < screens.length; ++i) {
            if (String(screens[i].name || "") === name)
                return true
        }

        return false
    }

    function defaultOutputName() {
        const workspaces = WorkspaceStore.workspaces || []

        for (var i = 0; i < workspaces.length; ++i) {
            if (workspaces[i].is_focused
                && outputExists(workspaces[i].output)) {
                return String(workspaces[i].output)
            }
        }

        const screens = Quickshell.screens || []

        const preferred = ConfigStore.notificationPreferredOutput

        if (preferred !== "active" && outputExists(preferred))
            return preferred

        return screens.length > 0 ? String(screens[0].name || "") : ""
    }

    function resolvedOutputName(outputName) {
        const requested = String(outputName || "")

        return outputExists(requested) ? requested : defaultOutputName()
    }

    function plainText(value) {
        return String(value || "")
            .replace(/<br\s*\/?>/gi, "\n")
            .replace(/<\/p>/gi, "\n")
            .replace(/<[^>]*>/g, "")
            .replace(/&amp;/g, "&")
            .replace(/&lt;/g, "<")
            .replace(/&gt;/g, ">")
            .replace(/&quot;/g, "\"")
            .trim()
    }

    function iconFor(notification) {
        if (notification.image)
            return String(notification.image)

        if (notification.appIcon)
            return String(notification.appIcon)

        if (notification.desktopEntry) {
            const entry = DesktopEntries.byId(notification.desktopEntry)
                || DesktopEntries.heuristicLookup(notification.desktopEntry)

            if (entry && entry.icon)
                return String(entry.icon)
        }

        return "dialog-information"
    }

    function entryFor(notification) {
        generation += 1

        return {
            key: String(notification.id) + "-" + generation,
            notificationId: notification.id,
            notification: notification,
            appName: String(notification.appName || "Application"),
            summary: plainText(notification.summary) || "Notification",
            body: plainText(notification.body),
            icon: iconFor(notification),
            urgency: notification.urgency,
            actions: notification.actions || [],
            expireTimeout: Number(notification.expireTimeout),
            resident: Boolean(notification.resident),
            transient: Boolean(notification.transient),
            receivedAt: Date.now(),
            read: doNotDisturb,
            closed: false
        }
    }

    function receiveNotification(notification) {
        if (!notification)
            return

        notification.tracked = true

        const entry = entryFor(notification)
        const nextHistory = [entry]

        for (var i = 0; i < history.length; ++i) {
            if (history[i].notificationId !== notification.id) {
                nextHistory.push(history[i])
            } else if (history[i].notification
                && history[i].notification !== notification) {
                history[i].notification.tracked = false
            }
        }

        const trimmed = nextHistory.slice(0, historyLimit)

        for (var discardedIndex = historyLimit;
             discardedIndex < nextHistory.length;
             ++discardedIndex) {
            const discarded = nextHistory[discardedIndex]

            if (discarded.notification)
                discarded.notification.tracked = false
        }

        history = ConfigStore.notificationKeepHistory ? trimmed : []
        popupOutputName = defaultOutputName()

        if (!doNotDisturb) {
            popupEntries = [entry].concat(
                popupEntries.filter(item => {
                    return item.notificationId !== notification.id
                })
            ).slice(0, popupLimit)
        }

        notification.closed.connect(function(reason) {
            root.handleClosed(entry.key, reason)
        })

        received(entry)
    }

    function updatedEntry(entry, changes) {
        const copy = {}

        for (const key in entry)
            copy[key] = entry[key]

        for (const changeKey in changes)
            copy[changeKey] = changes[changeKey]

        return copy
    }

    function handleClosed(entryKey, reason) {
        const nextHistory = []

        for (var i = 0; i < history.length; ++i) {
            const entry = history[i]

            nextHistory.push(
                entry.key === entryKey
                    ? updatedEntry(entry, { closed: true })
                    : entry
            )
        }

        history = nextHistory
        popupEntries = popupEntries.filter(entry => {
            return entry.key !== entryKey
        })
    }

    function dismissPopup(key) {
        popupEntries = popupEntries.filter(entry => entry.key !== key)
    }

    function expire(key) {
        for (var i = 0; i < popupEntries.length; ++i) {
            const entry = popupEntries[i]

            if (entry.key !== key)
                continue

            dismissPopup(key)

            if (entry.notification && !entry.closed)
                entry.notification.expire()

            return
        }
    }

    function dismissNotification(entry) {
        if (!entry)
            return

        dismissPopup(entry.key)

        if (entry.notification && !entry.closed)
            entry.notification.dismiss()
    }

    function invokeAction(entry, action) {
        if (!entry || !action)
            return

        action.invoke()

        if (!entry.resident)
            dismissPopup(entry.key)
    }

    function markAllRead() {
        const next = []
        let changed = false

        for (var i = 0; i < history.length; ++i) {
            const entry = history[i]

            if (!entry.read) {
                next.push(updatedEntry(entry, { read: true }))
                changed = true
            } else {
                next.push(entry)
            }
        }

        if (changed)
            history = next
    }

    function openCenter(outputName) {
        OverlayStore.openFor(
            "notifications",
            resolvedOutputName(outputName)
        )
        markAllRead()
    }

    function closeCenter() {
        OverlayStore.close("notifications")
    }

    function toggleCenter(outputName) {
        const targetOutput = resolvedOutputName(outputName)

        if (centerOutputName === targetOutput)
            closeCenter()
        else
            openCenter(targetOutput)
    }

    function setDoNotDisturb(enabled) {
        ConfigStore.setDoNotDisturb(enabled)

        if (Boolean(enabled))
            popupEntries = []
    }

    function toggleDoNotDisturb() {
        setDoNotDisturb(!doNotDisturb)
    }

    function clearHistory() {
        for (var i = 0; i < history.length; ++i) {
            const entry = history[i]
            const stillPopup = popupEntries.some(item => item.key === entry.key)

            if (!stillPopup && entry.notification)
                entry.notification.tracked = false
        }

        history = []
    }

    NotificationServer {
        id: notificationServer

        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: false
        bodyImagesSupported: false
        actionsSupported: true
        actionIconsSupported: false
        imageSupported: true
        inlineReplySupported: false

        onNotification: notification => {
            root.receiveNotification(notification)
        }
    }

    Connections {
        target: Quickshell

        function onScreensChanged() {
            if (root.popupEntries.length > 0
                && !root.outputExists(root.popupOutputName)) {
                root.popupOutputName = root.defaultOutputName()
            }
        }
    }
}

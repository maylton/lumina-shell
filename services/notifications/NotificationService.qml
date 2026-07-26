pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.stores.config
import qs.stores.niri
import qs.stores.shell
import "NotificationModel.js" as NotificationModel

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
    readonly property var historyKeys:
        NotificationModel.entryKeys(history)
    readonly property var popupKeys:
        NotificationModel.entryKeys(popupEntries)

    property var history: []
    property var popupEntries: []
    property int unreadCount: 0
    property string popupOutputName: ""
    property int generation: 0
    property int presentationRevision: 0
    property var nativeEntries: ({})

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
        const key = String(notification.id) + "-" + generation
        const nativeActions = []
        const actions = notification.actions || []

        for (var i = 0; i < actions.length; ++i)
            nativeActions.push(actions[i])

        nativeEntries[key] = {
            notification: notification,
            actions: nativeActions
        }

        return NotificationModel.presentationEntry(
            {
                id: notification.id,
                appName: notification.appName,
                summary: plainText(notification.summary) || "Notification",
                body: plainText(notification.body),
                urgency: notification.urgency,
                actions: actions,
                expireTimeout: notification.expireTimeout,
                resident: notification.resident,
                transient: notification.transient
            },
            key,
            iconFor(notification),
            doNotDisturb,
            Date.now()
        )
    }

    function nativeEntryForKey(entryKey) {
        return nativeEntries[String(entryKey || "")] || null
    }

    function entryForKey(entryKey) {
        // Reading the revision makes existing cards refresh after an in-place
        // presentation update without replacing the ScriptModel.
        const revision = presentationRevision
        const entry = NotificationModel.entryForKey(
            history,
            popupEntries,
            entryKey
        )

        if (revision < 0 || !entry)
            return NotificationModel.emptyEntry(entryKey)

        return NotificationModel.copyEntry(entry, {})
    }

    function cleanupNativeEntries() {
        const retained = {}
        const retainedNotifications = []
        const collections = [history, popupEntries]

        for (var collectionIndex = 0;
             collectionIndex < collections.length;
             ++collectionIndex) {
            const collection = collections[collectionIndex]

            for (var entryIndex = 0;
                 entryIndex < collection.length;
                 ++entryIndex) {
                const key = String(collection[entryIndex].key || "")
                const nativeEntry = nativeEntries[key]

                retained[key] = true

                if (nativeEntry && nativeEntry.notification)
                    retainedNotifications.push(nativeEntry.notification)
            }
        }

        for (const nativeKey in nativeEntries) {
            if (retained[nativeKey])
                continue

            const discarded = nativeEntries[nativeKey]
            const notification = discarded
                ? discarded.notification
                : null
            let stillTracked = false

            for (var notificationIndex = 0;
                 notificationIndex < retainedNotifications.length;
                 ++notificationIndex) {
                if (retainedNotifications[notificationIndex] === notification) {
                    stillTracked = true
                    break
                }
            }

            if (notification && !stillTracked)
                notification.tracked = false

            delete nativeEntries[nativeKey]
        }
    }

    function refreshPresentation() {
        unreadCount = NotificationModel.unreadCount(history)
        presentationRevision += 1
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
            }
        }

        const trimmed = nextHistory.slice(0, historyLimit)

        history = ConfigStore.notificationKeepHistory ? trimmed : []
        popupOutputName = defaultOutputName()

        if (!doNotDisturb) {
            popupEntries = [entry].concat(
                popupEntries.filter(item => {
                    return item.notificationId !== notification.id
                })
            ).slice(0, popupLimit)
        }

        cleanupNativeEntries()
        refreshPresentation()

        notification.closed.connect(function(reason) {
            root.handleClosed(entry.key, reason)
        })

        received(entry)
    }

    function updatedEntry(entry, changes) {
        return NotificationModel.copyEntry(entry, changes)
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
        cleanupNativeEntries()
        refreshPresentation()
    }

    function dismissPopup(key) {
        popupEntries = popupEntries.filter(entry => entry.key !== key)
        cleanupNativeEntries()
        presentationRevision += 1
    }

    function expire(key) {
        for (var i = 0; i < popupEntries.length; ++i) {
            const entry = popupEntries[i]

            if (entry.key !== key)
                continue

            const nativeEntry = nativeEntryForKey(key)

            if (nativeEntry && nativeEntry.notification && !entry.closed)
                nativeEntry.notification.expire()

            dismissPopup(key)
            return
        }
    }

    function dismissNotification(entryKey) {
        const entry = NotificationModel.entryForKey(
            history,
            popupEntries,
            entryKey
        )

        if (!entry)
            return

        const nativeEntry = nativeEntryForKey(entry.key)

        if (nativeEntry && nativeEntry.notification && !entry.closed)
            nativeEntry.notification.dismiss()

        dismissPopup(entry.key)
    }

    function invokeAction(entryKey, actionIndex) {
        const entry = NotificationModel.entryForKey(
            history,
            popupEntries,
            entryKey
        )
        const nativeEntry = nativeEntryForKey(entryKey)
        const action = nativeEntry
            && nativeEntry.actions
            && actionIndex >= 0
            && actionIndex < nativeEntry.actions.length
                ? nativeEntry.actions[actionIndex]
                : null

        if (!entry || !action)
            return

        action.invoke()

        if (!entry.resident)
            dismissPopup(entryKey)
    }

    function markAllRead() {
        if (NotificationModel.markAllRead(history))
            refreshPresentation()
    }

    function openCenter(outputName) {
        markAllRead()
        OverlayStore.openFor(
            "notifications",
            resolvedOutputName(outputName)
        )
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

        if (Boolean(enabled)) {
            popupEntries = []
            cleanupNativeEntries()
            presentationRevision += 1
        }
    }

    function toggleDoNotDisturb() {
        setDoNotDisturb(!doNotDisturb)
    }

    function clearHistory() {
        history = []
        cleanupNativeEntries()
        refreshPresentation()
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

.pragma library

function actionLabels(actions) {
    const labels = []
    const source = actions || []

    for (var i = 0; i < source.length; ++i)
        labels.push(String(source[i] && source[i].text || "Open"))

    return labels
}

function presentationEntry(notification, key, icon, read, receivedAt) {
    return {
        key: String(key),
        notificationId: Number(notification.id),
        appName: String(notification.appName || "Application"),
        summary: String(notification.summary || "Notification"),
        body: String(notification.body || ""),
        icon: String(icon || "dialog-information"),
        urgency: Number(notification.urgency),
        actionLabels: actionLabels(notification.actions),
        expireTimeout: Number(notification.expireTimeout),
        resident: Boolean(notification.resident),
        transient: Boolean(notification.transient),
        receivedAt: Number(receivedAt),
        read: Boolean(read),
        closed: false
    }
}

function copyEntry(entry, changes) {
    const copy = {
        key: String(entry.key || ""),
        notificationId: Number(entry.notificationId),
        appName: String(entry.appName || "Application"),
        summary: String(entry.summary || "Notification"),
        body: String(entry.body || ""),
        icon: String(entry.icon || "dialog-information"),
        urgency: Number(entry.urgency),
        actionLabels: (entry.actionLabels || []).slice(),
        expireTimeout: Number(entry.expireTimeout),
        resident: Boolean(entry.resident),
        transient: Boolean(entry.transient),
        receivedAt: Number(entry.receivedAt),
        read: Boolean(entry.read),
        closed: Boolean(entry.closed)
    }

    for (const key in changes)
        copy[key] = changes[key]

    return copy
}

function emptyEntry(key) {
    return {
        key: String(key || ""),
        notificationId: 0,
        appName: "Application",
        summary: "Notification",
        body: "",
        icon: "dialog-information",
        urgency: 0,
        actionLabels: [],
        expireTimeout: 0,
        resident: false,
        transient: false,
        receivedAt: 0,
        read: true,
        closed: true
    }
}

function entryKeys(entries) {
    const keys = []
    const source = entries || []

    for (var i = 0; i < source.length; ++i)
        keys.push(String(source[i].key || ""))

    return keys
}

function entryForKey(history, popupEntries, entryKey) {
    const key = String(entryKey || "")
    const sources = [history || [], popupEntries || []]

    for (var sourceIndex = 0; sourceIndex < sources.length; ++sourceIndex) {
        const source = sources[sourceIndex]

        for (var i = 0; i < source.length; ++i) {
            if (String(source[i].key || "") === key)
                return source[i]
        }
    }

    return null
}

function markAllRead(entries) {
    const source = entries || []
    let changed = false

    for (var i = 0; i < source.length; ++i) {
        if (!source[i].read) {
            source[i].read = true
            changed = true
        }
    }

    return changed
}

function unreadCount(entries) {
    const source = entries || []
    let count = 0

    for (var i = 0; i < source.length; ++i) {
        if (!source[i].read)
            count += 1
    }

    return count
}

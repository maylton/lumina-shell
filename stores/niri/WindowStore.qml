pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property var windows: []

    readonly property var focusedWindow: {
        for (var i = 0; i < windows.length; ++i) {
            if (windows[i].is_focused)
                return windows[i]
        }

        return null
    }

    readonly property string focusedTitle: {
        if (!focusedWindow)
            return "Desktop"

        if (focusedWindow.title)
            return String(focusedWindow.title)

        if (focusedWindow.app_id)
            return String(focusedWindow.app_id)

        return "Untitled window"
    }

    readonly property string focusedAppId: {
        if (!focusedWindow || !focusedWindow.app_id)
            return ""

        return String(focusedWindow.app_id)
    }

    function cloneObject(source) {
        const result = {}

        if (!source)
            return result

        for (const key in source)
            result[key] = source[key]

        return result
    }

    function replace(items) {
        windows = items ? items.slice() : []
    }

    function upsert(item) {
        if (!item)
            return

        const next = []
        var found = false

        for (var i = 0; i < windows.length; ++i) {
            const window = cloneObject(windows[i])

            if (window.id === item.id) {
                next.push(cloneObject(item))
                found = true
            } else {
                if (item.is_focused)
                    window.is_focused = false
                next.push(window)
            }
        }

        if (!found)
            next.push(cloneObject(item))

        windows = next
    }

    function remove(id) {
        const next = []

        for (var i = 0; i < windows.length; ++i) {
            if (windows[i].id !== id)
                next.push(windows[i])
        }

        windows = next
    }

    function focus(id) {
        const next = []

        for (var i = 0; i < windows.length; ++i) {
            const window = cloneObject(windows[i])
            window.is_focused = id !== null && window.id === id
            next.push(window)
        }

        windows = next
    }

    function setUrgent(id, urgent) {
        updateField(id, "is_urgent", urgent)
    }

    function updateLayout(id, layout) {
        updateField(id, "layout", layout)
    }

    function updateField(id, field, value) {
        const next = []

        for (var i = 0; i < windows.length; ++i) {
            const window = cloneObject(windows[i])

            if (window.id === id)
                window[field] = value

            next.push(window)
        }

        windows = next
    }

    function loadDemo() {
        replace([
            {
                id: 201,
                title: "Lumina Shell — Sprint 2",
                app_id: "org.kde.konsole",
                workspace_id: 101,
                is_focused: true,
                is_urgent: false
            },
            {
                id: 202,
                title: "Niri IPC documentation",
                app_id: "firefox",
                workspace_id: 102,
                is_focused: false,
                is_urgent: false
            }
        ])
    }
}

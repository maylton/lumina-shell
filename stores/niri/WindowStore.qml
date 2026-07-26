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

    readonly property string focusedTitle: titleFor(focusedWindow)
    readonly property string focusedAppId: appIdFor(focusedWindow)
    readonly property var focusedLayoutPosition: layoutPositionFor(focusedWindow)
    readonly property string focusedColumnLabel: columnLabelFor(focusedWindow)

    function cloneObject(source) {
        const result = {}

        if (!source)
            return result

        for (const key in source)
            result[key] = source[key]

        return result
    }

    function byId(id) {
        if (id === undefined || id === null)
            return null

        for (var i = 0; i < windows.length; ++i) {
            if (windows[i].id === id)
                return windows[i]
        }

        return null
    }

    function titleFor(item) {
        if (!item)
            return "Desktop"

        if (item.title)
            return String(item.title)

        if (item.app_id)
            return String(item.app_id)

        return "Untitled window"
    }

    function appIdFor(item) {
        if (!item || !item.app_id)
            return ""

        return String(item.app_id)
    }

    function layoutPositionFor(item) {
        if (!item || item.is_floating || !item.layout)
            return null

        const position = item.layout.pos_in_scrolling_layout

        if (!position || position.length < 2)
            return null

        const column = Number(position[0])
        const tile = Number(position[1])

        if (isNaN(column) || isNaN(tile))
            return null

        return {
            column: column,
            tile: tile
        }
    }

    function columnLabelFor(item) {
        if (!item)
            return ""

        if (item.is_floating)
            return "Floating"

        const position = layoutPositionFor(item)

        if (!position)
            return ""

        if (position.tile > 1)
            return "Column " + position.column + " · Tile " + position.tile

        return "Column " + position.column
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
            const current = cloneObject(windows[i])

            if (current.id === item.id) {
                next.push(cloneObject(item))
                found = true
            } else {
                if (item.is_focused)
                    current.is_focused = false
                next.push(current)
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
            const item = cloneObject(windows[i])
            item.is_focused = id !== null && item.id === id
            next.push(item)
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
            const item = cloneObject(windows[i])

            if (item.id === id)
                item[field] = value

            next.push(item)
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
                is_floating: false,
                is_urgent: false,
                layout: {
                    pos_in_scrolling_layout: [2, 1],
                    tile_size: [960, 1010],
                    window_size: [952, 1002],
                    tile_pos_in_workspace_view: [480, 0],
                    window_offset_in_tile: [4, 4]
                }
            },
            {
                id: 202,
                title: "Niri IPC documentation",
                app_id: "firefox",
                workspace_id: 102,
                is_focused: false,
                is_floating: false,
                is_urgent: false,
                layout: {
                    pos_in_scrolling_layout: [1, 1],
                    tile_size: [1280, 1010],
                    window_size: [1272, 1002],
                    tile_pos_in_workspace_view: [0, 0],
                    window_offset_in_tile: [4, 4]
                }
            }
        ])
    }
}

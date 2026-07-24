pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property var workspaces: []

    readonly property var focusedWorkspace: {
        for (var i = 0; i < workspaces.length; ++i) {
            if (workspaces[i].is_focused)
                return workspaces[i]
        }

        return null
    }

    readonly property string focusedLabel: {
        const workspace = focusedWorkspace

        if (!workspace)
            return "—"

        if (workspace.name)
            return String(workspace.name)

        return String(workspace.idx)
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
        workspaces = items ? items.slice() : []
    }

    function forOutput(outputName) {
        if (!outputName)
            return workspaces

        const matches = []

        for (var i = 0; i < workspaces.length; ++i) {
            if (workspaces[i].output === outputName)
                matches.push(workspaces[i])
        }

        return matches.length > 0 ? matches : workspaces
    }

    function activate(id, focused) {
        var targetOutput = null

        for (var i = 0; i < workspaces.length; ++i) {
            if (workspaces[i].id === id) {
                targetOutput = workspaces[i].output
                break
            }
        }

        const next = []

        for (var index = 0; index < workspaces.length; ++index) {
            const workspace = cloneObject(workspaces[index])

            if (targetOutput !== null && workspace.output === targetOutput)
                workspace.is_active = workspace.id === id

            if (focused)
                workspace.is_focused = workspace.id === id

            next.push(workspace)
        }

        workspaces = next
    }

    function setUrgent(id, urgent) {
        updateField(id, "is_urgent", urgent)
    }

    function setActiveWindow(workspaceId, windowId) {
        updateField(workspaceId, "active_window_id", windowId)
    }

    function updateField(id, field, value) {
        const next = []

        for (var i = 0; i < workspaces.length; ++i) {
            const workspace = cloneObject(workspaces[i])

            if (workspace.id === id)
                workspace[field] = value

            next.push(workspace)
        }

        workspaces = next
    }

    function loadDemo() {
        replace([
            {
                id: 101,
                idx: 1,
                name: "Code",
                output: "demo",
                is_urgent: false,
                is_active: true,
                is_focused: true,
                active_window_id: 201
            },
            {
                id: 102,
                idx: 2,
                name: "Web",
                output: "demo",
                is_urgent: false,
                is_active: false,
                is_focused: false,
                active_window_id: 202
            },
            {
                id: 103,
                idx: 3,
                name: "Chat",
                output: "demo",
                is_urgent: true,
                is_active: false,
                is_focused: false,
                active_window_id: null
            },
            {
                id: 104,
                idx: 4,
                name: "Music",
                output: "demo",
                is_urgent: false,
                is_active: false,
                is_focused: false,
                active_window_id: null
            }
        ])
    }
}

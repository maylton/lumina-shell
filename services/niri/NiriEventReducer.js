.pragma library

function cloneObject(source) {
    const result = {}

    if (!source)
        return result

    for (const key in source)
        result[key] = source[key]

    return result
}

function cloneItems(items) {
    const result = []
    const values = items || []

    for (var i = 0; i < values.length; ++i) {
        if (values[i])
            result.push(cloneObject(values[i]))
    }

    return result
}

function createState(workspaces, windows, overviewOpen) {
    return {
        workspaces: cloneItems(workspaces),
        windows: cloneItems(windows),
        overviewOpen: Boolean(overviewOpen)
    }
}

function emptyState() {
    return createState([], [], false)
}

function initialSyncState() {
    return {
        outputs: false,
        workspaces: false,
        windows: false
    }
}

function markInitialSnapshot(syncState, eventType) {
    const next = {
        outputs: Boolean(syncState && syncState.outputs),
        workspaces: Boolean(syncState && syncState.workspaces),
        windows: Boolean(syncState && syncState.windows)
    }

    if (eventType === "OutputsSnapshot")
        next.outputs = true
    else if (eventType === "WorkspacesChanged")
        next.workspaces = true
    else if (eventType === "WindowsChanged")
        next.windows = true

    return next
}

function isInitialStateComplete(syncState) {
    return Boolean(
        syncState
            && syncState.outputs
            && syncState.workspaces
            && syncState.windows
    )
}

function reconnectDelay(attempt) {
    const normalizedAttempt = Math.max(1, Math.floor(Number(attempt || 1)))
    return Math.min(15000, 1000 * Math.pow(2, normalizedAttempt - 1))
}

function parseLine(rawLine) {
    const line = String(rawLine || "").trim()

    if (!line) {
        return {
            accepted: false,
            error: "",
            eventType: "",
            payload: {}
        }
    }

    var event

    try {
        event = JSON.parse(line)
    } catch (error) {
        return {
            accepted: false,
            error: "Invalid Niri event JSON: " + error,
            eventType: "",
            payload: {}
        }
    }

    if (!event || Array.isArray(event) || typeof event !== "object") {
        return {
            accepted: false,
            error: "Niri event was not an object",
            eventType: "",
            payload: {}
        }
    }

    const keys = Object.keys(event)

    if (keys.length !== 1) {
        return {
            accepted: false,
            error: "",
            eventType: "",
            payload: {}
        }
    }

    return {
        accepted: true,
        error: "",
        eventType: keys[0],
        payload: event[keys[0]] || {}
    }
}

function updateWorkspaceField(items, id, field, value) {
    const next = cloneItems(items)

    for (var i = 0; i < next.length; ++i) {
        if (next[i].id === id)
            next[i][field] = value
    }

    return next
}

function activateWorkspace(items, id, focused) {
    const next = cloneItems(items)
    var targetOutput = null

    for (var i = 0; i < next.length; ++i) {
        if (next[i].id === id) {
            targetOutput = next[i].output
            break
        }
    }

    for (var index = 0; index < next.length; ++index) {
        if (targetOutput !== null && next[index].output === targetOutput)
            next[index].is_active = next[index].id === id

        if (focused)
            next[index].is_focused = next[index].id === id
    }

    return next
}

function updateWindowField(items, id, field, value) {
    const next = cloneItems(items)

    for (var i = 0; i < next.length; ++i) {
        if (next[i].id === id)
            next[i][field] = value
    }

    return next
}

function upsertWindow(items, source) {
    if (!source)
        return cloneItems(items)

    const next = []
    var found = false

    for (var i = 0; i < items.length; ++i) {
        const current = cloneObject(items[i])

        if (current.id === source.id) {
            next.push(cloneObject(source))
            found = true
        } else {
            if (source.is_focused)
                current.is_focused = false
            next.push(current)
        }
    }

    if (!found)
        next.push(cloneObject(source))

    return next
}

function focusWindow(items, id) {
    const next = cloneItems(items)

    for (var i = 0; i < next.length; ++i)
        next[i].is_focused = id !== null && next[i].id === id

    return next
}

function removeWindow(items, id) {
    const next = []

    for (var i = 0; i < items.length; ++i) {
        if (items[i].id !== id)
            next.push(cloneObject(items[i]))
    }

    return next
}

function applyWindowLayouts(items, changes) {
    var next = cloneItems(items)
    const values = changes || []

    for (var i = 0; i < values.length; ++i) {
        const change = values[i]

        if (change && change.length >= 2)
            next = updateWindowField(next, change[0], "layout", change[1])
    }

    return next
}

function reduce(state, eventType, payload) {
    const current = createState(
        state && state.workspaces,
        state && state.windows,
        state && state.overviewOpen
    )
    const data = payload || {}
    var handled = true

    switch (eventType) {
    case "WorkspacesChanged":
        current.workspaces = cloneItems(data.workspaces || [])
        break
    case "WorkspaceUrgencyChanged":
        current.workspaces = updateWorkspaceField(
            current.workspaces,
            data.id,
            "is_urgent",
            data.urgent
        )
        break
    case "WorkspaceActivated":
        current.workspaces = activateWorkspace(
            current.workspaces,
            data.id,
            data.focused
        )
        break
    case "WorkspaceActiveWindowChanged":
        current.workspaces = updateWorkspaceField(
            current.workspaces,
            data.workspace_id,
            "active_window_id",
            data.active_window_id
        )
        break
    case "WindowsChanged":
        current.windows = cloneItems(data.windows || [])
        break
    case "WindowOpenedOrChanged":
        current.windows = upsertWindow(current.windows, data.window)
        break
    case "WindowClosed":
        current.windows = removeWindow(current.windows, data.id)
        break
    case "WindowFocusChanged":
        current.windows = focusWindow(current.windows, data.id)
        break
    case "WindowUrgencyChanged":
        current.windows = updateWindowField(
            current.windows,
            data.id,
            "is_urgent",
            data.urgent
        )
        break
    case "WindowLayoutsChanged":
        current.windows = applyWindowLayouts(
            current.windows,
            data.changes || []
        )
        break
    case "OverviewOpenedOrClosed":
        current.overviewOpen = Boolean(data.is_open)
        break
    default:
        handled = false
        break
    }

    return {
        handled: handled,
        state: current
    }
}

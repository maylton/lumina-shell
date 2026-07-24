pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.stores.niri

Singleton {
    id: root

    readonly property string socketPath: {
        const value = Quickshell.env("NIRI_SOCKET")
        return value ? String(value) : ""
    }
    readonly property bool available: socketPath.length > 0
    readonly property bool demoMode: !available
    readonly property bool connected: eventStream.running && receivedInitialState

    property bool receivedInitialState: false
    property bool overviewOpen: false
    property string status: demoMode ? "demo" : "connecting"
    property string lastError: ""
    property string lastEventType: ""

    signal eventReceived(string eventType)

    function initialize() {
        if (available) {
            startStream()
        } else {
            WorkspaceStore.loadDemo()
            WindowStore.loadDemo()
            status = "demo"
        }
    }

    function startStream() {
        if (!available || eventStream.running)
            return

        status = "connecting"
        lastError = ""
        eventStream.running = true
    }

    function handleLine(rawLine) {
        const line = String(rawLine).trim()

        if (!line)
            return

        var event

        try {
            event = JSON.parse(line)
        } catch (error) {
            lastError = "Invalid Niri event JSON: " + error
            console.warn("Lumina NiriService:", lastError, line)
            return
        }

        const keys = Object.keys(event)

        if (keys.length !== 1)
            return

        const eventType = keys[0]
        const payload = event[eventType] || {}

        lastEventType = eventType
        status = "connected"
        receivedInitialState = true
        eventReceived(eventType)

        switch (eventType) {
        case "WorkspacesChanged":
            WorkspaceStore.replace(payload.workspaces || [])
            break
        case "WorkspaceUrgencyChanged":
            WorkspaceStore.setUrgent(payload.id, payload.urgent)
            break
        case "WorkspaceActivated":
            WorkspaceStore.activate(payload.id, payload.focused)
            break
        case "WorkspaceActiveWindowChanged":
            WorkspaceStore.setActiveWindow(payload.workspace_id, payload.active_window_id)
            break
        case "WindowsChanged":
            WindowStore.replace(payload.windows || [])
            break
        case "WindowOpenedOrChanged":
            WindowStore.upsert(payload.window)
            break
        case "WindowClosed":
            WindowStore.remove(payload.id)
            break
        case "WindowFocusChanged":
            WindowStore.focus(payload.id)
            break
        case "WindowUrgencyChanged":
            WindowStore.setUrgent(payload.id, payload.urgent)
            break
        case "WindowLayoutsChanged":
            applyWindowLayoutChanges(payload.changes || [])
            break
        case "OverviewOpenedOrClosed":
            overviewOpen = Boolean(payload.is_open)
            break
        case "ConfigLoaded":
            if (payload.failed)
                lastError = "Niri reported a failed configuration reload"
            break
        default:
            break
        }
    }

    function applyWindowLayoutChanges(changes) {
        for (var i = 0; i < changes.length; ++i) {
            const change = changes[i]

            if (change && change.length >= 2)
                WindowStore.updateLayout(change[0], change[1])
        }
    }

    function focusWorkspace(workspace) {
        if (!workspace)
            return

        if (demoMode) {
            WorkspaceStore.activate(workspace.id, true)
            return
        }

        actionProcess.exec([
            "niri",
            "msg",
            "action",
            "focus-workspace",
            "--id",
            String(workspace.id)
        ])
    }

    function toggleOverview() {
        if (demoMode) {
            overviewOpen = !overviewOpen
            return
        }

        actionProcess.exec([
            "niri",
            "msg",
            "action",
            "toggle-overview"
        ])
    }

    Component.onCompleted: initialize()

    Process {
        id: eventStream

        command: ["niri", "msg", "--json", "event-stream"]
        running: false

        stdout: SplitParser {
            onRead: line => root.handleLine(line)
        }

        stderr: SplitParser {
            onRead: line => {
                const message = String(line).trim()

                if (message) {
                    root.lastError = message
                    console.warn("Lumina Niri event stream:", message)
                }
            }
        }

        onStarted: {
            root.status = "connected"
            root.lastError = ""
        }

        onExited: (exitCode, exitStatus) => {
            root.receivedInitialState = false

            if (root.available) {
                root.status = "reconnecting"
                reconnectTimer.restart()
            } else {
                root.status = "demo"
            }
        }
    }

    Process {
        id: actionProcess

        stderr: SplitParser {
            onRead: line => {
                const message = String(line).trim()

                if (message) {
                    root.lastError = message
                    console.warn("Lumina Niri action:", message)
                }
            }
        }
    }

    Timer {
        id: reconnectTimer
        interval: 1500
        repeat: false
        onTriggered: root.startStream()
    }
}

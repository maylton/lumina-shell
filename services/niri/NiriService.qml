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
    property bool outputRefreshPending: false
    property string status: demoMode ? "demo" : "connecting"
    property string lastError: ""
    property string lastEventType: ""

    signal eventReceived(string eventType)

    function initialize() {
        if (available) {
            startStream()
            requestOutputRefresh()
        } else {
            OutputStore.loadDemo()
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

    function requestOutputRefresh() {
        if (!available)
            return

        if (outputSnapshot.running) {
            outputRefreshPending = true
            return
        }

        outputRefreshTimer.restart()
    }

    function refreshOutputs() {
        if (!available)
            return

        if (outputSnapshot.running) {
            outputRefreshPending = true
            return
        }

        outputRefreshPending = false
        outputSnapshot.exec(["niri", "msg", "--json", "outputs"])
    }

    function handleOutputsSnapshot(rawText) {
        const text = String(rawText).trim()

        if (!text)
            return

        var parsed

        try {
            parsed = JSON.parse(text)
        } catch (error) {
            lastError = "Invalid Niri outputs JSON: " + error
            console.warn("Lumina Niri outputs:", lastError, text)
            return
        }

        var outputMap = parsed

        if (parsed && parsed.Ok && parsed.Ok.Outputs)
            outputMap = parsed.Ok.Outputs
        else if (parsed && parsed.Outputs)
            outputMap = parsed.Outputs

        if (!outputMap || Array.isArray(outputMap) || typeof outputMap !== "object") {
            lastError = "Niri outputs response did not contain an output map"
            console.warn("Lumina Niri outputs:", lastError)
            return
        }

        OutputStore.replaceMap(outputMap)
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
            if (payload.failed) {
                lastError = "Niri reported a failed configuration reload"
            } else {
                requestOutputRefresh()
            }
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

    function workspaceReference(workspace) {
        if (!workspace)
            return ""

        if (workspace.name && String(workspace.name).length > 0)
            return String(workspace.name)

        if (workspace.idx !== undefined && workspace.idx !== null)
            return String(workspace.idx)

        return ""
    }

    function focusWorkspace(workspace) {
        if (!workspace)
            return

        if (demoMode) {
            WorkspaceStore.activate(workspace.id, true)
            return
        }

        const reference = workspaceReference(workspace)

        if (!reference) {
            lastError = "Workspace has no valid Niri reference"
            console.warn("Lumina Niri action:", lastError)
            return
        }

        lastError = ""
        actionProcess.exec([
            "niri",
            "msg",
            "action",
            "focus-workspace",
            reference
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

    Connections {
        target: Quickshell

        function onScreensChanged() {
            root.requestOutputRefresh()
        }
    }

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
            root.requestOutputRefresh()
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
        id: outputSnapshot

        stdout: StdioCollector {
            onStreamFinished: root.handleOutputsSnapshot(text)
        }

        stderr: SplitParser {
            onRead: line => {
                const message = String(line).trim()

                if (message) {
                    root.lastError = message
                    console.warn("Lumina Niri outputs:", message)
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (root.outputRefreshPending) {
                root.outputRefreshPending = false
                outputRefreshTimer.restart()
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

    Timer {
        id: outputRefreshTimer
        interval: 150
        repeat: false
        onTriggered: root.refreshOutputs()
    }
}

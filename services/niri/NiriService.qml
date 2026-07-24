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
    readonly property bool actionRunning: actionProcess.running
    readonly property bool actionFailed: actionStatus === "failed"
    readonly property int pendingActionCount: actionQueue.length
        + (activeActionName.length > 0 ? 1 : 0)

    property bool receivedInitialState: false
    property bool overviewOpen: false
    property bool outputRefreshPending: false
    property string status: demoMode ? "demo" : "connecting"
    property string lastError: ""
    property string lastEventType: ""
    property string actionStatus: "idle"
    property string activeActionName: ""
    property string activeActionLabel: ""
    property string lastActionName: ""
    property string lastActionLabel: ""
    property string lastActionError: ""
    property string actionStdout: ""
    property string actionStderr: ""
    property bool actionFeedbackVisible: false
    property var actionQueue: []

    signal eventReceived(string eventType)
    signal actionFinished(string actionName, bool succeeded, string message)

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

    function appendProcessOutput(currentText, rawText) {
        const text = String(rawText).trim()

        if (!text)
            return currentText

        return currentText.length > 0 ? currentText + "\n" + text : text
    }

    function reportActionFailure(actionName, actionLabel, message) {
        const errorMessage = String(message).trim()
            || "Niri action failed without an error message"

        actionStatus = "failed"
        lastActionName = String(actionName)
        lastActionLabel = String(actionLabel)
        lastActionError = errorMessage
        lastError = errorMessage
        actionFeedbackVisible = true
        actionFeedbackTimer.restart()
        actionFinished(lastActionName, false, errorMessage)
        console.warn("Lumina Niri action:", lastActionLabel + ":", errorMessage)
    }

    function reportActionSuccess(actionName, actionLabel, message) {
        actionStatus = "succeeded"
        lastActionName = String(actionName)
        lastActionLabel = String(actionLabel)
        actionFinished(lastActionName, true, String(message).trim())
    }

    function completeDemoAction(actionName, actionLabel) {
        reportActionSuccess(actionName, actionLabel, "Demo action completed")
    }

    function enqueueAction(actionName, actionLabel, actionArguments) {
        actionQueue = actionQueue.concat([{
            name: String(actionName),
            label: String(actionLabel),
            args: actionArguments
        }])

        if (!actionProcess.running && !activeActionName)
            Qt.callLater(startNextAction)
    }

    function startNextAction() {
        if (actionProcess.running || activeActionName || actionQueue.length === 0)
            return

        const request = actionQueue[0]

        actionQueue = actionQueue.slice(1)
        activeActionName = request.name
        activeActionLabel = request.label
        actionStdout = ""
        actionStderr = ""
        actionStatus = "running"
        actionProcess.exec([
            "niri",
            "msg",
            "action"
        ].concat(request.args))
    }

    function finishAction(exitCode) {
        const actionName = activeActionName
        const actionLabel = activeActionLabel
        const outputMessage = actionStdout.trim()
        const errorMessage = actionStderr.trim()

        activeActionName = ""
        activeActionLabel = ""

        if (exitCode === 0) {
            reportActionSuccess(actionName, actionLabel, outputMessage)
        } else {
            reportActionFailure(
                actionName,
                actionLabel,
                errorMessage || "Niri action exited with code " + exitCode
            )
        }

        Qt.callLater(startNextAction)
    }

    function performAction(actionName, actionLabel, actionArguments) {
        if (demoMode) {
            completeDemoAction(actionName, actionLabel)
            return
        }

        enqueueAction(actionName, actionLabel, actionArguments)
    }

    function focusWindow(windowId) {
        const id = Number(windowId)

        if (!isFinite(id))
            return

        if (demoMode) {
            WindowStore.focus(id)
            completeDemoAction("focus-window", "Focus window")
            return
        }

        enqueueAction(
            "focus-window",
            "Focus window " + id,
            [
                "focus-window",
                "--id",
                String(id)
            ]
        )
    }

    function focusWorkspace(workspace) {
        if (!workspace)
            return

        if (demoMode) {
            WorkspaceStore.activate(workspace.id, true)
            completeDemoAction("focus-workspace", "Switch workspace")
            return
        }

        const reference = workspaceReference(workspace)

        if (!reference) {
            reportActionFailure(
                "focus-workspace",
                "Switch workspace",
                "Workspace has no valid Niri reference"
            )
            return
        }

        enqueueAction(
            "focus-workspace",
            "Switch to workspace " + reference,
            [
                "focus-workspace",
                reference
            ]
        )
    }

    function toggleOverview() {
        if (demoMode) {
            overviewOpen = !overviewOpen
            completeDemoAction("toggle-overview", "Toggle overview")
            return
        }

        enqueueAction(
            "toggle-overview",
            "Toggle overview",
            [
                "toggle-overview"
            ]
        )
    }

    function closeFocusedWindow() {
        performAction(
            "close-window",
            "Close focused window",
            ["close-window"]
        )
    }

    function toggleFullscreen() {
        performAction(
            "fullscreen-window",
            "Toggle fullscreen",
            ["fullscreen-window"]
        )
    }

    function toggleFloating() {
        performAction(
            "toggle-window-floating",
            "Toggle floating",
            ["toggle-window-floating"]
        )
    }

    function focusColumnLeft() {
        performAction(
            "focus-column-left",
            "Focus column left",
            ["focus-column-left"]
        )
    }

    function focusColumnRight() {
        performAction(
            "focus-column-right",
            "Focus column right",
            ["focus-column-right"]
        )
    }

    function moveColumnLeft() {
        performAction(
            "move-column-left",
            "Move column left",
            ["move-column-left"]
        )
    }

    function moveColumnRight() {
        performAction(
            "move-column-right",
            "Move column right",
            ["move-column-right"]
        )
    }

    function centerColumn() {
        performAction(
            "center-column",
            "Center column",
            ["center-column"]
        )
    }

    function switchPresetColumnWidth() {
        performAction(
            "switch-preset-column-width",
            "Switch preset column width",
            ["switch-preset-column-width"]
        )
    }

    function toggleTabbedDisplay() {
        performAction(
            "toggle-column-tabbed-display",
            "Toggle tabbed display",
            ["toggle-column-tabbed-display"]
        )
    }

    function quitSession() {
        performAction(
            "quit",
            "Exit Niri session",
            [
                "quit",
                "--skip-confirmation"
            ]
        )
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

        stdout: SplitParser {
            onRead: line => {
                root.actionStdout = root.appendProcessOutput(
                    root.actionStdout,
                    line
                )
            }
        }

        stderr: SplitParser {
            onRead: line => {
                root.actionStderr = root.appendProcessOutput(
                    root.actionStderr,
                    line
                )
            }
        }

        onExited: (exitCode, exitStatus) => root.finishAction(exitCode)
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

    Timer {
        id: actionFeedbackTimer
        interval: 6000
        repeat: false
        onTriggered: root.actionFeedbackVisible = false
    }
}

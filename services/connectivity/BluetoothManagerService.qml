pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.connectivity
import "ConnectivityParsing.js" as Parsing

Singleton {
    id: root

    readonly property bool busy: actionProcess.running
        || pairAgentProcess.running
        || scanProcess.running
        || infoProcess.running
        || verifyTimer.running
    readonly property bool refreshRunning: allProcess.running
        || pairedProcess.running
        || connectedProcess.running

    property bool active: false
    property var devices: []
    property string busyAction: ""
    property string statusCode: ""
    property string targetAddress: ""
    property string targetName: ""
    property string diagnostic: ""

    property string flow: ""
    property string step: ""
    property bool expectedConnected: false
    property int verifyAttempts: 0
    property int stableChecks: 0
    property bool pairingAgentCompleted: false
    property string cancellationReason: ""

    property bool authenticationPending: false
    property string authenticationType: ""
    property string authenticationCode: ""
    property string authenticationService: ""
    property int authenticationEntered: 0

    property bool refreshQueued: false
    property bool allReady: false
    property bool pairedReady: false
    property bool connectedReady: false
    property string allText: ""
    property string pairedText: ""
    property string connectedText: ""

    function normalizedAddress(value) {
        const address = String(value || "").trim().toUpperCase()
        return /^[0-9A-F]{2}(:[0-9A-F]{2}){5}$/.test(address)
            ? address
            : ""
    }

    function nameForAddress(address) {
        const requested = normalizedAddress(address)
        for (let index = 0; index < devices.length; ++index) {
            const device = devices[index]
            if (String(device.address || "").toUpperCase() === requested)
                return String(device.name || requested)
        }
        return requested
    }

    function setActive(value) {
        active = Boolean(value)
        if (active)
            refresh()
    }

    function setEnabled(value) {
        statusCode = ""
        diagnostic = ""
        ConnectivityService.setBluetoothEnabled(Boolean(value))
        delayedRefresh.restart()
    }

    function refresh() {
        if (!active || !ConnectivityService.bluetoothAvailable) {
            if (!ConnectivityService.bluetoothAvailable)
                devices = []
            return
        }

        if (refreshRunning) {
            refreshQueued = true
            return
        }

        refreshQueued = false
        allReady = false
        pairedReady = false
        connectedReady = false
        allProcess.exec(["bluetoothctl", "devices"])
        pairedProcess.exec(["bluetoothctl", "devices", "Paired"])
        connectedProcess.exec(["bluetoothctl", "devices", "Connected"])
    }

    function maybeRebuild() {
        if (!allReady || !pairedReady || !connectedReady)
            return

        devices = Parsing.mergeBluetoothDevices(
            allText,
            pairedText,
            connectedText
        )

        if (refreshQueued) {
            refreshQueued = false
            Qt.callLater(root.refresh)
        }
    }

    function scan() {
        if (!ConnectivityService.bluetoothEnabled || busy)
            return

        busyAction = "scan"
        statusCode = "scanning"
        diagnostic = ""
        scanProcess.exec([
            "bluetoothctl", "--timeout", "12", "scan", "on"
        ])
    }

    function clearAuthentication() {
        authenticationTimeout.stop()
        authenticationPending = false
        authenticationType = ""
        authenticationCode = ""
        authenticationService = ""
        authenticationEntered = 0
    }

    function requestAuthentication(kind, code, service, entered) {
        authenticationType = String(kind || "")
        authenticationCode = String(code || "")
        authenticationService = String(service || "")
        authenticationEntered = Number(entered || 0)
        authenticationPending = true
        authenticationTimeout.restart()
    }

    function sendAgentCommand(payload) {
        if (!pairAgentProcess.running)
            return false

        pairAgentProcess.write(JSON.stringify(payload || {}) + "\n")
        return true
    }

    function acceptAuthentication() {
        if (!authenticationPending
            || ["confirmation", "authorize"]
                .indexOf(authenticationType) < 0) {
            return
        }

        if (sendAgentCommand({ action: "accept" }))
            clearAuthentication()
    }

    function rejectAuthentication() {
        if (!authenticationPending
            || ["confirmation", "authorize"]
                .indexOf(authenticationType) < 0) {
            return
        }

        if (sendAgentCommand({ action: "reject" }))
            clearAuthentication()
    }

    function submitAuthentication(value) {
        if (!authenticationPending
            || ["pin", "passkey"].indexOf(authenticationType) < 0) {
            return
        }

        const requested = String(value || "").trim()
        const valid = authenticationType === "pin"
            ? requested.length >= 1 && requested.length <= 16
            : /^[0-9]{1,6}$/.test(requested)
                && Number(requested) <= 999999

        if (!valid) {
            statusCode = authenticationType === "pin"
                ? "invalid-pin"
                : "invalid-passkey"
            return
        }

        if (sendAgentCommand({ action: "value", value: requested }))
            clearAuthentication()
    }

    function cancelAuthentication(reason) {
        if (!pairAgentProcess.running)
            return

        const timedOut = String(reason || "user") === "timeout"
        pairingAgentCompleted = true
        clearAuthentication()
        pairAgentProcess.signal(2)

        if (timedOut) {
            fail(
                "pair-failed",
                "Pairing confirmation timed out"
            )
        } else {
            statusCode = ""
            diagnostic = ""
            clearFlow()
            refresh()
        }
    }

    function handlePairingAgentEvent(data) {
        let event = null
        try {
            event = JSON.parse(String(data || ""))
        } catch (error) {
            diagnostic = "Invalid pairing-agent response: " + error
            return
        }

        const type = String(event.type || "")
        if (type === "prompt") {
            requestAuthentication(
                event.kind,
                event.code,
                event.service,
                event.entered
            )
            return
        }

        if (type === "display") {
            requestAuthentication(
                event.kind,
                event.code,
                event.service,
                event.entered
            )
            return
        }

        if (type === "invalid-response") {
            statusCode = String(event.kind || "") === "pin"
                ? "invalid-pin"
                : "invalid-passkey"
            return
        }

        if (type === "completed") {
            pairingAgentCompleted = true
            clearAuthentication()
            runStep("trust", [
                "bluetoothctl", "--timeout", "15",
                "trust", targetAddress
            ])
            return
        }

        if (type === "cancelled") {
            pairingAgentCompleted = true
            statusCode = ""
            diagnostic = ""
            clearFlow()
            refresh()
            return
        }

        if (type === "failed") {
            pairingAgentCompleted = true
            const helperCode = String(event.code || "")
            const code = helperCode === "invalid-address"
                ? "invalid-address"
                : "pair-failed"
            fail(code, String(event.message || helperCode))
        }
    }

    function clearFlow() {
        verifyTimer.stop()
        clearAuthentication()
        flow = ""
        step = ""
        expectedConnected = false
        verifyAttempts = 0
        stableChecks = 0
        busyAction = ""
        pairingAgentCompleted = false
        cancellationReason = ""
    }

    function finish(code) {
        statusCode = String(code || "")
        diagnostic = ""
        clearFlow()
        refresh()
    }

    function fail(code, details) {
        statusCode = String(code || "bluetooth-failed")
        diagnostic = String(details || "")
        if (diagnostic)
            console.warn("Lumina Bluetooth:", diagnostic)
        clearFlow()
        refresh()
    }

    function failureCode(text) {
        if (flow === "remove")
            return "forget-failed"

        return flow + "-failed"
    }

    function commandAccepted(exitCode, requestedStep, text) {
        if (exitCode === 0)
            return true

        const normalized = String(text || "").toLowerCase()
        if (requestedStep === "connect") {
            return normalized.indexOf("alreadyconnected") >= 0
                || normalized.indexOf("already connected") >= 0
        }
        if (requestedStep === "disconnect") {
            return normalized.indexOf("notconnected") >= 0
                || normalized.indexOf("not connected") >= 0
        }

        return false
    }

    function runStep(requestedStep, command) {
        step = String(requestedStep || "")
        actionProcess.exec(command)
    }

    function begin(requestedFlow, address) {
        if (busy)
            return

        const requested = normalizedAddress(address)
        if (!requested) {
            statusCode = "invalid-address"
            diagnostic = ""
            return
        }

        flow = String(requestedFlow || "")
        targetAddress = requested
        targetName = nameForAddress(requested)
        diagnostic = ""
        verifyAttempts = 0
        stableChecks = 0
        pairingAgentCompleted = false
        cancellationReason = ""
        busyAction = flow
        statusCode = flow === "pair"
            ? "pairing"
            : flow === "connect"
                ? "connecting"
                : flow === "disconnect"
                    ? "disconnecting"
                    : "forgetting"

        if (flow === "pair") {
            step = "agent"
            pairAgentProcess.exec([
                "python3",
                String(Quickshell.shellPath(
                    "services/connectivity/BluetoothPairingAgent.py"
                )),
                requested
            ])
        } else if (flow === "connect") {
            runStep("connect", [
                "bluetoothctl", "--timeout", "20",
                "connect", requested
            ])
        } else if (flow === "disconnect") {
            runStep("disconnect", [
                "bluetoothctl", "--timeout", "15",
                "disconnect", requested
            ])
        } else if (flow === "remove") {
            runStep("remove", [
                "bluetoothctl", "--timeout", "15",
                "remove", requested
            ])
        }
    }

    function pair(address) {
        begin("pair", address)
    }

    function connectDevice(address) {
        begin("connect", address)
    }

    function disconnectDevice(address) {
        begin("disconnect", address)
    }

    function forgetDevice(address) {
        begin("remove", address)
    }

    function scheduleVerification(connected) {
        expectedConnected = Boolean(connected)
        verifyAttempts = 0
        stableChecks = 0
        verifyTimer.restart()
    }

    Connections {
        target: ConnectivityService

        function onBluetoothEnabledChanged() {
            if (root.active)
                delayedRefresh.restart()
        }
    }

    Process {
        id: allProcess
        stdout: StdioCollector { id: allOutput }
        stderr: StdioCollector { id: allError }
        onExited: (exitCode, exitStatus) => {
            root.allText = exitCode === 0
                ? String(allOutput.text || "")
                : ""
            root.allReady = true
            if (exitCode !== 0 && !root.diagnostic)
                root.diagnostic = Parsing.bluetoothCommandSummary(allError.text)
            root.maybeRebuild()
        }
    }

    Process {
        id: pairedProcess
        stdout: StdioCollector { id: pairedOutput }
        stderr: StdioCollector { id: pairedError }
        onExited: (exitCode, exitStatus) => {
            root.pairedText = exitCode === 0
                ? String(pairedOutput.text || "")
                : ""
            root.pairedReady = true
            if (exitCode !== 0 && !root.diagnostic)
                root.diagnostic = Parsing.bluetoothCommandSummary(pairedError.text)
            root.maybeRebuild()
        }
    }

    Process {
        id: connectedProcess
        stdout: StdioCollector { id: connectedOutput }
        stderr: StdioCollector { id: connectedError }
        onExited: (exitCode, exitStatus) => {
            root.connectedText = exitCode === 0
                ? String(connectedOutput.text || "")
                : ""
            root.connectedReady = true
            if (exitCode !== 0 && !root.diagnostic) {
                root.diagnostic = Parsing.bluetoothCommandSummary(
                    connectedError.text
                )
            }
            root.maybeRebuild()
        }
    }

    Process {
        id: scanProcess
        stderr: StdioCollector { id: scanError }
        onExited: (exitCode, exitStatus) => {
            root.busyAction = ""
            root.statusCode = exitCode === 0
                ? "scan-complete"
                : "scan-failed"
            root.diagnostic = exitCode === 0
                ? ""
                : Parsing.bluetoothCommandSummary(scanError.text)
            if (root.diagnostic)
                console.warn("Lumina Bluetooth:", root.diagnostic)
            root.refresh()
        }
    }

    Process {
        id: pairAgentProcess
        stdinEnabled: true
        stdout: SplitParser {
            onRead: data => root.handlePairingAgentEvent(data)
        }
        stderr: StdioCollector { id: pairAgentError }
        onExited: (exitCode, exitStatus) => {
            if (root.flow !== "pair"
                || root.step !== "agent"
                || root.pairingAgentCompleted) {
                return
            }

            root.fail(
                "pair-failed",
                Parsing.bluetoothCommandSummary(pairAgentError.text)
                    || "Pairing agent exited unexpectedly"
            )
        }
    }

    Process {
        id: actionProcess
        stdout: StdioCollector { id: actionOutput }
        stderr: StdioCollector { id: actionError }
        onExited: (exitCode, exitStatus) => {
            const combined = String(actionOutput.text || "")
                + "\n" + String(actionError.text || "")
            const details = Parsing.bluetoothCommandSummary(combined)

            if (!root.commandAccepted(exitCode, root.step, combined)) {
                root.fail(root.failureCode(combined), details)
                return
            }

            if (root.step === "trust") {
                root.runStep("connect", [
                    "bluetoothctl", "--timeout", "20",
                    "connect", root.targetAddress
                ])
            } else if (root.step === "connect") {
                root.scheduleVerification(true)
            } else if (root.step === "disconnect") {
                root.scheduleVerification(false)
            } else if (root.step === "remove") {
                root.finish("forgotten")
            }
        }
    }

    Process {
        id: infoProcess
        stdout: StdioCollector { id: infoOutput }
        stderr: StdioCollector { id: infoError }
        onExited: (exitCode, exitStatus) => {
            const info = exitCode === 0
                ? Parsing.parseBluetoothInfo(infoOutput.text)
                : ({ valid: false })
            const pairingMatches = root.flow !== "pair"
                || (Boolean(info.paired) && Boolean(info.trusted))
            const stateMatches = Boolean(info.valid)
                && Boolean(info.connected) === root.expectedConnected
                && pairingMatches

            root.stableChecks = stateMatches ? root.stableChecks + 1 : 0

            if (root.stableChecks >= 2) {
                root.finish(root.expectedConnected
                    ? "connected"
                    : "disconnected")
                return
            }

            if (root.verifyAttempts >= 4) {
                const details = Parsing.bluetoothCommandSummary(infoError.text)
                if (root.flow === "pair"
                    && Boolean(info.paired)
                    && !Boolean(info.connected)) {
                    root.fail("paired-not-connected", details)
                } else {
                    root.fail(root.failureCode(details), details)
                }
                return
            }

            verifyTimer.restart()
        }
    }

    Timer {
        id: verifyTimer
        interval: 900
        repeat: false
        onTriggered: {
            if (!root.targetAddress || infoProcess.running)
                return

            root.verifyAttempts += 1
            infoProcess.exec([
                "bluetoothctl", "info", root.targetAddress
            ])
        }
    }

    Timer {
        id: authenticationTimeout
        interval: 60000
        repeat: false
        onTriggered: root.cancelAuthentication("timeout")
    }

    Timer {
        id: delayedRefresh
        interval: 650
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        interval: 15000
        running: root.active
        repeat: true
        onTriggered: root.refresh()
    }

    IpcHandler {
        target: "bluetooth-manager"

        function refresh(): void {
            root.refresh()
        }

        function status(): string {
            return JSON.stringify({
                active: root.active,
                busy: root.busy,
                action: root.busyAction,
                status: root.statusCode,
                targetAddress: root.targetAddress,
                targetName: root.targetName,
                diagnostic: root.diagnostic,
                authentication: {
                    pending: root.authenticationPending,
                    type: root.authenticationType,
                    code: root.authenticationCode,
                    service: root.authenticationService,
                    entered: root.authenticationEntered
                },
                devices: root.devices
            })
        }
    }
}

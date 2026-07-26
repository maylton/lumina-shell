#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"Expected one match in {path}, found {count}: {old[:80]!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


service = ROOT / "services/connectivity/ConnectivityManagerService.qml"
replace_once(
    service,
    '''    readonly property bool busy: actionProcess.running
        || chmodSecretProcess.running
        || wifiCreateProcess.running
        || wifiSecretActivateProcess.running
        || wifiScanProcess.running
        || bluetoothScanProcess.running
''',
    '''    readonly property bool busy: actionProcess.running
        || chmodSecretProcess.running
        || wifiCreateProcess.running
        || wifiSecretActivateProcess.running
        || wifiScanProcess.running
        || bluetoothScanProcess.running
        || bluetoothActionProcess.running
        || bluetoothInfoProcess.running
        || bluetoothVerifyTimer.running
'''
)
replace_once(
    service,
    '''    property bool clearSecretAfterAction: false
''',
    '''    property bool clearSecretAfterAction: false
    property string bluetoothFlow: ""
    property string bluetoothStep: ""
    property string bluetoothAddress: ""
    property string bluetoothDeviceName: ""
    property string bluetoothStatusCode: ""
    property string bluetoothDiagnostic: ""
    property bool bluetoothExpectedConnected: false
    property int bluetoothVerifyAttempts: 0
    property int bluetoothStableChecks: 0
    property bool bluetoothRefreshQueued: false
    property bool bluetoothAllReady: false
    property bool bluetoothPairedReady: false
    property bool bluetoothConnectedReady: false
    property string bluetoothAllText: ""
    property string bluetoothPairedText: ""
    property string bluetoothConnectedText: ""
'''
)
replace_once(
    service,
    '''    function refreshBluetooth() {
        if (!sectionAllows("bluetooth"))
            return

        if (!bluetoothAllProcess.running)
            bluetoothAllProcess.exec(["bluetoothctl", "devices"])
        if (!bluetoothPairedProcess.running) {
            bluetoothPairedProcess.exec([
                "bluetoothctl", "devices", "Paired"
            ])
        }
        if (!bluetoothConnectedProcess.running) {
            bluetoothConnectedProcess.exec([
                "bluetoothctl", "devices", "Connected"
            ])
        }
    }

    function rebuildBluetoothDevices() {
        bluetoothDevices = Parsing.mergeBluetoothDevices(
            bluetoothAllOutput.text,
            bluetoothPairedOutput.text,
            bluetoothConnectedOutput.text
        )
    }
''',
    '''    function bluetoothRefreshRunning() {
        return bluetoothAllProcess.running
            || bluetoothPairedProcess.running
            || bluetoothConnectedProcess.running
    }

    function refreshBluetooth() {
        if (!sectionAllows("bluetooth"))
            return

        if (bluetoothRefreshRunning()) {
            bluetoothRefreshQueued = true
            return
        }

        bluetoothRefreshQueued = false
        bluetoothAllReady = false
        bluetoothPairedReady = false
        bluetoothConnectedReady = false
        bluetoothAllProcess.exec(["bluetoothctl", "devices"])
        bluetoothPairedProcess.exec([
            "bluetoothctl", "devices", "Paired"
        ])
        bluetoothConnectedProcess.exec([
            "bluetoothctl", "devices", "Connected"
        ])
    }

    function maybeRebuildBluetoothDevices() {
        if (!bluetoothAllReady
            || !bluetoothPairedReady
            || !bluetoothConnectedReady) {
            return
        }

        bluetoothDevices = Parsing.mergeBluetoothDevices(
            bluetoothAllText,
            bluetoothPairedText,
            bluetoothConnectedText
        )

        if (bluetoothRefreshQueued) {
            bluetoothRefreshQueued = false
            Qt.callLater(root.refreshBluetooth)
        }
    }
'''
)
replace_once(
    service,
    '''    function setBluetoothEnabled(enabled) {
        ConnectivityService.setBluetoothEnabled(Boolean(enabled))
        delayedRefresh.restart()
    }

    function scanBluetooth() {
        if (!ConnectivityService.bluetoothEnabled || busy)
            return

        busyAction = "bluetooth-scan"
        statusMessage = ""
        lastError = ""
        bluetoothScanProcess.exec([
            "bluetoothctl", "--timeout", "12", "scan", "on"
        ])
    }

    function pairBluetooth(address) {
        runAction(
            "bluetooth-pair",
            ["bluetoothctl", "pair", String(address || "")],
            false
        )
    }

    function connectBluetooth(address) {
        runAction(
            "bluetooth-connect",
            ["bluetoothctl", "connect", String(address || "")],
            false
        )
    }

    function disconnectBluetooth(address) {
        runAction(
            "bluetooth-disconnect",
            ["bluetoothctl", "disconnect", String(address || "")],
            false
        )
    }

    function trustBluetooth(address) {
        runAction(
            "bluetooth-trust",
            ["bluetoothctl", "trust", String(address || "")],
            false
        )
    }

    function removeBluetooth(address) {
        runAction(
            "bluetooth-remove",
            ["bluetoothctl", "remove", String(address || "")],
            false
        )
    }
''',
    '''    function normalizedBluetoothAddress(value) {
        const address = String(value || "").trim().toUpperCase()
        return /^[0-9A-F]{2}(:[0-9A-F]{2}){5}$/.test(address)
            ? address
            : ""
    }

    function bluetoothNameForAddress(address) {
        const requested = normalizedBluetoothAddress(address)

        for (let index = 0; index < bluetoothDevices.length; ++index) {
            const device = bluetoothDevices[index]
            if (String(device.address || "").toUpperCase() === requested)
                return String(device.name || requested)
        }

        return requested
    }

    function clearBluetoothFlowState() {
        bluetoothFlow = ""
        bluetoothStep = ""
        bluetoothExpectedConnected = false
        bluetoothVerifyAttempts = 0
        bluetoothStableChecks = 0
        busyAction = ""
    }

    function finishBluetoothFlow(statusCode) {
        bluetoothStatusCode = String(statusCode || "")
        bluetoothDiagnostic = ""
        clearBluetoothFlowState()
        refreshBluetooth()
    }

    function failBluetoothFlow(statusCode, diagnostic) {
        bluetoothStatusCode = String(statusCode || "bluetooth-failed")
        bluetoothDiagnostic = String(diagnostic || "")
        if (bluetoothDiagnostic)
            console.warn("Lumina Bluetooth:", bluetoothDiagnostic)
        clearBluetoothFlowState()
        refreshBluetooth()
    }

    function bluetoothFailureCode(text) {
        const normalized = String(text || "").toLowerCase()
        if (bluetoothFlow === "pair"
            && (normalized.indexOf("authentication") >= 0
                || normalized.indexOf("agent") >= 0
                || normalized.indexOf("passkey") >= 0
                || normalized.indexOf("pin") >= 0)) {
            return "authentication-required"
        }

        if (bluetoothFlow === "remove")
            return "forget-failed"

        return bluetoothFlow + "-failed"
    }

    function bluetoothCommandAccepted(exitCode, step, text) {
        if (exitCode === 0)
            return true

        const normalized = String(text || "").toLowerCase()
        if (step === "connect") {
            return normalized.indexOf("alreadyconnected") >= 0
                || normalized.indexOf("already connected") >= 0
        }
        if (step === "disconnect") {
            return normalized.indexOf("notconnected") >= 0
                || normalized.indexOf("not connected") >= 0
        }

        return false
    }

    function runBluetoothStep(step, command) {
        bluetoothStep = String(step || "")
        bluetoothActionProcess.exec(command)
    }

    function beginBluetoothFlow(flow, address) {
        if (busy)
            return

        const requested = normalizedBluetoothAddress(address)
        if (!requested) {
            bluetoothStatusCode = "invalid-address"
            bluetoothDiagnostic = ""
            return
        }

        bluetoothFlow = String(flow || "")
        bluetoothAddress = requested
        bluetoothDeviceName = bluetoothNameForAddress(requested)
        bluetoothDiagnostic = ""
        bluetoothVerifyAttempts = 0
        bluetoothStableChecks = 0
        statusMessage = ""
        lastError = ""
        busyAction = "bluetooth-" + bluetoothFlow
        bluetoothStatusCode = bluetoothFlow === "pair"
            ? "pairing"
            : bluetoothFlow === "connect"
                ? "connecting"
                : bluetoothFlow === "disconnect"
                    ? "disconnecting"
                    : "forgetting"

        if (bluetoothFlow === "pair") {
            runBluetoothStep("pair", [
                "bluetoothctl", "--timeout", "30",
                "--agent=NoInputNoOutput", "pair", requested
            ])
        } else if (bluetoothFlow === "connect") {
            runBluetoothStep("connect", [
                "bluetoothctl", "--timeout", "20",
                "connect", requested
            ])
        } else if (bluetoothFlow === "disconnect") {
            runBluetoothStep("disconnect", [
                "bluetoothctl", "--timeout", "15",
                "disconnect", requested
            ])
        } else if (bluetoothFlow === "remove") {
            runBluetoothStep("remove", [
                "bluetoothctl", "--timeout", "15",
                "remove", requested
            ])
        }
    }

    function scheduleBluetoothVerification(expectedConnected) {
        bluetoothExpectedConnected = Boolean(expectedConnected)
        bluetoothVerifyAttempts = 0
        bluetoothStableChecks = 0
        bluetoothVerifyTimer.restart()
    }

    function setBluetoothEnabled(enabled) {
        bluetoothStatusCode = ""
        bluetoothDiagnostic = ""
        ConnectivityService.setBluetoothEnabled(Boolean(enabled))
        delayedRefresh.restart()
    }

    function scanBluetooth() {
        if (!ConnectivityService.bluetoothEnabled || busy)
            return

        busyAction = "bluetooth-scan"
        bluetoothStatusCode = "scanning"
        bluetoothDiagnostic = ""
        statusMessage = ""
        lastError = ""
        bluetoothScanProcess.exec([
            "bluetoothctl", "--timeout", "12", "scan", "on"
        ])
    }

    function pairBluetooth(address) {
        beginBluetoothFlow("pair", address)
    }

    function connectBluetooth(address) {
        beginBluetoothFlow("connect", address)
    }

    function disconnectBluetooth(address) {
        beginBluetoothFlow("disconnect", address)
    }

    function trustBluetooth(address) {
        const requested = normalizedBluetoothAddress(address)
        if (!requested || busy)
            return

        bluetoothFlow = "connect"
        bluetoothAddress = requested
        bluetoothDeviceName = bluetoothNameForAddress(requested)
        bluetoothStatusCode = "connecting"
        bluetoothDiagnostic = ""
        busyAction = "bluetooth-connect"
        runBluetoothStep("trust", [
            "bluetoothctl", "--timeout", "15", "trust", requested
        ])
    }

    function removeBluetooth(address) {
        beginBluetoothFlow("remove", address)
    }
'''
)
replace_once(
    service,
    '''    Process {
        id: bluetoothAllProcess
        stdout: StdioCollector { id: bluetoothAllOutput }
        onExited: (exitCode, exitStatus) => root.rebuildBluetoothDevices()
    }

    Process {
        id: bluetoothPairedProcess
        stdout: StdioCollector { id: bluetoothPairedOutput }
        onExited: (exitCode, exitStatus) => root.rebuildBluetoothDevices()
    }

    Process {
        id: bluetoothConnectedProcess
        stdout: StdioCollector { id: bluetoothConnectedOutput }
        onExited: (exitCode, exitStatus) => root.rebuildBluetoothDevices()
    }

    Process {
        id: bluetoothScanProcess
        stderr: StdioCollector { id: bluetoothScanError }
        onExited: (exitCode, exitStatus) => {
            root.busyAction = ""
            if (exitCode !== 0)
                root.lastError = String(bluetoothScanError.text || "").trim()
            root.refreshBluetooth()
        }
    }
''',
    '''    Process {
        id: bluetoothAllProcess
        stdout: StdioCollector { id: bluetoothAllOutput }
        stderr: StdioCollector { id: bluetoothAllError }
        onExited: (exitCode, exitStatus) => {
            root.bluetoothAllText = exitCode === 0
                ? String(bluetoothAllOutput.text || "")
                : ""
            root.bluetoothAllReady = true
            if (exitCode !== 0 && !root.bluetoothDiagnostic) {
                root.bluetoothDiagnostic = Parsing.bluetoothCommandSummary(
                    bluetoothAllError.text
                )
            }
            root.maybeRebuildBluetoothDevices()
        }
    }

    Process {
        id: bluetoothPairedProcess
        stdout: StdioCollector { id: bluetoothPairedOutput }
        stderr: StdioCollector { id: bluetoothPairedError }
        onExited: (exitCode, exitStatus) => {
            root.bluetoothPairedText = exitCode === 0
                ? String(bluetoothPairedOutput.text || "")
                : ""
            root.bluetoothPairedReady = true
            if (exitCode !== 0 && !root.bluetoothDiagnostic) {
                root.bluetoothDiagnostic = Parsing.bluetoothCommandSummary(
                    bluetoothPairedError.text
                )
            }
            root.maybeRebuildBluetoothDevices()
        }
    }

    Process {
        id: bluetoothConnectedProcess
        stdout: StdioCollector { id: bluetoothConnectedOutput }
        stderr: StdioCollector { id: bluetoothConnectedError }
        onExited: (exitCode, exitStatus) => {
            root.bluetoothConnectedText = exitCode === 0
                ? String(bluetoothConnectedOutput.text || "")
                : ""
            root.bluetoothConnectedReady = true
            if (exitCode !== 0 && !root.bluetoothDiagnostic) {
                root.bluetoothDiagnostic = Parsing.bluetoothCommandSummary(
                    bluetoothConnectedError.text
                )
            }
            root.maybeRebuildBluetoothDevices()
        }
    }

    Process {
        id: bluetoothActionProcess
        stdout: StdioCollector { id: bluetoothActionOutput }
        stderr: StdioCollector { id: bluetoothActionError }
        onExited: (exitCode, exitStatus) => {
            const combined = String(bluetoothActionOutput.text || "")
                + "\n" + String(bluetoothActionError.text || "")
            const diagnostic = Parsing.bluetoothCommandSummary(combined)

            if (!root.bluetoothCommandAccepted(
                    exitCode,
                    root.bluetoothStep,
                    combined
                )) {
                root.failBluetoothFlow(
                    root.bluetoothFailureCode(combined),
                    diagnostic
                )
                return
            }

            if (root.bluetoothStep === "pair") {
                root.runBluetoothStep("trust", [
                    "bluetoothctl", "--timeout", "15",
                    "trust", root.bluetoothAddress
                ])
            } else if (root.bluetoothStep === "trust") {
                root.runBluetoothStep("connect", [
                    "bluetoothctl", "--timeout", "20",
                    "connect", root.bluetoothAddress
                ])
            } else if (root.bluetoothStep === "connect") {
                root.scheduleBluetoothVerification(true)
            } else if (root.bluetoothStep === "disconnect") {
                root.scheduleBluetoothVerification(false)
            } else if (root.bluetoothStep === "remove") {
                root.finishBluetoothFlow("forgotten")
            }
        }
    }

    Process {
        id: bluetoothInfoProcess
        stdout: StdioCollector { id: bluetoothInfoOutput }
        stderr: StdioCollector { id: bluetoothInfoError }
        onExited: (exitCode, exitStatus) => {
            const info = exitCode === 0
                ? Parsing.parseBluetoothInfo(bluetoothInfoOutput.text)
                : ({ valid: false })
            const pairingMatches = root.bluetoothFlow !== "pair"
                || (Boolean(info.paired) && Boolean(info.trusted))
            const stateMatches = Boolean(info.valid)
                && Boolean(info.connected)
                    === root.bluetoothExpectedConnected
                && pairingMatches

            root.bluetoothStableChecks = stateMatches
                ? root.bluetoothStableChecks + 1
                : 0

            if (root.bluetoothStableChecks >= 2) {
                root.finishBluetoothFlow(
                    root.bluetoothExpectedConnected
                        ? "connected"
                        : "disconnected"
                )
                return
            }

            if (root.bluetoothVerifyAttempts >= 4) {
                const diagnostic = Parsing.bluetoothCommandSummary(
                    String(bluetoothInfoError.text || "")
                )
                if (root.bluetoothFlow === "pair"
                    && Boolean(info.paired)
                    && !Boolean(info.connected)) {
                    root.failBluetoothFlow(
                        "paired-not-connected",
                        diagnostic
                    )
                } else {
                    root.failBluetoothFlow(
                        root.bluetoothFailureCode(diagnostic),
                        diagnostic
                    )
                }
                return
            }

            bluetoothVerifyTimer.restart()
        }
    }

    Timer {
        id: bluetoothVerifyTimer
        interval: 900
        repeat: false
        onTriggered: {
            if (!root.bluetoothAddress || bluetoothInfoProcess.running)
                return

            root.bluetoothVerifyAttempts += 1
            bluetoothInfoProcess.exec([
                "bluetoothctl", "info", root.bluetoothAddress
            ])
        }
    }

    Process {
        id: bluetoothScanProcess
        stderr: StdioCollector { id: bluetoothScanError }
        onExited: (exitCode, exitStatus) => {
            root.busyAction = ""
            root.lastError = ""
            root.bluetoothStatusCode = exitCode === 0
                ? "scan-complete"
                : "scan-failed"
            root.bluetoothDiagnostic = exitCode === 0
                ? ""
                : Parsing.bluetoothCommandSummary(bluetoothScanError.text)
            if (root.bluetoothDiagnostic)
                console.warn("Lumina Bluetooth:", root.bluetoothDiagnostic)
            root.refreshBluetooth()
        }
    }
'''
)
replace_once(
    service,
    '''                bluetoothDevices: root.bluetoothDevices,
                message: root.statusMessage,
                error: root.lastError
''',
    '''                bluetoothDevices: root.bluetoothDevices,
                bluetoothStatus: root.bluetoothStatusCode,
                bluetoothAddress: root.bluetoothAddress,
                bluetoothDeviceName: root.bluetoothDeviceName,
                bluetoothDiagnostic: root.bluetoothDiagnostic,
                message: root.statusMessage,
                error: root.lastError
'''
)

parsing = ROOT / "services/connectivity/ConnectivityParsing.js"
text = parsing.read_text(encoding="utf-8")
append = r'''

function stripAnsi(text) {
    return String(text || "")
        .replace(/\x1B\[[0-?]*[ -\/]*[@-~]/g, "")
}

function parseBluetoothInfo(text) {
    const input = lines(stripAnsi(text))
    const result = {
        valid: false,
        address: "",
        name: "",
        paired: false,
        bonded: false,
        trusted: false,
        connected: false,
        blocked: false
    }

    for (let index = 0; index < input.length; ++index) {
        const deviceMatch = input[index].match(
            /^Device\s+([0-9A-Fa-f:]{17})(?:\s+(.+))?$/
        )
        if (deviceMatch) {
            result.address = deviceMatch[1].toUpperCase()
            if (deviceMatch[2])
                result.name = deviceMatch[2].trim()
            continue
        }

        const propertyMatch = input[index].match(
            /^(Name|Alias|Paired|Bonded|Trusted|Connected|Blocked):\s*(.+)$/
        )
        if (!propertyMatch)
            continue

        const key = propertyMatch[1]
        const value = propertyMatch[2].trim()
        if ((key === "Name" || key === "Alias") && value) {
            result.name = value
        } else if (key === "Paired") {
            result.paired = value.toLowerCase() === "yes"
        } else if (key === "Bonded") {
            result.bonded = value.toLowerCase() === "yes"
        } else if (key === "Trusted") {
            result.trusted = value.toLowerCase() === "yes"
        } else if (key === "Connected") {
            result.connected = value.toLowerCase() === "yes"
        } else if (key === "Blocked") {
            result.blocked = value.toLowerCase() === "yes"
        }
    }

    result.valid = result.address.length === 17
    return result
}

function bluetoothCommandSummary(text) {
    const input = lines(stripAnsi(text)).filter(function(line) {
        return !/^\[(NEW|CHG|DEL|SIGNAL)\]/.test(line)
            && line !== "Discovery started"
            && line !== "Discovery stopped"
            && line !== "Agent registered"
            && line !== "Default agent request successful"
    })

    if (input.length === 0)
        return ""

    const summary = input[input.length - 1]
    return summary.length > 240 ? summary.slice(0, 237) + "..." : summary
}
'''
if "function parseBluetoothInfo" in text:
    raise SystemExit("ConnectivityParsing.js already contains Bluetooth info parsing")
parsing.write_text(text.rstrip() + append + "\n", encoding="utf-8")

page = ROOT / "modules/control/settings/pages/connectivity/BluetoothPage.qml"
replace_once(
    page,
    '''    function activateDevice(device) {
        if (device.connected) {
            ConnectivityManagerService.disconnectBluetooth(device.address)
        } else if (device.paired) {
            ConnectivityManagerService.connectBluetooth(device.address)
        } else {
            ConnectivityManagerService.pairBluetooth(device.address)
        }
    }
''',
    '''    function activateDevice(device) {
        if (device.connected) {
            ConnectivityManagerService.disconnectBluetooth(device.address)
        } else if (device.paired) {
            ConnectivityManagerService.connectBluetooth(device.address)
        } else {
            ConnectivityManagerService.pairBluetooth(device.address)
        }
    }

    function bluetoothStatusDescription() {
        const code = ConnectivityManagerService.bluetoothStatusCode
        const name = ConnectivityManagerService.bluetoothDeviceName
            || ConnectivityManagerService.bluetoothAddress
        const replacements = [name]

        switch (code) {
        case "scanning":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.scanning",
                "Searching for Bluetooth devices"
            )
        case "scan-complete":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.scanComplete",
                "Bluetooth device search completed"
            )
        case "scan-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.scanFailed",
                "Bluetooth device search failed"
            )
        case "pairing":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.pairing",
                "Pairing with %1",
                replacements
            )
        case "connecting":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.connecting",
                "Connecting to %1",
                replacements
            )
        case "disconnecting":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.disconnecting",
                "Disconnecting %1",
                replacements
            )
        case "forgetting":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.forgetting",
                "Forgetting %1",
                replacements
            )
        case "connected":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.connected",
                "%1 is connected",
                replacements
            )
        case "disconnected":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.disconnected",
                "%1 is disconnected",
                replacements
            )
        case "forgotten":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.forgotten",
                "%1 was forgotten",
                replacements
            )
        case "paired-not-connected":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.pairedNotConnected",
                "%1 was paired, but the connection could not be confirmed",
                replacements
            )
        case "authentication-required":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.authenticationRequired",
                "%1 requires a PIN or confirmation that Lumina does not support yet",
                replacements
            )
        case "pair-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.pairFailed",
                "Could not pair with %1",
                replacements
            )
        case "connect-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.connectFailed",
                "Could not confirm a connection to %1",
                replacements
            )
        case "disconnect-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.disconnectFailed",
                "Could not confirm that %1 disconnected",
                replacements
            )
        case "forget-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.forgetFailed",
                "Could not forget %1",
                replacements
            )
        case "invalid-address":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.invalidAddress",
                "The Bluetooth device address is invalid"
            )
        default:
            return ConnectivityService.bluetoothSummary
        }
    }
'''
)
replace_once(
    page,
    '''        description: ConnectivityManagerService.lastError
            || ConnectivityManagerService.statusMessage
''',
    '''        description: root.bluetoothStatusDescription()
'''
)
replace_once(
    page,
    '''                    actionLabel: I18n.tr(
                        "settings.connectivity.disconnect",
                        "Disconnect"
                    )
''',
    '''                    actionLabel: ConnectivityManagerService.busyAction
                        === "bluetooth-disconnect"
                        && ConnectivityManagerService.bluetoothAddress
                            === modelData.address
                        ? I18n.tr(
                            "settings.connectivity.bluetooth.action.disconnecting",
                            "Disconnecting"
                        )
                        : I18n.tr(
                            "settings.connectivity.disconnect",
                            "Disconnect"
                        )
'''
)
replace_once(
    page,
    '''                        actionLabel: I18n.tr(
                            "settings.connectivity.connect",
                            "Connect"
                        )
''',
    '''                        actionLabel: ConnectivityManagerService.busyAction
                            === "bluetooth-connect"
                            && ConnectivityManagerService.bluetoothAddress
                                === modelData.address
                            ? I18n.tr(
                                "settings.connectivity.bluetooth.action.connecting",
                                "Connecting"
                            )
                            : I18n.tr(
                                "settings.connectivity.connect",
                                "Connect"
                            )
'''
)
replace_once(
    page,
    '''                    actionLabel: I18n.tr(
                        "settings.connectivity.bluetooth.pair",
                        "Pair"
                    )
''',
    '''                    actionLabel: ConnectivityManagerService.busyAction
                        === "bluetooth-pair"
                        && ConnectivityManagerService.bluetoothAddress
                            === modelData.address
                        ? I18n.tr(
                            "settings.connectivity.bluetooth.action.pairing",
                            "Pairing"
                        )
                        : I18n.tr(
                            "settings.connectivity.bluetooth.pair",
                            "Pair"
                        )
'''
)

messages = ROOT / "services/i18n/ConnectivityMessages.js"
messages.write_text('''.pragma library

var MESSAGES = {
    "en-US": {
        "settings.connectivity.wired.state.connected": "Connected",
        "settings.connectivity.wired.state.connecting": "Connecting",
        "settings.connectivity.wired.state.disconnected": "Disconnected",
        "settings.connectivity.wired.state.disconnecting": "Disconnecting",
        "settings.connectivity.wired.state.unavailable": "Unavailable",
        "settings.connectivity.wired.state.unmanaged": "Unmanaged",
        "settings.connectivity.wired.state.unknown": "Unknown",
        "settings.connectivity.bluetooth.status.scanning": "Searching for Bluetooth devices",
        "settings.connectivity.bluetooth.status.scanComplete": "Bluetooth device search completed",
        "settings.connectivity.bluetooth.status.scanFailed": "Bluetooth device search failed",
        "settings.connectivity.bluetooth.status.pairing": "Pairing with %1",
        "settings.connectivity.bluetooth.status.connecting": "Connecting to %1",
        "settings.connectivity.bluetooth.status.disconnecting": "Disconnecting %1",
        "settings.connectivity.bluetooth.status.forgetting": "Forgetting %1",
        "settings.connectivity.bluetooth.status.connected": "%1 is connected",
        "settings.connectivity.bluetooth.status.disconnected": "%1 is disconnected",
        "settings.connectivity.bluetooth.status.forgotten": "%1 was forgotten",
        "settings.connectivity.bluetooth.status.pairedNotConnected": "%1 was paired, but the connection could not be confirmed",
        "settings.connectivity.bluetooth.status.authenticationRequired": "%1 requires a PIN or confirmation that Lumina does not support yet",
        "settings.connectivity.bluetooth.status.pairFailed": "Could not pair with %1",
        "settings.connectivity.bluetooth.status.connectFailed": "Could not confirm a connection to %1",
        "settings.connectivity.bluetooth.status.disconnectFailed": "Could not confirm that %1 disconnected",
        "settings.connectivity.bluetooth.status.forgetFailed": "Could not forget %1",
        "settings.connectivity.bluetooth.status.invalidAddress": "The Bluetooth device address is invalid",
        "settings.connectivity.bluetooth.action.pairing": "Pairing",
        "settings.connectivity.bluetooth.action.connecting": "Connecting",
        "settings.connectivity.bluetooth.action.disconnecting": "Disconnecting"
    },
    "pt-BR": {
        "settings.connectivity.wired.state.connected": "Conectada",
        "settings.connectivity.wired.state.connecting": "Conectando",
        "settings.connectivity.wired.state.disconnected": "Desconectada",
        "settings.connectivity.wired.state.disconnecting": "Desconectando",
        "settings.connectivity.wired.state.unavailable": "Indisponível",
        "settings.connectivity.wired.state.unmanaged": "Não gerenciada",
        "settings.connectivity.wired.state.unknown": "Desconhecido",
        "settings.connectivity.bluetooth.status.scanning": "Procurando dispositivos Bluetooth",
        "settings.connectivity.bluetooth.status.scanComplete": "Busca por dispositivos Bluetooth concluída",
        "settings.connectivity.bluetooth.status.scanFailed": "A busca por dispositivos Bluetooth falhou",
        "settings.connectivity.bluetooth.status.pairing": "Pareando com %1",
        "settings.connectivity.bluetooth.status.connecting": "Conectando a %1",
        "settings.connectivity.bluetooth.status.disconnecting": "Desconectando %1",
        "settings.connectivity.bluetooth.status.forgetting": "Esquecendo %1",
        "settings.connectivity.bluetooth.status.connected": "%1 está conectado",
        "settings.connectivity.bluetooth.status.disconnected": "%1 está desconectado",
        "settings.connectivity.bluetooth.status.forgotten": "%1 foi esquecido",
        "settings.connectivity.bluetooth.status.pairedNotConnected": "%1 foi pareado, mas não foi possível confirmar a conexão",
        "settings.connectivity.bluetooth.status.authenticationRequired": "%1 exige PIN ou confirmação, ainda não compatível com o Lumina",
        "settings.connectivity.bluetooth.status.pairFailed": "Não foi possível parear com %1",
        "settings.connectivity.bluetooth.status.connectFailed": "Não foi possível confirmar a conexão com %1",
        "settings.connectivity.bluetooth.status.disconnectFailed": "Não foi possível confirmar que %1 foi desconectado",
        "settings.connectivity.bluetooth.status.forgetFailed": "Não foi possível esquecer %1",
        "settings.connectivity.bluetooth.status.invalidAddress": "O endereço do dispositivo Bluetooth é inválido",
        "settings.connectivity.bluetooth.action.pairing": "Pareando",
        "settings.connectivity.bluetooth.action.connecting": "Conectando",
        "settings.connectivity.bluetooth.action.disconnecting": "Desconectando"
    }
}

function message(locale, key) {
    var requested = String(locale || "en-US")
    var catalog = MESSAGES[requested] || MESSAGES["en-US"]
    return typeof catalog[key] === "string" ? catalog[key] : ""
}
''', encoding="utf-8")

i18n = ROOT / "services/i18n/I18n.qml"
replace_once(
    i18n,
    '''import "BehaviorMessages.js" as BehaviorMessages
import "SettingsMessages.js" as SettingsMessages
''',
    '''import "BehaviorMessages.js" as BehaviorMessages
import "ConnectivityMessages.js" as ConnectivityMessages
import "SettingsMessages.js" as SettingsMessages
'''
)
replace_once(
    i18n,
    '''            || BehaviorMessages.message(locale, key)
            || SettingsMessages.message(locale, key)
''',
    '''            || BehaviorMessages.message(locale, key)
            || ConnectivityMessages.message(locale, key)
            || SettingsMessages.message(locale, key)
'''
)

tests = ROOT / "tests/tst_connectivity_parsing.qml"
replace_once(
    tests,
    '''    function test_mergesBluetoothState() {
''',
    '''    function test_parsesBluetoothInfoAndIgnoresAnsi() {
        const info = Parsing.parseBluetoothInfo(
            "\\x1b[0;94mDevice AA:BB:CC:DD:EE:FF Headphones\\x1b[0m\\n"
            + "    Name: Headphones\\n"
            + "    Paired: yes\\n"
            + "    Bonded: yes\\n"
            + "    Trusted: yes\\n"
            + "    Connected: yes\\n"
            + "    Blocked: no\\n"
        )

        compare(info.valid, true)
        compare(info.address, "AA:BB:CC:DD:EE:FF")
        compare(info.name, "Headphones")
        compare(info.paired, true)
        compare(info.trusted, true)
        compare(info.connected, true)
        compare(info.blocked, false)
    }

    function test_summarizesBluetoothCommandWithoutEventLog() {
        const summary = Parsing.bluetoothCommandSummary(
            "[CHG] Device AA:BB:CC:DD:EE:FF Connected: yes\\n"
            + "Connection successful\\n"
        )

        compare(summary, "Connection successful")
    }

    function test_mergesBluetoothState() {
'''
)

print("Bluetooth state verification migration applied.")

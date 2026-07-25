pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.connectivity
import "ConnectivityParsing.js" as Parsing

Singleton {
    id: root

    readonly property bool busy: actionProcess.running
        || chmodSecretProcess.running
        || wifiCreateProcess.running
        || wifiSecretActivateProcess.running
        || wifiScanProcess.running
        || bluetoothScanProcess.running
    readonly property string secretPath:
        Quickshell.cacheDir + "/lumina-network-secret"

    property var wifiNetworks: []
    property var networkProfiles: []
    property var networkDevices: []
    property var bluetoothDevices: []
    property string statusMessage: ""
    property string lastError: ""
    property string busyAction: ""
    property string pendingWifiProfile: ""
    property string pendingWifiSsid: ""
    property bool pendingWifiSaved: false
    property bool clearSecretAfterAction: false

    function profileTypeMatches(profile, kind) {
        const type = String(profile && profile.type || "").toLowerCase()
        return kind === "wifi"
            ? type.indexOf("wireless") >= 0 || type === "wifi"
            : type.indexOf("ethernet") >= 0 || type === "wired"
    }

    function wifiProfiles() {
        return networkProfiles.filter(function(profile) {
            return root.profileTypeMatches(profile, "wifi")
        })
    }

    function wiredProfiles() {
        return networkProfiles.filter(function(profile) {
            return root.profileTypeMatches(profile, "wired")
        })
    }

    function wifiDevice() {
        for (let index = 0; index < networkDevices.length; ++index) {
            if (String(networkDevices[index].type).toLowerCase() === "wifi")
                return networkDevices[index]
        }

        return null
    }

    function wiredDevices() {
        return networkDevices.filter(function(device) {
            const type = String(device.type || "").toLowerCase()
            return type === "ethernet" || type === "wired"
        })
    }

    function savedWifiProfile(ssid) {
        const requested = String(ssid || "")
        const profiles = wifiProfiles()

        for (let index = 0; index < profiles.length; ++index) {
            if (profiles[index].name === requested
                || profiles[index].name === "Lumina " + requested) {
                return profiles[index]
            }
        }

        return null
    }

    function refreshNetwork() {
        if (!deviceListProcess.running) {
            deviceListProcess.exec([
                "nmcli", "-t", "--escape", "yes",
                "-f", "DEVICE,TYPE,STATE,CONNECTION",
                "device", "status"
            ])
        }

        if (!profileListProcess.running) {
            profileListProcess.exec([
                "nmcli", "-t", "--escape", "yes",
                "-f", "NAME,UUID,TYPE,DEVICE,AUTOCONNECT",
                "connection", "show"
            ])
        }

        if (ConnectivityService.wifiEnabled && !wifiListProcess.running) {
            wifiListProcess.exec([
                "nmcli", "-t", "--escape", "yes",
                "-f", "IN-USE,SSID,SIGNAL,SECURITY,BARS",
                "device", "wifi", "list", "--rescan", "no"
            ])
        } else if (!ConnectivityService.wifiEnabled) {
            wifiNetworks = []
        }
    }

    function refreshBluetooth() {
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

    function refreshAll() {
        refreshNetwork()
        refreshBluetooth()
    }

    function runAction(label, command, clearSecret) {
        if (busy)
            return

        busyAction = String(label || "")
        statusMessage = ""
        lastError = ""
        clearSecretAfterAction = Boolean(clearSecret)
        actionProcess.exec(command)
    }

    function setWifiEnabled(enabled) {
        ConnectivityService.setWifiEnabled(Boolean(enabled))
        delayedRefresh.restart()
    }

    function scanWifi() {
        if (!ConnectivityService.wifiEnabled || busy)
            return

        busyAction = "wifi-scan"
        statusMessage = ""
        lastError = ""
        wifiScanProcess.exec(["nmcli", "device", "wifi", "rescan"])
    }

    function connectWifi(ssid, security, password) {
        const requestedSsid = String(ssid || "").trim()
        const securityLabel = String(security || "").trim()
        const saved = savedWifiProfile(requestedSsid)

        if (!requestedSsid || busy)
            return

        if (saved && !password) {
            activateConnection(saved.uuid)
            return
        }

        if (!securityLabel || securityLabel === "--") {
            runAction(
                "wifi-connect",
                ["nmcli", "device", "wifi", "connect", requestedSsid],
                false
            )
            return
        }

        const secret = String(password || "")
        if (!secret) {
            lastError = "A password is required for this network"
            return
        }

        busyAction = "wifi-connect"
        statusMessage = ""
        lastError = ""
        pendingWifiSsid = requestedSsid
        pendingWifiSaved = Boolean(saved)
        pendingWifiProfile = saved
            ? saved.uuid
            : "Lumina " + requestedSsid
        secretFile.setText(
            "802-11-wireless-security.psk:" + secret + "\n"
        )
        chmodSecretProcess.exec(["chmod", "600", secretPath])
    }

    function continueProtectedWifiConnection() {
        if (!pendingWifiProfile || !pendingWifiSsid) {
            lastError = "Protected Wi-Fi connection state was incomplete"
            busyAction = ""
            clearSecret()
            return
        }

        if (pendingWifiSaved) {
            wifiSecretActivateProcess.exec([
                "nmcli", "connection", "up", "uuid", pendingWifiProfile,
                "passwd-file", secretPath
            ])
        } else {
            wifiCreateProcess.exec([
                "nmcli", "connection", "add",
                "type", "wifi",
                "ifname", "*",
                "con-name", pendingWifiProfile,
                "ssid", pendingWifiSsid,
                "wifi-sec.key-mgmt", "wpa-psk",
                "connection.autoconnect", "yes"
            ])
        }
    }

    function disconnectWifi() {
        const device = wifiDevice()
        if (!device)
            return

        runAction(
            "wifi-disconnect",
            ["nmcli", "device", "disconnect", device.device],
            false
        )
    }

    function activateConnection(uuid) {
        const id = String(uuid || "")
        if (!id)
            return

        runAction(
            "connection-up",
            ["nmcli", "connection", "up", "uuid", id],
            false
        )
    }

    function deactivateConnection(uuid) {
        const id = String(uuid || "")
        if (!id)
            return

        runAction(
            "connection-down",
            ["nmcli", "connection", "down", "uuid", id],
            false
        )
    }

    function forgetConnection(uuid) {
        const id = String(uuid || "")
        if (!id)
            return

        runAction(
            "connection-delete",
            ["nmcli", "connection", "delete", "uuid", id],
            false
        )
    }

    function setAutoconnect(uuid, enabled) {
        const id = String(uuid || "")
        if (!id)
            return

        runAction(
            "connection-autoconnect",
            [
                "nmcli", "connection", "modify", "uuid", id,
                "connection.autoconnect", Boolean(enabled) ? "yes" : "no"
            ],
            false
        )
    }

    function setBluetoothEnabled(enabled) {
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

    function resetPendingWifi() {
        pendingWifiProfile = ""
        pendingWifiSsid = ""
        pendingWifiSaved = false
    }

    function clearSecret() {
        secretFile.setText("")
        if (!removeSecretProcess.running)
            removeSecretProcess.exec(["rm", "-f", secretPath])
    }

    Component.onCompleted: refreshAll()

    Connections {
        target: ConnectivityService

        function onWifiEnabledChanged() {
            root.refreshNetwork()
        }

        function onBluetoothEnabledChanged() {
            root.refreshBluetooth()
        }
    }

    FileView {
        id: secretFile
        path: root.secretPath
        atomicWrites: true
        printErrors: false
    }

    Process {
        id: chmodSecretProcess
        stderr: StdioCollector { id: chmodSecretError }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.continueProtectedWifiConnection()
                return
            }

            root.lastError = String(chmodSecretError.text || "").trim()
                || "Could not secure the temporary network secret"
            root.busyAction = ""
            root.resetPendingWifi()
            root.clearSecret()
        }
    }

    Process { id: removeSecretProcess }

    Process {
        id: deviceListProcess
        stdout: StdioCollector { id: deviceListOutput }
        stderr: StdioCollector { id: deviceListError }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
                root.networkDevices = Parsing.parseDevices(deviceListOutput.text)
            else
                root.lastError = String(deviceListError.text || "").trim()
        }
    }

    Process {
        id: profileListProcess
        stdout: StdioCollector { id: profileListOutput }
        stderr: StdioCollector { id: profileListError }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
                root.networkProfiles = Parsing.parseConnections(profileListOutput.text)
            else
                root.lastError = String(profileListError.text || "").trim()
        }
    }

    Process {
        id: wifiListProcess
        stdout: StdioCollector { id: wifiListOutput }
        stderr: StdioCollector { id: wifiListError }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
                root.wifiNetworks = Parsing.parseWifiNetworks(wifiListOutput.text)
            else
                root.lastError = String(wifiListError.text || "").trim()
        }
    }

    Process {
        id: wifiScanProcess
        stderr: StdioCollector { id: wifiScanError }
        onExited: (exitCode, exitStatus) => {
            root.busyAction = ""
            if (exitCode !== 0)
                root.lastError = String(wifiScanError.text || "").trim()
            root.refreshNetwork()
        }
    }

    Process {
        id: wifiCreateProcess
        stderr: StdioCollector { id: wifiCreateError }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.lastError = String(wifiCreateError.text || "").trim()
                root.busyAction = ""
                root.resetPendingWifi()
                root.clearSecret()
                return
            }

            wifiSecretActivateProcess.exec([
                "nmcli", "connection", "up", "id", root.pendingWifiProfile,
                "passwd-file", root.secretPath
            ])
        }
    }

    Process {
        id: wifiSecretActivateProcess
        stdout: StdioCollector { id: wifiSecretOutput }
        stderr: StdioCollector { id: wifiSecretError }
        onExited: (exitCode, exitStatus) => {
            root.clearSecret()
            root.resetPendingWifi()
            root.busyAction = ""
            root.statusMessage = exitCode === 0
                ? String(wifiSecretOutput.text || "").trim()
                : ""
            root.lastError = exitCode === 0
                ? ""
                : String(wifiSecretError.text || "").trim()
            root.refreshNetwork()
        }
    }

    Process {
        id: actionProcess
        stdout: StdioCollector { id: actionOutput }
        stderr: StdioCollector { id: actionError }
        onExited: (exitCode, exitStatus) => {
            root.statusMessage = exitCode === 0
                ? String(actionOutput.text || "").trim()
                : ""
            root.lastError = exitCode === 0
                ? ""
                : String(actionError.text || "").trim()
            root.busyAction = ""

            if (root.clearSecretAfterAction)
                root.clearSecret()

            root.clearSecretAfterAction = false
            root.refreshAll()
        }
    }

    Process {
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

    Timer {
        id: delayedRefresh
        interval: 650
        repeat: false
        onTriggered: root.refreshAll()
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: root.refreshAll()
    }

    IpcHandler {
        target: "connectivity-manager"

        function refresh(): void {
            root.refreshAll()
        }

        function status(): string {
            return JSON.stringify({
                busy: root.busy,
                action: root.busyAction,
                wifiNetworks: root.wifiNetworks,
                networkProfiles: root.networkProfiles,
                networkDevices: root.networkDevices,
                bluetoothDevices: root.bluetoothDevices,
                message: root.statusMessage,
                error: root.lastError
            })
        }
    }
}

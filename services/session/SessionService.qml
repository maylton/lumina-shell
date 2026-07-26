pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.niri
import qs.stores.config

Singleton {
    id: root

    readonly property bool running: sessionProcess.running

    property string pendingAction: ""
    property string activeAction: ""
    property string status: "idle"
    property string lastError: ""
    property string processOutput: ""
    property string processError: ""

    signal finished(string actionName, bool succeeded, string message)

    function validAction(actionName) {
        return [
            "lock",
            "suspend",
            "logout",
            "reboot",
            "poweroff"
        ].indexOf(String(actionName)) >= 0
    }

    function actionLabel(actionName) {
        switch (String(actionName)) {
        case "lock":
            return "Lock session"
        case "suspend":
            return "Suspend"
        case "logout":
            return "Log out"
        case "reboot":
            return "Restart"
        case "poweroff":
            return "Power off"
        default:
            return "Session action"
        }
    }

    function actionDescription(actionName) {
        switch (String(actionName)) {
        case "lock":
            return "Request the current session locker"
        case "suspend":
            return "Suspend this computer"
        case "logout":
            return "End the current desktop session"
        case "reboot":
            return "Restart the operating system"
        case "poweroff":
            return "Shut down the operating system"
        default:
            return ""
        }
    }

    function commandFor(actionName) {
        const sessionId = String(Quickshell.env("XDG_SESSION_ID") || "")

        switch (String(actionName)) {
        case "lock":
            return sessionId
                ? ["loginctl", "lock-session", sessionId]
                : ["loginctl", "lock-session"]
        case "suspend":
            return ["systemctl", "suspend"]
        case "reboot":
            return ["systemctl", "reboot"]
        case "poweroff":
            return ["systemctl", "poweroff"]
        default:
            return []
        }
    }

    function commandDescription(actionName) {
        if (String(actionName) === "logout")
            return "niri msg action quit --skip-confirmation"

        return commandFor(actionName).join(" ")
    }

    function request(actionName) {
        const action = String(actionName)

        if (!validAction(action) || running)
            return

        if (!requiresConfirmation(action)) {
            pendingAction = action
            confirm()
        } else {
            pendingAction = action
            status = "confirming"
            lastError = ""
        }
    }

    function requiresConfirmation(actionName) {
        if (!ConfigStore.destructiveConfirmations)
            return false

        switch (String(actionName)) {
        case "logout":
            return ConfigStore.sessionConfirmLogout
        case "reboot":
            return ConfigStore.sessionConfirmReboot
        case "poweroff":
            return ConfigStore.sessionConfirmPoweroff
        default:
            return false
        }
    }

    function cancel() {
        if (running)
            return

        pendingAction = ""
        status = "idle"
    }

    function appendOutput(currentValue, rawValue) {
        const text = String(rawValue).trim()

        if (!text)
            return currentValue

        return currentValue
            ? currentValue + "\n" + text
            : text
    }

    function confirm() {
        if (!pendingAction || running)
            return

        const action = pendingAction

        pendingAction = ""
        activeAction = action
        status = "running"
        lastError = ""
        processOutput = ""
        processError = ""

        if (action === "logout") {
            NiriService.quitSession()
            activeAction = ""
            status = "submitted"
            finished(action, true, "Logout submitted")
            return
        }

        const command = commandFor(action)

        if (command.length === 0) {
            activeAction = ""
            status = "failed"
            lastError = "Unsupported session action"
            finished(action, false, lastError)
            return
        }

        sessionProcess.exec(command)
    }

    Process {
        id: sessionProcess

        stdout: SplitParser {
            onRead: line => {
                root.processOutput = root.appendOutput(
                    root.processOutput,
                    line
                )
            }
        }

        stderr: SplitParser {
            onRead: line => {
                root.processError = root.appendOutput(
                    root.processError,
                    line
                )
            }
        }

        onExited: (exitCode, exitStatus) => {
            const action = root.activeAction
            const success = exitCode === 0
            const message = success
                ? root.processOutput.trim()
                : root.processError.trim()
                    || "Session action exited with code " + exitCode

            root.activeAction = ""
            root.status = success ? "succeeded" : "failed"
            root.lastError = success ? "" : message
            root.finished(action, success, message)
        }
    }
}

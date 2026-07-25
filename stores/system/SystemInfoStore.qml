pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "UserIdentity.js" as UserIdentity

Singleton {
    id: root

    readonly property string homeDirectory: String(
        Quickshell.env("HOME") || ""
    ).trim()
    readonly property string userName: {
        const user = String(
            Quickshell.env("USER")
                || Quickshell.env("LOGNAME")
                || ""
        ).trim()

        return user.length > 0 ? user : "User"
    }
    readonly property string displayName:
        realName.length > 0 ? realName : userName
    readonly property string userInitial:
        UserIdentity.initials(displayName, userName)
    readonly property string facePath:
        homeDirectory ? homeDirectory + "/.face" : ""
    readonly property string faceIconPath:
        homeDirectory ? homeDirectory + "/.face.icon" : ""
    readonly property var avatarCandidates:
        UserIdentity.uniquePaths([
            accountIconAvailable ? accountIconPath : "",
            faceAvailable ? facePath : "",
            faceIconAvailable ? faceIconPath : ""
        ])

    property string distributionName: "Linux"
    property string distributionId: "linux"
    property string accountPath: ""
    property string accountIconPath: ""
    property string realName: ""
    property bool accountIconAvailable: false
    property bool faceAvailable: false
    property bool faceIconAvailable: false

    function decodedValue(rawValue) {
        let value = String(rawValue || "").trim()

        if (value.length >= 2
            && (
                (value.charAt(0) === "\"" && value.slice(-1) === "\"")
                || (value.charAt(0) === "'" && value.slice(-1) === "'")
            )) {
            value = value.slice(1, -1)
        }

        return value
            .replace(/\\"/g, "\"")
            .replace(/\\\\/g, "\\")
    }

    function parseOsRelease(rawText) {
        const values = {}
        const lines = String(rawText || "").split(/\r?\n/)

        for (var index = 0; index < lines.length; ++index) {
            const line = lines[index].trim()

            if (!line || line.charAt(0) === "#")
                continue

            const separator = line.indexOf("=")

            if (separator <= 0)
                continue

            const key = line.slice(0, separator).trim()
            const value = decodedValue(line.slice(separator + 1))

            values[key] = value
        }

        distributionName = String(
            values.PRETTY_NAME
                || values.NAME
                || values.ID
                || "Linux"
        )
        distributionId = String(values.ID || "linux")
    }

    function resolveAccountIdentity() {
        if (!accountLookupProcess.running) {
            accountLookupProcess.exec([
                "busctl",
                "--system",
                "call",
                "org.freedesktop.Accounts",
                "/org/freedesktop/Accounts",
                "org.freedesktop.Accounts",
                "FindUserByName",
                "s",
                userName
            ])
        }
    }

    function requestAccountProperties() {
        if (!accountPath)
            return

        accountIconProcess.exec([
            "busctl",
            "--system",
            "get-property",
            "org.freedesktop.Accounts",
            accountPath,
            "org.freedesktop.Accounts.User",
            "IconFile"
        ])
        accountNameProcess.exec([
            "busctl",
            "--system",
            "get-property",
            "org.freedesktop.Accounts",
            accountPath,
            "org.freedesktop.Accounts.User",
            "RealName"
        ])
    }

    Component.onCompleted: resolveAccountIdentity()

    FileView {
        id: osReleaseFile

        path: "/etc/os-release"
        preload: true
        printErrors: false
        onLoaded: root.parseOsRelease(text())
    }

    FileView {
        path: root.accountIconPath
        preload: path.length > 0
        printErrors: false
        onLoaded: root.accountIconAvailable = true
        onLoadFailed: error => root.accountIconAvailable = false
    }

    FileView {
        path: root.facePath
        preload: path.length > 0
        printErrors: false
        onLoaded: root.faceAvailable = true
        onLoadFailed: error => root.faceAvailable = false
    }

    FileView {
        path: root.faceIconPath
        preload: path.length > 0
        printErrors: false
        onLoaded: root.faceIconAvailable = true
        onLoadFailed: error => root.faceIconAvailable = false
    }

    Process {
        id: accountLookupProcess

        stdout: StdioCollector {
            id: accountLookupOutput
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                return

            root.accountPath = UserIdentity.busctlValue(
                accountLookupOutput.text
            )
            root.requestAccountProperties()
        }
    }

    Process {
        id: accountIconProcess

        stdout: StdioCollector {
            id: accountIconOutput
        }

        onExited: (exitCode, exitStatus) => {
            root.accountIconPath = exitCode === 0
                ? UserIdentity.busctlValue(accountIconOutput.text)
                : ""
        }
    }

    Process {
        id: accountNameProcess

        stdout: StdioCollector {
            id: accountNameOutput
        }

        onExited: (exitCode, exitStatus) => {
            root.realName = exitCode === 0
                ? UserIdentity.busctlValue(accountNameOutput.text)
                : ""
        }
    }

    IpcHandler {
        target: "systemInfo"

        function status(): string {
            return JSON.stringify({
                user: root.userName,
                displayName: root.displayName,
                avatarSource: root.avatarCandidates.length > 0
                    ? root.avatarCandidates[0]
                    : "",
                distribution: root.distributionName,
                distributionId: root.distributionId
            })
        }
    }
}

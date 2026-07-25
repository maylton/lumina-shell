pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string userName: {
        const user = String(
            Quickshell.env("USER")
                || Quickshell.env("LOGNAME")
                || ""
        ).trim()

        return user.length > 0 ? user : "User"
    }
    readonly property string userInitial:
        userName.charAt(0).toLocaleUpperCase()

    property string distributionName: "Linux"
    property string distributionId: "linux"

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

    FileView {
        id: osReleaseFile

        path: "/etc/os-release"
        preload: true
        printErrors: false
        onLoaded: root.parseOsRelease(text())
    }

    IpcHandler {
        target: "systemInfo"

        function status(): string {
            return JSON.stringify({
                user: root.userName,
                distribution: root.distributionName,
                distributionId: root.distributionId
            })
        }
    }
}

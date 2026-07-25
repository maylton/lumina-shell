pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string projectRoot: {
        const overridePath = Quickshell.env("LUMINA_ROOT")
        const workingPath = Quickshell.env("PWD")
        return String(overridePath || workingPath || "")
    }
    readonly property string diagnosticsPath:
        projectRoot + "/scripts/check-environment.sh"
    readonly property bool running: diagnosticsProcess.running

    property string niriVersion: "Detecting…"
    property string quickshellVersion: "Detecting…"
    property string commit: "Unavailable"
    property string diagnosticsStatus: "Not run"
    property string diagnosticsOutput: ""
    property string diagnosticsError: ""

    function cleanVersion(text, fallback) {
        const value = String(text || "").trim()
        return value || fallback
    }

    function refresh() {
        if (!niriVersionProcess.running)
            niriVersionProcess.exec(["niri", "--version"])

        if (!quickshellVersionProcess.running)
            quickshellVersionProcess.exec(["qs", "--version"])

        if (projectRoot && !commitProcess.running) {
            commitProcess.exec([
                "git",
                "-C",
                projectRoot,
                "rev-parse",
                "--short",
                "HEAD"
            ])
        }
    }

    function runDiagnostics() {
        if (running || !projectRoot)
            return

        diagnosticsStatus = "Running"
        diagnosticsOutput = ""
        diagnosticsError = ""
        diagnosticsProcess.exec([
            diagnosticsPath,
            "--require-niri"
        ])
    }

    Component.onCompleted: refresh()

    Process {
        id: niriVersionProcess

        stdout: StdioCollector {
            id: niriVersionOutput
        }

        onExited: (exitCode, exitStatus) => {
            root.niriVersion = exitCode === 0
                ? root.cleanVersion(niriVersionOutput.text, "Unknown")
                : "Unavailable"
        }
    }

    Process {
        id: quickshellVersionProcess

        stdout: StdioCollector {
            id: quickshellVersionOutput
        }

        onExited: (exitCode, exitStatus) => {
            root.quickshellVersion = exitCode === 0
                ? root.cleanVersion(
                    quickshellVersionOutput.text,
                    "Unknown"
                )
                : "Unavailable"
        }
    }

    Process {
        id: commitProcess

        stdout: StdioCollector {
            id: commitOutput
        }

        onExited: (exitCode, exitStatus) => {
            root.commit = exitCode === 0
                ? root.cleanVersion(commitOutput.text, "Unavailable")
                : "Unavailable"
        }
    }

    Process {
        id: diagnosticsProcess

        stdout: StdioCollector {
            id: diagnosticsOutput
        }

        stderr: StdioCollector {
            id: diagnosticsError
        }

        onExited: (exitCode, exitStatus) => {
            root.diagnosticsOutput =
                String(diagnosticsOutput.text || "").trim()
            root.diagnosticsError =
                String(diagnosticsError.text || "").trim()
            root.diagnosticsStatus = exitCode === 0
                ? "Passed"
                : "Failed (" + exitCode + ")"
        }
    }

    IpcHandler {
        target: "diagnostics"

        function run(): void {
            root.runDiagnostics()
        }

        function refresh(): void {
            root.refresh()
        }

        function status(): string {
            return JSON.stringify({
                projectRoot: root.projectRoot,
                niriVersion: root.niriVersion,
                quickshellVersion: root.quickshellVersion,
                commit: root.commit,
                running: root.running,
                diagnosticsStatus: root.diagnosticsStatus,
                diagnosticsOutput: root.diagnosticsOutput,
                diagnosticsError: root.diagnosticsError
            })
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.audio
import qs.services.brightness
import qs.services.session
import qs.stores.config
import qs.stores.niri

Singleton {
    id: root

    property bool visible: false
    property string outputName: ""
    property string kind: ""
    property string title: ""
    property string detail: ""
    property string symbol: ""
    property real value: 0
    property bool showProgress: true

    function outputExists(name) {
        const requested = String(name || "")
        const screens = Quickshell.screens || []

        for (var i = 0; i < screens.length; ++i) {
            if (String(screens[i].name || "") === requested)
                return true
        }

        return false
    }

    function focusedOutputName() {
        const workspaces = WorkspaceStore.workspaces || []

        for (var i = 0; i < workspaces.length; ++i) {
            if (workspaces[i].is_focused
                && outputExists(workspaces[i].output)) {
                return String(workspaces[i].output)
            }
        }

        const screens = Quickshell.screens || []
        return screens.length > 0 ? String(screens[0].name || "") : ""
    }

    function show(
        osdKind,
        osdTitle,
        osdDetail,
        osdSymbol,
        osdValue,
        progressVisible,
        requestedOutput
    ) {
        const targetOutput = outputExists(requestedOutput)
            ? String(requestedOutput)
            : focusedOutputName()

        if (!targetOutput || !ConfigStore.osdEnabled)
            return

        kind = String(osdKind || "")
        title = String(osdTitle || "")
        detail = String(osdDetail || "")
        symbol = String(osdSymbol || "")
        value = Math.max(0, Math.min(1, Number(osdValue) || 0))
        showProgress = Boolean(progressVisible)
        outputName = targetOutput
        visible = true
        hideTimer.restart()
    }

    function showOutputVolume(value, muted, requestedOutput) {
        if (!ConfigStore.osdVolumeEnabled)
            return

        const percentage = Math.round(Number(value || 0) * 100)

        show(
            "volume",
            muted ? "Audio muted" : "Output volume",
            ConfigStore.osdShowPercentage
                ? muted ? AudioService.outputName : percentage + "%"
                : "",
            muted ? "×" : "♪",
            muted ? 0 : value,
            true,
            requestedOutput
        )
    }

    function showInputVolume(value, muted, requestedOutput) {
        if (!ConfigStore.osdMicrophoneEnabled)
            return

        const percentage = Math.round(Number(value || 0) * 100)

        show(
            "microphone",
            muted ? "Microphone muted" : "Microphone",
            ConfigStore.osdShowPercentage
                ? muted ? AudioService.inputName : percentage + "%"
                : "",
            muted ? "×" : "●",
            muted ? 0 : value,
            true,
            requestedOutput
        )
    }

    function showBrightness(percentage, requestedOutput) {
        if (!ConfigStore.osdBrightnessEnabled)
            return

        show(
            "brightness",
            "Brightness",
            ConfigStore.osdShowPercentage
                ? Math.round(percentage) + "%"
                : "",
            "☀",
            Number(percentage) / 100,
            true,
            requestedOutput
        )
    }

    function showLockState(lockName, enabled, requestedOutput) {
        const name = String(lockName || "Lock")

        show(
            "lock",
            name,
            Boolean(enabled) ? "On" : "Off",
            Boolean(enabled) ? "A" : "a",
            Boolean(enabled) ? 1 : 0,
            false,
            requestedOutput
        )
    }

    Connections {
        target: AudioService

        function onOutputAdjusted(value, muted) {
            root.showOutputVolume(value, muted, "")
        }

        function onInputAdjusted(value, muted) {
            root.showInputVolume(value, muted, "")
        }
    }

    Connections {
        target: BrightnessService

        function onAdjusted(percentage) {
            root.showBrightness(percentage, "")
        }
    }

    Connections {
        target: SessionService

        function onFinished(actionName, succeeded, message) {
            if (actionName === "lock" && succeeded) {
                root.show(
                    "lock",
                    "Session lock",
                    "Requested",
                    "●",
                    1,
                    false,
                    ""
                )
            }
        }
    }

    Connections {
        target: Quickshell

        function onScreensChanged() {
            if (root.visible && !root.outputExists(root.outputName))
                root.visible = false
        }
    }

    Timer {
        id: hideTimer

        interval: ConfigStore.osdDuration
        repeat: false
        onTriggered: root.visible = false
    }

    IpcHandler {
        target: "osd"

        function volume(percent: int, muted: bool, outputName: string): void {
            root.showOutputVolume(percent / 100, muted, outputName)
        }

        function brightness(percent: int, outputName: string): void {
            root.showBrightness(percent, outputName)
        }

        function lock(lockName: string, enabled: bool, outputName: string): void {
            root.showLockState(lockName, enabled, outputName)
        }

        function hide(): void {
            root.visible = false
        }

        function status(): string {
            return JSON.stringify({
                visible: root.visible,
                output: root.outputName,
                kind: root.kind,
                title: root.title,
                detail: root.detail,
                value: root.value
            })
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool ready: Pipewire.ready
    readonly property bool outputAvailable: sink
        && sink.ready
        && sink.audio
    readonly property bool inputAvailable: source
        && source.ready
        && source.audio
    readonly property real outputVolume: outputAvailable
        ? sink.audio.volume
        : 0
    readonly property real inputVolume: inputAvailable
        ? source.audio.volume
        : 0
    readonly property bool outputMuted: outputAvailable
        ? sink.audio.muted
        : false
    readonly property bool inputMuted: inputAvailable
        ? source.audio.muted
        : false
    readonly property string outputName: outputAvailable
        ? String(sink.description || sink.nickname || sink.name || "Audio output")
        : "No audio output"
    readonly property string inputName: inputAvailable
        ? String(source.description || source.nickname || source.name || "Microphone")
        : "No microphone"

    signal outputAdjusted(real value, bool muted)
    signal inputAdjusted(real value, bool muted)

    function clampVolume(value) {
        return Math.max(0, Math.min(1, Number(value) || 0))
    }

    function setOutputVolume(value) {
        if (!outputAvailable)
            return

        sink.audio.volume = clampVolume(value)

        if (sink.audio.muted && value > 0)
            sink.audio.muted = false

        outputAdjusted(sink.audio.volume, sink.audio.muted)
    }

    function changeOutputVolume(delta) {
        setOutputVolume(outputVolume + Number(delta || 0))
    }

    function toggleOutputMute() {
        if (!outputAvailable)
            return

        sink.audio.muted = !sink.audio.muted
        outputAdjusted(sink.audio.volume, sink.audio.muted)
    }

    function setInputVolume(value) {
        if (!inputAvailable)
            return

        source.audio.volume = clampVolume(value)

        if (source.audio.muted && value > 0)
            source.audio.muted = false

        inputAdjusted(source.audio.volume, source.audio.muted)
    }

    function changeInputVolume(delta) {
        setInputVolume(inputVolume + Number(delta || 0))
    }

    function toggleInputMute() {
        if (!inputAvailable)
            return

        source.audio.muted = !source.audio.muted
        inputAdjusted(source.audio.volume, source.audio.muted)
    }

    function statusObject() {
        return {
            ready: ready,
            output: {
                available: outputAvailable,
                name: outputName,
                volume: Math.round(outputVolume * 100),
                muted: outputMuted
            },
            input: {
                available: inputAvailable,
                name: inputName,
                volume: Math.round(inputVolume * 100),
                muted: inputMuted
            }
        }
    }

    PwObjectTracker {
        objects: [
            root.sink,
            root.source
        ]
    }

    IpcHandler {
        target: "audio"

        function output(percent: int): void {
            root.setOutputVolume(percent / 100)
        }

        function outputStep(percent: int): void {
            root.changeOutputVolume(percent / 100)
        }

        function outputMute(): void {
            root.toggleOutputMute()
        }

        function input(percent: int): void {
            root.setInputVolume(percent / 100)
        }

        function inputStep(percent: int): void {
            root.changeInputVolume(percent / 100)
        }

        function inputMute(): void {
            root.toggleInputMute()
        }

        function status(): string {
            return JSON.stringify(root.statusObject())
        }
    }
}

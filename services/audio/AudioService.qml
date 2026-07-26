pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "AudioNodePolicy.js" as AudioNodePolicy

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var trackedNodes: Pipewire.nodes.values
    readonly property var outputDevices: nodesFor(
        AudioNodePolicy.OUTPUT_DEVICE
    )
    readonly property var inputDevices: nodesFor(
        AudioNodePolicy.INPUT_DEVICE
    )
    readonly property var playbackStreams: nodesFor(
        AudioNodePolicy.PLAYBACK_STREAM
    )
    readonly property var captureStreams: nodesFor(
        AudioNodePolicy.CAPTURE_STREAM
    )
    readonly property var applicationStreams:
        playbackStreams.concat(captureStreams)
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
    signal panelToggleRequested(string outputName)

    function clampVolume(value) {
        return Math.max(0, Math.min(1, Number(value) || 0))
    }

    function nodesFor(requestedKind) {
        const values = Pipewire.nodes.values || []
        const result = []

        for (var index = 0; index < values.length; ++index) {
            const node = values[index]

            if (!node
                || !node.ready
                || !node.audio
                || AudioNodePolicy.kind(node) !== requestedKind)
                continue

            result.push(node)
        }

        result.sort(function(first, second) {
            const firstDefault = isDefaultNode(first)
            const secondDefault = isDefaultNode(second)

            if (firstDefault !== secondDefault)
                return firstDefault ? -1 : 1

            return nodeLabel(first).localeCompare(nodeLabel(second))
        })
        return result
    }

    function nodeLabel(node) {
        return AudioNodePolicy.label(node)
    }

    function nodeDetail(node) {
        return AudioNodePolicy.detail(node)
    }

    function nodeIconName(node) {
        return AudioNodePolicy.iconName(node)
    }

    function isPlaybackStream(node) {
        return AudioNodePolicy.isPlaybackStream(node)
    }

    function isCaptureStream(node) {
        return AudioNodePolicy.isCaptureStream(node)
    }

    function isDefaultOutput(node) {
        return Boolean(node) && node === sink
    }

    function isDefaultInput(node) {
        return Boolean(node) && node === source
    }

    function isDefaultNode(node) {
        return isDefaultOutput(node) || isDefaultInput(node)
    }

    function setDefaultOutput(node) {
        if (!node || outputDevices.indexOf(node) < 0)
            return

        Pipewire.preferredDefaultAudioSink = node
    }

    function setDefaultInput(node) {
        if (!node || inputDevices.indexOf(node) < 0)
            return

        Pipewire.preferredDefaultAudioSource = node
    }

    function setNodeVolume(node, value) {
        if (!node || !node.ready || !node.audio)
            return false

        const requested = clampVolume(value)
        node.audio.volume = requested

        if (node.audio.muted && requested > 0)
            node.audio.muted = false

        return true
    }

    function toggleNodeMute(node) {
        if (!node || !node.ready || !node.audio)
            return false

        node.audio.muted = !node.audio.muted
        return true
    }

    function setOutputVolume(value) {
        if (!setNodeVolume(sink, value))
            return

        outputAdjusted(sink.audio.volume, sink.audio.muted)
    }

    function changeOutputVolume(delta) {
        setOutputVolume(outputVolume + Number(delta || 0))
    }

    function toggleOutputMute() {
        if (!toggleNodeMute(sink))
            return

        outputAdjusted(sink.audio.volume, sink.audio.muted)
    }

    function setInputVolume(value) {
        if (!setNodeVolume(source, value))
            return

        inputAdjusted(source.audio.volume, source.audio.muted)
    }

    function changeInputVolume(delta) {
        setInputVolume(inputVolume + Number(delta || 0))
    }

    function toggleInputMute() {
        if (!toggleNodeMute(source))
            return

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
            },
            outputDeviceCount: outputDevices.length,
            inputDeviceCount: inputDevices.length,
            playbackStreamCount: playbackStreams.length,
            captureStreamCount: captureStreams.length
        }
    }

    PwObjectTracker {
        objects: root.trackedNodes
    }

    IpcHandler {
        target: "audio"

        function panel(outputName: string): void {
            root.panelToggleRequested(String(outputName || ""))
        }

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

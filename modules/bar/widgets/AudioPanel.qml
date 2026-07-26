pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.design
import qs.modules.control
import qs.services.audio
import qs.services.i18n
import qs.stores.config
import qs.stores.shell
import "../../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

BarPanelWindow {
    id: root

    required property string outputName
    property var panelWindow: null

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real availableScreenHeight:
        panelWindow && panelWindow.screen
            ? panelWindow.screen.height
            : 720
    readonly property real panelWidth: Math.min(560, width - 32)
    readonly property real panelHeight: Math.max(
        420,
        Math.min(
            720,
            availableScreenHeight
                - SurfacePlacementPolicy.barWindowHeight(
                    ConfigStore.barHeight,
                    ConfigStore.barSurfaceMode,
                    ConfigStore.barMargin
                )
                - ConfigStore.barPanelGap
                - luminaDesign.spacing.medium
        )
    )

    function dismiss() {
        OverlayStore.close("audio")
    }

    function deviceSubtitle(node, fallbackKey, fallback) {
        const detail = AudioService.nodeDetail(node)
        return detail.length > 0
            ? detail
            : I18n.tr(fallbackKey, fallback)
    }

    function streamSubtitle(node) {
        const kind = AudioService.isCaptureStream(node)
            ? I18n.tr("bar.audio.stream.recording", "Recording")
            : I18n.tr("bar.audio.stream.playback", "Playback")
        const detail = AudioService.nodeDetail(node)
        return detail.length > 0 ? kind + " · " + detail : kind
    }

    panelId: "audio"
    panelOutputName: outputName
    panelVisible: panelWindow !== null
        && OverlayStore.isOpenFor("audio", outputName)
    layerNamespace: "lumina-audio-panel"
    screen: panelWindow ? panelWindow.screen : null
    surfaceItem: audioSurface
    surfaceRadius: audioSurface.radius
    onDismissRequested: dismiss()

    onClosed: dismiss()

    ShellSurface {
        id: audioSurface

        x: SurfacePlacementPolicy.horizontalX(
            OverlayStore.activePlacement,
            OverlayStore.activeAnchorX,
            width,
            root.width,
            root.luminaDesign.spacing.medium
        )
        width: root.panelWidth
        height: root.panelHeight
        radius: root.luminaDesign.shape.extraLarge
        clip: true

        Column {
            anchors {
                fill: parent
                margins: root.luminaDesign.spacing.large
            }
            spacing: root.luminaDesign.spacing.medium

            Item {
                width: parent.width
                height: 58

                Column {
                    anchors {
                        left: parent.left
                        right: statusPill.left
                        rightMargin: root.luminaDesign.spacing.medium
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 2

                    Text {
                        width: parent.width
                        text: I18n.tr("bar.audio.panel.title", "Audio")
                        color: root.luminaDesign.color.onSurface
                        elide: Text.ElideRight
                        font.pixelSize:
                            root.luminaDesign.typography.titleLarge
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        text: AudioService.ready
                            ? I18n.tr(
                                "bar.audio.panel.description",
                                "Devices and application volume"
                            )
                            : I18n.tr(
                                "bar.audio.notReady",
                                "PipeWire is not ready"
                            )
                        color: root.luminaDesign.color.textMuted
                        elide: Text.ElideRight
                        font.pixelSize:
                            root.luminaDesign.typography.labelMedium
                    }
                }

                Rectangle {
                    id: statusPill

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    width: statusLabel.implicitWidth + 22
                    height: 32
                    radius: root.luminaDesign.shape.full
                    color: AudioService.ready
                        ? root.luminaDesign.color.accentContainer
                        : root.luminaDesign.color.errorContainer

                    Text {
                        id: statusLabel

                        anchors.centerIn: parent
                        text: AudioService.ready
                            ? I18n.tr("bar.audio.ready", "Ready")
                            : I18n.tr("bar.audio.unavailable", "Unavailable")
                        color: AudioService.ready
                            ? root.luminaDesign.color.onAccentContainer
                            : root.luminaDesign.color.onErrorContainer
                        font.pixelSize:
                            root.luminaDesign.typography.labelSmall
                        font.weight: Font.Bold
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: root.luminaDesign.color.divider
            }

            Flickable {
                id: audioFlickable

                width: parent.width
                height: parent.height - 58
                    - parent.spacing * 2 - 1
                contentWidth: width
                contentHeight: contentColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 2600

                Controls.ScrollBar.vertical: Controls.ScrollBar {
                    policy: audioFlickable.contentHeight
                        > audioFlickable.height
                            ? Controls.ScrollBar.AsNeeded
                            : Controls.ScrollBar.AlwaysOff
                }

                Column {
                    id: contentColumn

                    width: audioFlickable.width
                        - (audioFlickable.contentHeight
                            > audioFlickable.height ? 12 : 0)
                    spacing: root.luminaDesign.spacing.small

                    Text {
                        width: parent.width
                        text: I18n.tr(
                            "bar.audio.section.output",
                            "Output devices"
                        )
                        color: root.luminaDesign.color.onSurface
                        font.pixelSize:
                            root.luminaDesign.typography.titleMedium
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        visible: AudioService.outputDevices.length === 0
                        text: I18n.tr(
                            "bar.audio.empty.output",
                            "No audio output is available"
                        )
                        color: root.luminaDesign.color.textMuted
                        wrapMode: Text.Wrap
                        font.pixelSize:
                            root.luminaDesign.typography.bodyMedium
                    }

                    Repeater {
                        model: AudioService.outputDevices

                        delegate: AudioVolumeRow {
                            required property var modelData

                            width: contentColumn.width
                            node: modelData
                            title: AudioService.nodeLabel(modelData)
                            subtitle: root.deviceSubtitle(
                                modelData,
                                "bar.audio.outputDevice",
                                "Output device"
                            )
                            iconName:
                                AudioService.nodeIconName(modelData)
                            fallbackSymbol: "♪"
                            selectable: true
                            selected:
                                AudioService.isDefaultOutput(modelData)
                            onSelectedRequested:
                                AudioService.setDefaultOutput(modelData)
                            onVolumeRequested: value =>
                                AudioService.setNodeVolume(modelData, value)
                            onMuteRequested:
                                AudioService.toggleNodeMute(modelData)
                        }
                    }

                    Item {
                        width: parent.width
                        height: root.luminaDesign.spacing.medium
                    }

                    Text {
                        width: parent.width
                        text: I18n.tr(
                            "bar.audio.section.input",
                            "Input devices"
                        )
                        color: root.luminaDesign.color.onSurface
                        font.pixelSize:
                            root.luminaDesign.typography.titleMedium
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        visible: AudioService.inputDevices.length === 0
                        text: I18n.tr(
                            "bar.audio.empty.input",
                            "No microphone is available"
                        )
                        color: root.luminaDesign.color.textMuted
                        wrapMode: Text.Wrap
                        font.pixelSize:
                            root.luminaDesign.typography.bodyMedium
                    }

                    Repeater {
                        model: AudioService.inputDevices

                        delegate: AudioVolumeRow {
                            required property var modelData

                            width: contentColumn.width
                            node: modelData
                            title: AudioService.nodeLabel(modelData)
                            subtitle: root.deviceSubtitle(
                                modelData,
                                "bar.audio.inputDevice",
                                "Input device"
                            )
                            iconName:
                                AudioService.nodeIconName(modelData)
                            fallbackSymbol: "●"
                            selectable: true
                            selected:
                                AudioService.isDefaultInput(modelData)
                            onSelectedRequested:
                                AudioService.setDefaultInput(modelData)
                            onVolumeRequested: value =>
                                AudioService.setNodeVolume(modelData, value)
                            onMuteRequested:
                                AudioService.toggleNodeMute(modelData)
                        }
                    }

                    Item {
                        width: parent.width
                        height: root.luminaDesign.spacing.medium
                    }

                    Text {
                        width: parent.width
                        text: I18n.tr(
                            "bar.audio.section.applications",
                            "Applications"
                        )
                        color: root.luminaDesign.color.onSurface
                        font.pixelSize:
                            root.luminaDesign.typography.titleMedium
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        width: parent.width
                        visible:
                            AudioService.applicationStreams.length === 0
                        height: visible ? 82 : 0
                        radius: root.luminaDesign.shape.large
                        color: root.luminaDesign.color.surfaceBase
                        border.width: 1
                        border.color: root.luminaDesign.color.outline

                        Column {
                            anchors {
                                fill: parent
                                margins: root.luminaDesign.spacing.medium
                            }
                            spacing: 3

                            Text {
                                width: parent.width
                                text: I18n.tr(
                                    "bar.audio.empty.applications",
                                    "No application is using audio"
                                )
                                color: root.luminaDesign.color.onSurface
                                elide: Text.ElideRight
                                font.pixelSize:
                                    root.luminaDesign.typography.bodyMedium
                                font.weight: Font.DemiBold
                            }

                            Text {
                                width: parent.width
                                text: I18n.tr(
                                    "bar.audio.empty.applicationsDescription",
                                    "Playback and recording controls appear here automatically"
                                )
                                color: root.luminaDesign.color.textMuted
                                wrapMode: Text.Wrap
                                font.pixelSize:
                                    root.luminaDesign.typography.labelSmall
                            }
                        }
                    }

                    Repeater {
                        model: AudioService.applicationStreams

                        delegate: AudioVolumeRow {
                            required property var modelData

                            width: contentColumn.width
                            node: modelData
                            title: AudioService.nodeLabel(modelData)
                            subtitle: root.streamSubtitle(modelData)
                            iconName:
                                AudioService.nodeIconName(modelData)
                            fallbackSymbol:
                                AudioService.isCaptureStream(modelData)
                                    ? "●"
                                    : "♪"
                            onVolumeRequested: value =>
                                AudioService.setNodeVolume(modelData, value)
                            onMuteRequested:
                                AudioService.toggleNodeMute(modelData)
                        }
                    }

                    Item {
                        width: parent.width
                        height: root.luminaDesign.spacing.small
                    }
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import qs.services.audio
import qs.services.i18n
import qs.stores.config
import qs.stores.shell

SystemStatusItem {
    id: root

    required property string outputName
    property var panelWindow: null
    property bool compact: false

    readonly property bool layoutAvailable: AudioService.ready
    readonly property string textMode: String(
        ConfigStore.widgetSetting("audio", "textMode", "percentage")
    )
    readonly property string surfacePlacement: String(
        ConfigStore.widgetSetting(
            "audio",
            "surfacePlacement",
            "near-widget"
        )
    )
    readonly property string unavailableLabel: I18n.tr(
        "common.unavailable",
        "Unavailable"
    )
    readonly property string mutedLabel: I18n.tr(
        "bar.audio.state.muted",
        "Muted"
    )
    readonly property string activeLabel: I18n.tr(
        "bar.audio.state.active",
        "Active"
    )
    readonly property string statusLabel:
        !AudioService.outputAvailable
            ? textMode === "icon" ? "" : unavailableLabel
            : textMode === "icon"
                ? ""
                : textMode === "state"
                    ? AudioService.outputMuted ? mutedLabel : activeLabel
                    : AudioService.outputMuted
                        ? mutedLabel
                        : Math.round(AudioService.outputVolume * 100) + "%"
    readonly property string statusIcon:
        !AudioService.outputAvailable
            ? "audio-card-symbolic"
            : AudioService.outputMuted
                ? "audio-volume-muted-symbolic"
                : AudioService.outputVolume >= 0.66
                    ? "audio-volume-high-symbolic"
                    : AudioService.outputVolume >= 0.33
                        ? "audio-volume-medium-symbolic"
                        : AudioService.outputVolume > 0
                            ? "audio-volume-low-symbolic"
                            : "audio-volume-muted-symbolic"

    visible: layoutAvailable
    individual: true
    interactive: true
    selected: audioPanel.visible
    showBackground: Boolean(
        ConfigStore.widgetSetting("audio", "showBackground", true)
    )
    showLabel: !compact && textMode !== "icon"
    iconName: statusIcon
    fallbackSymbol: AudioService.outputMuted ? "×" : "♪"
    label: statusLabel
    description: AudioService.outputAvailable
        ? I18n.tr(
            "bar.audio.accessible",
            "Volume %1 percent, %2",
            [
                Math.round(AudioService.outputVolume * 100),
                AudioService.outputMuted
                    ? mutedLabel
                    : AudioService.outputName
            ]
        )
        : AudioService.outputName
    alert: AudioService.outputAvailable && AudioService.outputMuted
    onActivated: localX => togglePopup(localX)

    function mappedAnchorGeometry(localX) {
        const top = root.mapToItem(null, Number(localX), 0)
        const bottom = root.mapToItem(
            null,
            Number(localX),
            root.height
        )

        return {
            x: Number(top.x),
            top: Number(top.y),
            bottom: Number(bottom.y)
        }
    }

    function togglePopup(localX) {
        const anchor = mappedAnchorGeometry(localX)

        BarPanelCoordinator.requestToggle(
            "audio",
            root.outputName,
            surfacePlacement,
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

    AudioPanel {
        id: audioPanel

        outputName: root.outputName
        panelWindow: root.panelWindow
    }

    Connections {
        target: BarPanelCoordinator

        function onOpenRequested(
            panelId,
            outputName,
            placement,
            anchorX,
            anchorTop,
            anchorBottom
        ) {
            if (panelId !== "audio" || outputName !== root.outputName)
                return

            OverlayStore.prepareFor(
                "audio",
                root.outputName,
                placement,
                anchorX,
                anchorTop,
                anchorBottom
            )
            OverlayStore.openFor("audio", root.outputName)
        }

        function onCloseRequested(panelId, outputName) {
            if (panelId === "audio" && outputName === root.outputName)
                audioPanel.dismiss()
        }
    }

    Connections {
        target: AudioService

        function onPanelToggleRequested(outputName) {
            if (String(outputName || "") === root.outputName)
                root.togglePopup(root.width / 2)
        }
    }
}

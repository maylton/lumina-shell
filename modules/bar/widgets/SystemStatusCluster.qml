import QtQuick
import qs.design
import qs.services.audio
import qs.services.connectivity
import qs.services.power
import qs.stores.config
import qs.stores.control
import qs.stores.shell
import "ExpressiveBatteryGeometry.js" as BatteryGeometry

Rectangle {
    id: root

    required property string outputName
    property var panelWindow: null
    property bool compact: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool individual:
        ConfigStore.widgetSetting(
            "system-status",
            "layout",
            "grouped"
        ) === "individual"
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "system-status",
            "showBackground",
            true
        )
    )
    readonly property bool showNetwork:
        Boolean(ConfigStore.widgetSetting(
            "system-status",
            "showNetwork",
            true
        ))
    readonly property bool showAudio:
        Boolean(ConfigStore.widgetSetting(
            "system-status",
            "showAudio",
            true
        ))
        && AudioService.ready
    readonly property bool showBattery:
        Boolean(ConfigStore.widgetSetting(
            "system-status",
            "showBattery",
            true
        ))
        && PowerService.batteryAvailable
    readonly property string networkTextMode: String(
        ConfigStore.widgetSetting(
            "system-status",
            "networkTextMode",
            "summary"
        )
    )
    readonly property string audioTextMode: String(
        ConfigStore.widgetSetting(
            "system-status",
            "audioTextMode",
            "percentage"
        )
    )
    readonly property string batteryTextMode: String(
        ConfigStore.widgetSetting(
            "system-status",
            "batteryTextMode",
            "percentage"
        )
    )
    readonly property string networkLabel: {
        if (networkTextMode === "icon")
            return ""

        if (networkTextMode === "name") {
            return ConnectivityService.wifiConnected
                ? ConnectivityService.wifiName
                : ConnectivityService.networkSummary
        }

        if (networkTextMode === "type") {
            return ConnectivityService.wifiConnected
                ? "Wi-Fi"
                : ConnectivityService.wiredConnected
                    ? "Wired"
                    : "Offline"
        }

        return ConnectivityService.networkSummary
    }
    readonly property string audioLabel:
        !AudioService.outputAvailable
            ? audioTextMode === "icon" ? "" : "Unavailable"
            : audioTextMode === "icon"
            ? ""
            : audioTextMode === "state"
                ? AudioService.outputMuted ? "Muted" : "Active"
                : AudioService.outputMuted
                    ? "Muted"
                    : Math.round(AudioService.outputVolume * 100) + "%"
    readonly property string batteryLabel:
        batteryTextMode === "icon"
            ? ""
            : batteryTextMode === "state"
                ? PowerService.batteryState
                : PowerService.batteryPercentage + "%"
    readonly property int itemCount:
        Number(showNetwork)
        + Number(showAudio)
        + Number(showBattery)
    readonly property bool expanded:
        ControlCenterStore.activeOutputName === outputName
        && ControlCenterStore.activePage === "dashboard"
    readonly property string networkIcon:
        ConnectivityService.wifiConnected
            ? "network-wireless-signal-excellent-symbolic"
            : ConnectivityService.wiredConnected
                ? "network-wired-symbolic"
                : "network-offline-symbolic"
    readonly property string audioIcon:
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
    readonly property bool batteryCharging:
        BatteryGeometry.isChargingState(PowerService.batteryState)
    readonly property string accessibleSummary: [
        showNetwork
            ? "Network " + ConnectivityService.networkSummary
            : "",
        showAudio
            ? AudioService.outputAvailable
                ? "Volume "
                    + Math.round(AudioService.outputVolume * 100)
                    + " percent"
                    + (AudioService.outputMuted ? ", muted" : "")
                    + ", " + AudioService.outputName
                : AudioService.outputName
            : "",
        showBattery
            ? "Battery " + PowerService.batteryPercentage
                + " percent, " + PowerService.batteryState
            : ""
    ].filter(value => value.length > 0).join(". ")

    visible: itemCount > 0
    implicitWidth: visible
        ? statusRow.implicitWidth
            + (
                individual
                    ? 0
                    : luminaDesign.spacing.barWidgetPadding * 2
            )
        : 0
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded || statusMouse.containsMouse
        ? luminaDesign.shape.full
        : luminaDesign.shape.barLarge
    color: individual
        ? "transparent"
        : expanded || statusMouse.containsMouse
            ? luminaDesign.color.accentContainer
            : showBackground
                ? luminaDesign.color.surfaceMuted
                : "transparent"
    scale: statusMouse.pressed ? 0.96 : 1
    activeFocusOnTab: visible
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: "Open system controls"
    Accessible.description: accessibleSummary
    Accessible.focusable: visible
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate(root.width / 2)

    function mappedAnchorGeometry(item, localX) {
        const target = item || root
        const top = target.mapToItem(
            null,
            Number(localX),
            0
        )
        const bottom = target.mapToItem(
            null,
            Number(localX),
            target.height
        )

        return {
            x: Number(top.x),
            top: Number(top.y),
            bottom: Number(bottom.y)
        }
    }

    function activate(localX) {
        const anchor = mappedAnchorGeometry(
            root,
            isFinite(Number(localX)) ? Number(localX) : root.width / 2
        )

        BarPanelCoordinator.requestToggle(
            "dashboard",
            root.outputName,
            "near-widget",
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

    function toggleNetworkPopup(localX) {
        const anchor = mappedAnchorGeometry(networkItem, localX)

        BarPanelCoordinator.requestToggle(
            "network",
            root.outputName,
            "near-widget",
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

    function toggleAudioPopup(localX) {
        const anchor = mappedAnchorGeometry(audioItem, localX)

        BarPanelCoordinator.requestToggle(
            "audio",
            root.outputName,
            "near-widget",
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

    Keys.onSpacePressed: event => {
        activate(root.width / 2)
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activate(root.width / 2)
        event.accepted = true
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
            if (outputName !== root.outputName)
                return

            if (panelId === "network") {
                OverlayStore.prepareFor(
                    "network",
                    root.outputName,
                    placement,
                    anchorX,
                    anchorTop,
                    anchorBottom
                )
                OverlayStore.openFor("network", root.outputName)
                Qt.callLater(function() {
                    if (OverlayStore.isOpenFor(
                        "network",
                        root.outputName
                    )) {
                        networkPanel.prepareContent()
                    }
                })
            } else if (panelId === "audio") {
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
        }

        function onCloseRequested(panelId, outputName) {
            if (outputName !== root.outputName)
                return

            if (panelId === "network")
                networkPanel.dismiss()
            else if (panelId === "audio")
                audioPanel.dismiss()
        }
    }

    Connections {
        target: AudioService

        function onPanelToggleRequested(outputName) {
            if (String(outputName || "") !== root.outputName)
                return

            root.toggleAudioPopup(audioItem.width / 2)
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialFast
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialDefault
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    MouseArea {
        id: statusMouse

        z: 0
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            root.focus = false
            root.activate(mouse.x)
        }
    }

    Row {
        id: statusRow

        z: 1
        anchors.centerIn: parent
        spacing: root.individual
            ? root.luminaDesign.spacing.barItemGap
            : root.luminaDesign.spacing.barWidgetPadding

        Behavior on spacing {
            NumberAnimation {
                duration: root.luminaDesign.motion.spatialDefault
                easing.type:
                    root.luminaDesign.motion.spatialEasing
                easing.overshoot:
                    root.luminaDesign.motion.spatialOvershoot
            }
        }

        SystemStatusItem {
            id: networkItem

            visible: root.showNetwork
            individual: root.individual
            interactive: true
            selected: networkPanel.visible
            showLabel: !root.compact
                && root.networkTextMode !== "icon"
            iconName: root.networkIcon
            fallbackSymbol:
                ConnectivityService.networkSummary === "Offline"
                    ? "×"
                    : "◉"
            label: root.networkLabel
            description: "Network "
                + ConnectivityService.networkSummary
            alert: ConnectivityService.networkSummary === "Offline"
            onActivated: localX => root.toggleNetworkPopup(localX)
        }

        SystemStatusItem {
            id: audioItem

            visible: root.showAudio
            individual: root.individual
            interactive: true
            selected: audioPanel.visible
            showLabel: !root.compact
                && root.audioTextMode !== "icon"
            iconName: root.audioIcon
            fallbackSymbol: AudioService.outputMuted ? "×" : "♪"
            label: root.audioLabel
            description: AudioService.outputName
            alert: AudioService.outputAvailable
                && AudioService.outputMuted
            onActivated: localX => root.toggleAudioPopup(localX)
        }

        SystemStatusItem {
            visible: root.showBattery
            individual: root.individual
            showLabel: !root.compact
                && root.batteryTextMode !== "icon"
            expressiveBattery: true
            batteryPercentage: PowerService.batteryPercentage
            batteryCharging: root.batteryCharging
            label: root.batteryLabel
            description: PowerService.batteryState
            alert: BatteryGeometry.isLowBattery(
                PowerService.batteryPercentage,
                root.batteryCharging
            )
        }
    }

    TrayTooltip {
        anchorItem: root
        title: "System status"
        description: root.accessibleSummary
        shown: statusMouse.containsMouse
            && !networkPanel.visible
            && !audioPanel.visible
    }

    NetworkPanel {
        id: networkPanel

        outputName: root.outputName
        panelWindow: root.panelWindow
    }

    AudioPanel {
        id: audioPanel

        outputName: root.outputName
        panelWindow: root.panelWindow
    }
}

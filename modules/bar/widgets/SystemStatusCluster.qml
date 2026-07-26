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
        && AudioService.outputAvailable
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

        if (networkTextMode === "name")
            return ConnectivityService.wifiConnected
                ? ConnectivityService.wifiName
                : ConnectivityService.networkSummary

        if (networkTextMode === "type")
            return ConnectivityService.wifiConnected
                ? "Wi-Fi"
                : ConnectivityService.wiredConnected
                    ? "Wired"
                    : "Offline"

        return ConnectivityService.networkSummary
    }
    readonly property string audioLabel:
        audioTextMode === "icon"
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
        AudioService.outputMuted
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
            ? "Volume "
                + Math.round(AudioService.outputVolume * 100)
                + " percent"
                + (AudioService.outputMuted ? ", muted" : "")
                + ", " + AudioService.outputName
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
    Accessible.onPressAction: root.activate()

    function activate() {
        networkPopup.dismiss()
        ControlCenterStore.openFor(outputName, "dashboard")
    }

    function mappedNetworkAnchorX(localX) {
        const point = networkItem.mapToItem(
            null,
            Number(localX),
            networkItem.height / 2
        )
        return Number(point.x)
    }

    function toggleNetworkPopup(localX) {
        const opening = !networkPopup.requestedVisible
        if (opening)
            OverlayStore.close()
        networkPopup.anchorX = mappedNetworkAnchorX(localX)
        networkPopup.toggle()
    }

    Keys.onSpacePressed: event => {
        activate()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activate()
        event.accepted = true
    }

    Connections {
        target: OverlayStore

        function onActiveSurfaceChanged() {
            if (OverlayStore.activeSurface.length > 0)
                networkPopup.dismiss()
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
        onClicked: {
            root.focus = false
            root.activate()
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
            selected: networkPopup.visible
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
            visible: root.showAudio
            individual: root.individual
            showLabel: !root.compact
                && root.audioTextMode !== "icon"
            iconName: root.audioIcon
            fallbackSymbol: AudioService.outputMuted ? "×" : "♪"
            label: root.audioLabel
            description: AudioService.outputName
            alert: AudioService.outputMuted
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
        shown: statusMouse.containsMouse && !networkPopup.visible
    }

    NetworkPopup {
        id: networkPopup

        anchorItem: networkItem
        panelWindow: root.panelWindow
    }
}

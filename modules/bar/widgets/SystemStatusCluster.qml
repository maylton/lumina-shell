import QtQuick
import qs.design
import qs.services.audio
import qs.services.connectivity
import qs.services.power
import qs.stores.config
import qs.stores.control

Rectangle {
    id: root

    required property string outputName
    property bool compact: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool individual:
        ConfigStore.barStatusLayout === "individual"
    readonly property bool showNetwork:
        ConfigStore.barShowNetworkStatus
    readonly property bool showAudio:
        ConfigStore.barShowAudioStatus
        && AudioService.outputAvailable
    readonly property bool showBattery:
        ConfigStore.barShowBatteryStatus
        && PowerService.batteryAvailable
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
        String(PowerService.batteryState).toLowerCase()
            .indexOf("charging") >= 0
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
            : ConfigStore.barWidgetPillsEnabled
                ? luminaDesign.color.surfaceMuted
                : "transparent"
    scale: statusMouse.pressed
        ? 0.96
        : 1
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
        ControlCenterStore.openFor(outputName, "dashboard")
    }

    Keys.onSpacePressed: event => {
        activate()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activate()
        event.accepted = true
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

    Row {
        id: statusRow

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
            visible: root.showNetwork
            individual: root.individual
            showLabel: !root.compact
                && ConfigStore.barShowNetworkLabel
            iconName: root.networkIcon
            fallbackSymbol:
                ConnectivityService.networkSummary === "Offline"
                    ? "×"
                    : "◉"
            label: ConnectivityService.networkSummary
            description: "Network "
                + ConnectivityService.networkSummary
            alert: ConnectivityService.networkSummary === "Offline"
        }

        SystemStatusItem {
            visible: root.showAudio
            individual: root.individual
            showLabel: !root.compact
                && ConfigStore.barShowAudioLabel
            iconName: root.audioIcon
            fallbackSymbol: AudioService.outputMuted ? "×" : "♪"
            label: AudioService.outputMuted
                ? "Muted"
                : Math.round(AudioService.outputVolume * 100) + "%"
            description: AudioService.outputName
            alert: AudioService.outputMuted
        }

        SystemStatusItem {
            visible: root.showBattery
            individual: root.individual
            showLabel: !root.compact
            iconName: PowerService.batteryIcon.length > 0
                ? PowerService.batteryIcon
                : "battery-symbolic"
            fallbackSymbol: root.batteryCharging ? "⚡" : "▰"
            label: PowerService.batteryPercentage + "%"
            description: PowerService.batteryState
        }
    }

    MouseArea {
        id: statusMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.focus = false
            root.activate()
        }
    }

    TrayTooltip {
        anchorItem: root
        title: "System status"
        description: root.accessibleSummary
        shown: statusMouse.containsMouse
    }
}

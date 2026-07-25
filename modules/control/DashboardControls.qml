pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.audio
import qs.services.brightness
import qs.services.power

DashboardCard {
    id: root

    readonly property var powerProfiles: [
        {
            id: "power-saver",
            label: "Saver"
        },
        {
            id: "balanced",
            label: "Balanced"
        },
        {
            id: "performance",
            label: "Performance"
        }
    ]

    accessibleName: "Daily controls"

    Column {
        anchors {
            fill: parent
            margins: root.luminaDesign.spacing.large
        }

        spacing: root.luminaDesign.spacing.small

        Row {
            width: parent.width
            height: 48

            Text {
                width: parent.width - muteActions.width
                anchors.verticalCenter: parent.verticalCenter
                text: "Daily controls"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleMedium
                font.weight: Font.Bold
            }

            Row {
                id: muteActions

                anchors.verticalCenter: parent.verticalCenter
                spacing: root.luminaDesign.spacing.extraSmall

                DashboardAction {
                    iconName: AudioService.outputMuted
                        ? "audio-volume-muted-symbolic"
                        : "audio-volume-high-symbolic"
                    symbol: AudioService.outputMuted ? "×" : "♪"
                    label: "Toggle output mute"
                    checked: AudioService.outputMuted
                    available: AudioService.outputAvailable
                    onActivated: AudioService.toggleOutputMute()
                }

                DashboardAction {
                    iconName: AudioService.inputMuted
                        ? "microphone-sensitivity-muted-symbolic"
                        : "audio-input-microphone-symbolic"
                    symbol: AudioService.inputMuted ? "×" : "●"
                    label: "Toggle microphone mute"
                    checked: AudioService.inputMuted
                    available: AudioService.inputAvailable
                    onActivated: AudioService.toggleInputMute()
                }
            }
        }

        ControlSlider {
            width: parent.width
            height: 60
            iconName: AudioService.outputMuted
                ? "audio-volume-muted-symbolic"
                : "audio-volume-high-symbolic"
            title: AudioService.outputMuted
                ? "Output muted"
                : "Output volume"
            symbol: AudioService.outputMuted ? "×" : "♪"
            detail: AudioService.outputAvailable
                ? Math.round(AudioService.outputVolume * 100) + "%"
                : "Unavailable"
            value: AudioService.outputVolume
            available: AudioService.outputAvailable
            onValueRequested: value =>
                AudioService.setOutputVolume(value)
        }

        ControlSlider {
            width: parent.width
            height: 60
            iconName: AudioService.inputMuted
                ? "microphone-sensitivity-muted-symbolic"
                : "audio-input-microphone-symbolic"
            title: AudioService.inputMuted
                ? "Microphone muted"
                : "Microphone"
            symbol: AudioService.inputMuted ? "×" : "●"
            detail: AudioService.inputAvailable
                ? Math.round(AudioService.inputVolume * 100) + "%"
                : "Unavailable"
            value: AudioService.inputVolume
            available: AudioService.inputAvailable
            onValueRequested: value =>
                AudioService.setInputVolume(value)
        }

        ControlSlider {
            width: parent.width
            height: 60
            iconName: "display-brightness-symbolic"
            title: "Brightness"
            symbol: "☀"
            detail: BrightnessService.available
                ? BrightnessService.percentage + "%"
                : "No backlight"
            value: BrightnessService.percentage / 100
            available: BrightnessService.available
            onValueRequested: value =>
                BrightnessService.setPercentage(value * 100)
        }

        Row {
            width: parent.width
            height: 26

            Text {
                width: parent.width / 2
                text: "Power profile"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.bodyMedium
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width / 2
                horizontalAlignment: Text.AlignRight
                text: PowerService.batteryAvailable
                    ? PowerService.batteryPercentage + "%"
                    : "AC power"
                color: root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.labelSmall
            }
        }

        Row {
            width: parent.width
            spacing: root.luminaDesign.spacing.small

            Repeater {
                model: root.powerProfiles

                delegate: DashboardAction {
                    required property var modelData

                    width: (parent.width - parent.spacing * 2) / 3
                    wide: true
                    iconName: "power-profile-"
                        + modelData.id
                        + "-symbolic"
                    symbol: modelData.id === "power-saver"
                        ? "◔"
                        : modelData.id === "performance"
                            ? "◆"
                            : "◉"
                    label: modelData.label
                    checked: PowerService.profileName === modelData.id
                    available: modelData.id !== "performance"
                        || PowerService.performanceAvailable
                    onActivated: PowerService.setProfile(modelData.id)
                }
            }
        }
    }
}

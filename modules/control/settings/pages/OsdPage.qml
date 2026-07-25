pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.stores.config

SettingsPage {
    id: root

    title: "OSD"
    description: "On-screen feedback for hardware and session events"

    SettingsSection {
        title: "Presentation"

        SettingsSwitchRow {
            width: parent.width
            title: "Show OSD"
            description: "Master switch for on-screen feedback"
            checked: ConfigStore.osdEnabled
            onToggled: value => ConfigStore.setOsdEnabled(value)
        }

        SettingsComboRow {
            width: parent.width
            title: "Position"
            description: "Vertical placement on the active output"
            available: ConfigStore.osdEnabled
            availabilityText: "Enable OSD first"
            options: [
                { value: "top", label: "Top" },
                { value: "center", label: "Center" },
                { value: "bottom", label: "Bottom" }
            ]
            currentValue: ConfigStore.osdPosition
            onSelected: value =>
                ConfigStore.setOsdValue("osdPosition", value)
        }

        SettingsSliderRow {
            width: parent.width
            title: "Duration"
            description: "Safe range: 0.8–5 seconds"
            available: ConfigStore.osdEnabled
            availabilityText: "Enable OSD first"
            from: 800
            to: 5000
            stepSize: 200
            value: ConfigStore.osdDuration
            valueLabel: (value / 1000).toFixed(1) + " s"
            onValueEdited: value =>
                ConfigStore.setOsdDuration(value)
        }

        SettingsSliderRow {
            width: parent.width
            title: "Size"
            description: "Scale the complete OSD surface"
            available: ConfigStore.osdEnabled
            availabilityText: "Enable OSD first"
            from: 0.8
            to: 1.4
            stepSize: 0.1
            value: ConfigStore.osdSize
            valueLabel: value.toFixed(1) + "×"
            onValueEdited: value =>
                ConfigStore.setOsdValue("osdSize", value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Show percentage"
            description: "Show numeric values beside progress feedback"
            available: ConfigStore.osdEnabled
            availabilityText: "Enable OSD first"
            checked: ConfigStore.osdShowPercentage
            onToggled: value =>
                ConfigStore.setOsdValue(
                    "osdShowPercentage",
                    value
                )
        }
    }

    SettingsSection {
        title: "Events"

        SettingsSwitchRow {
            width: parent.width
            title: "Output volume"
            checked: ConfigStore.osdVolumeEnabled
            onToggled: value =>
                ConfigStore.setOsdValue(
                    "osdVolumeEnabled",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Microphone"
            checked: ConfigStore.osdMicrophoneEnabled
            onToggled: value =>
                ConfigStore.setOsdValue(
                    "osdMicrophoneEnabled",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Brightness"
            checked: ConfigStore.osdBrightnessEnabled
            onToggled: value =>
                ConfigStore.setOsdValue(
                    "osdBrightnessEnabled",
                    value
                )
        }
    }
}

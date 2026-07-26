pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

SettingsPage {
    id: root

    title: I18n.tr("settings.category.osd.label", "OSD")
    description: I18n.tr(
        "settings.page.osd.description",
        "On-screen feedback for hardware and session events"
    )

    SettingsSection {
        title: I18n.tr(
            "settings.osd.presentation.section",
            "Presentation"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr("settings.osd.enabled", "Show OSD")
            description: I18n.tr(
                "settings.osd.enabledDescription",
                "Master switch for on-screen feedback"
            )
            checked: ConfigStore.osdEnabled
            onToggled: value => ConfigStore.setOsdEnabled(value)
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr("settings.osd.position", "Position")
            description: I18n.tr(
                "settings.osd.positionDescription",
                "Vertical placement on the active output"
            )
            available: ConfigStore.osdEnabled
            availabilityText: I18n.tr(
                "settings.osd.enableFirst",
                "Enable OSD first"
            )
            options: [
                {
                    value: "top",
                    label: I18n.tr(
                        "settings.common.position.top",
                        "Top"
                    )
                },
                {
                    value: "center",
                    label: I18n.tr(
                        "settings.common.position.center",
                        "Center"
                    )
                },
                {
                    value: "bottom",
                    label: I18n.tr(
                        "settings.common.position.bottom",
                        "Bottom"
                    )
                }
            ]
            currentValue: ConfigStore.osdPosition
            onSelected: value =>
                ConfigStore.setOsdValue("osdPosition", value)
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr("settings.osd.duration", "Duration")
            description: I18n.tr(
                "settings.osd.durationDescription",
                "Safe range: 0.8–5 seconds"
            )
            available: ConfigStore.osdEnabled
            availabilityText: I18n.tr(
                "settings.osd.enableFirst",
                "Enable OSD first"
            )
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
            title: I18n.tr("settings.osd.size", "Size")
            description: I18n.tr(
                "settings.osd.sizeDescription",
                "Scale the complete OSD surface"
            )
            available: ConfigStore.osdEnabled
            availabilityText: I18n.tr(
                "settings.osd.enableFirst",
                "Enable OSD first"
            )
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
            title: I18n.tr(
                "settings.osd.percentage",
                "Show percentage"
            )
            description: I18n.tr(
                "settings.osd.percentageDescription",
                "Show numeric values beside progress feedback"
            )
            available: ConfigStore.osdEnabled
            availabilityText: I18n.tr(
                "settings.osd.enableFirst",
                "Enable OSD first"
            )
            checked: ConfigStore.osdShowPercentage
            onToggled: value =>
                ConfigStore.setOsdValue(
                    "osdShowPercentage",
                    value
                )
        }
    }

    SettingsSection {
        title: I18n.tr("settings.osd.events.section", "Events")

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.osd.events.volume",
                "Output volume"
            )
            checked: ConfigStore.osdVolumeEnabled
            onToggled: value =>
                ConfigStore.setOsdValue(
                    "osdVolumeEnabled",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.osd.events.microphone",
                "Microphone"
            )
            checked: ConfigStore.osdMicrophoneEnabled
            onToggled: value =>
                ConfigStore.setOsdValue(
                    "osdMicrophoneEnabled",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.osd.events.brightness",
                "Brightness"
            )
            checked: ConfigStore.osdBrightnessEnabled
            onToggled: value =>
                ConfigStore.setOsdValue(
                    "osdBrightnessEnabled",
                    value
                )
        }
    }
}

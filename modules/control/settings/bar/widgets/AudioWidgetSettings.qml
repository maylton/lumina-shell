import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0

    SettingsSection {
        title: I18n.tr(
            "settings.widget.status.audioSection",
            "Audio"
        )
        description: I18n.tr(
            "settings.widget.status.audioDescription",
            "Choose the visible audio status and text"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.common.background",
                "Background"
            )
            description: I18n.tr(
                "settings.widget.common.backgroundResting",
                "Show a resting tonal surface"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "audio", "showBackground", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "audio", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.status.audioText",
                "Audio text"
            )
            description: I18n.tr(
                "settings.widget.status.audioTextDescription",
                "Show a percentage, state, or icon only"
            )
            options: [
                {
                    value: "icon",
                    label: I18n.tr(
                        "settings.widget.status.iconOnly",
                        "Icon only"
                    )
                },
                {
                    value: "percentage",
                    label: I18n.tr(
                        "settings.widget.status.percentage",
                        "Percentage"
                    )
                },
                {
                    value: "state",
                    label: I18n.tr(
                        "settings.widget.status.state",
                        "State"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "audio", "textMode", "percentage"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "audio", "textMode", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.common.openPosition",
                "Open position"
            )
            description: I18n.tr(
                "settings.widget.common.openPositionDescription",
                "Open beside the widget or centered on the screen"
            )
            options: [
                {
                    value: "near-widget",
                    label: I18n.tr(
                        "settings.widget.common.nearWidget",
                        "Near the widget"
                    )
                },
                {
                    value: "centered",
                    label: I18n.tr(
                        "settings.widget.common.centered",
                        "Centered"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "audio", "surfacePlacement", "near-widget"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "audio", "surfacePlacement", value
            )
        }
    }
}

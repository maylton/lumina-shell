import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: I18n.tr(
            "settings.widget.common.presentation",
            "Presentation"
        )
        description: I18n.tr(
            "settings.widget.wallpaper.description",
            "Wallpaper action on the bar"
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
                "wallpaper", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "wallpaper", "showBackground", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.common.label",
                "Label"
            )
            description: I18n.tr(
                "settings.widget.wallpaper.labelDescription",
                "Show Wallpaper beside the icon"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "wallpaper", "showLabel", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "wallpaper", "showLabel", value
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
                "wallpaper", "surfacePlacement", "centered"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "wallpaper", "surfacePlacement", value
            )
        }
    }
}

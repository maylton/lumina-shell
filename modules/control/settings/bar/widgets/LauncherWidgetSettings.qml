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
            "settings.widget.launcher.description",
            "Launcher appearance on the bar"
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
                "launcher", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "launcher", "showBackground", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.common.label",
                "Label"
            )
            description: I18n.tr(
                "settings.widget.launcher.labelDescription",
                "Show Apps beside the launcher icon"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "launcher", "showLabel", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "launcher", "showLabel", value
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
                "launcher", "surfacePlacement", "centered"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "launcher", "surfacePlacement", value
            )
        }
    }
}

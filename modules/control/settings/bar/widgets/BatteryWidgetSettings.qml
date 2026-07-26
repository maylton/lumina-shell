import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0

    SettingsSection {
        title: I18n.tr(
            "settings.bar.systemStatus.battery.title",
            "Battery"
        )
        description: I18n.tr(
            "settings.bar.systemStatus.battery.description",
            "Android-inspired level icon with optional text beside it"
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
                "battery", "showBackground", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "battery", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.systemStatus.battery.text",
                "Text beside icon"
            )
            description: I18n.tr(
                "settings.bar.systemStatus.battery.textDescription",
                "The battery shape never contains text"
            )
            options: [
                {
                    value: "icon",
                    label: I18n.tr(
                        "settings.bar.systemStatus.battery.iconOnly",
                        "Icon only"
                    )
                },
                {
                    value: "percentage",
                    label: I18n.tr(
                        "settings.bar.systemStatus.battery.percentage",
                        "Percentage beside icon"
                    )
                },
                {
                    value: "state",
                    label: I18n.tr(
                        "settings.bar.systemStatus.battery.state",
                        "State beside icon"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "battery", "textMode", "percentage"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "battery", "textMode", value
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
                "battery", "surfacePlacement", "near-widget"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "battery", "surfacePlacement", value
            )
        }
    }
}

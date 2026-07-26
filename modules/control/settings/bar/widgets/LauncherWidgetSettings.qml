import QtQuick
import qs.modules.control.settings
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: "Presentation"
        description: "Launcher appearance on the bar"

        SettingsSwitchRow {
            width: parent.width
            title: "Background"
            description: "Show a resting tonal surface"
            checked: Boolean(ConfigStore.widgetSetting(
                "launcher", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "launcher", "showBackground", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Label"
            description: "Show Apps beside the launcher icon"
            checked: Boolean(ConfigStore.widgetSetting(
                "launcher", "showLabel", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "launcher", "showLabel", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Open position"
            description: "Open beside the widget or centered on the screen"
            options: [
                { value: "near-widget", label: "Near the widget" },
                { value: "centered", label: "Centered" }
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

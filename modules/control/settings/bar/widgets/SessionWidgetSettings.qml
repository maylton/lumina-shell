import QtQuick
import qs.modules.control.settings
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: "Presentation"
        description: "Session action on the bar"

        SettingsSwitchRow {
            width: parent.width
            title: "Background"
            description: "Show a resting tonal surface"
            checked: Boolean(ConfigStore.widgetSetting(
                "session", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "session", "showBackground", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Label"
            description: "Show Session beside the icon"
            checked: Boolean(ConfigStore.widgetSetting(
                "session", "showLabel", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "session", "showLabel", value
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
                "session", "surfacePlacement", "centered"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "session", "surfacePlacement", value
            )
        }
    }
}

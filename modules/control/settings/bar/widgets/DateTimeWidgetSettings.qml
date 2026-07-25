import QtQuick
import qs.modules.control.settings
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: "Clock and date"
        description: "Localized date and time presentation"

        SettingsSwitchRow {
            width: parent.width
            title: "Background"
            description: "Show a resting tonal surface"
            checked: Boolean(ConfigStore.widgetSetting(
                "datetime", "showBackground", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "datetime", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Layout"
            description: "Place date inline or below the clock"
            options: [
                { value: "inline", label: "Inline" },
                { value: "stacked", label: "Stacked" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "datetime", "clockLayout", "inline"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "datetime", "clockLayout", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Hour format"
            description: "Use the system, 12-hour, or 24-hour format"
            options: [
                { value: "system", label: "System" },
                { value: "12", label: "12-hour" },
                { value: "24", label: "24-hour" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "datetime", "hourFormat", "24"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "datetime", "hourFormat", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Seconds"
            description: "Refresh and show seconds"
            checked: Boolean(ConfigStore.widgetSetting(
                "datetime", "showSeconds", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "datetime", "showSeconds", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Date"
            description: "Choose the localized date detail"
            options: [
                { value: "hidden", label: "Hidden" },
                { value: "short", label: "Short" },
                { value: "weekday", label: "Weekday" },
                { value: "full", label: "Full" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "datetime", "dateMode", "short"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "datetime", "dateMode", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Separator"
            description: "Separate the clock and date when inline"
            available: String(ConfigStore.widgetSetting(
                "datetime", "clockLayout", "inline"
            )) === "inline"
            checked: Boolean(ConfigStore.widgetSetting(
                "datetime", "showSeparator", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "datetime", "showSeparator", value
            )
        }
    }
}

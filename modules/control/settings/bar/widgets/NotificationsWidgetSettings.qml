import QtQuick
import qs.modules.control.settings
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: "Notification state"
        description: "Information shown by the bar button"

        SettingsSwitchRow {
            width: parent.width
            title: "Background"
            description: "Show a resting tonal surface"
            checked: Boolean(ConfigStore.widgetSetting(
                "notifications", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "notifications", "showBackground", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Unread badge"
            description: "Show the unread notification count"
            checked: Boolean(ConfigStore.widgetSetting(
                "notifications", "showUnreadBadge", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "notifications", "showUnreadBadge", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Do Not Disturb state"
            description: "Show when interruptions are muted"
            checked: Boolean(ConfigStore.widgetSetting(
                "notifications", "showDoNotDisturbState", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "notifications", "showDoNotDisturbState", value
            )
        }
    }
}

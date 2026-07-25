import QtQuick
import qs.modules.control.settings
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: "Personal entry point"
        description: "Dashboard button identity"

        SettingsSwitchRow {
            width: parent.width
            title: "Background"
            description: "Show a resting tonal surface"
            checked: Boolean(ConfigStore.widgetSetting(
                "dashboard", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "dashboard", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Avatar"
            description: "Choose image priority or account initials"
            options: [
                { value: "automatic", label: "Automatic" },
                { value: "image", label: "Image" },
                { value: "initials", label: "Initials" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "dashboard", "avatarDisplay", "image"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "dashboard", "avatarDisplay", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "User name"
            description: "Show the detected account name"
            checked: Boolean(ConfigStore.widgetSetting(
                "dashboard", "showUserName", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "dashboard", "showUserName", value
            )
        }
    }
}

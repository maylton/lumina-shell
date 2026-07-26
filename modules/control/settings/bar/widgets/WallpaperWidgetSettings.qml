import QtQuick
import qs.modules.control.settings
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: "Presentation"
        description: "Wallpaper action on the bar"

        SettingsSwitchRow {
            width: parent.width
            title: "Background"
            description: "Show a resting tonal surface"
            checked: Boolean(ConfigStore.widgetSetting(
                "wallpaper", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "wallpaper", "showBackground", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Label"
            description: "Show Wallpaper beside the icon"
            checked: Boolean(ConfigStore.widgetSetting(
                "wallpaper", "showLabel", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "wallpaper", "showLabel", value
            )
        }
    }
}

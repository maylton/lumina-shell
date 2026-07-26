import QtQuick
import qs.modules.control.settings
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: "Presentation"
        description: "Overview appearance on the bar"

        SettingsSwitchRow {
            width: parent.width
            title: "Background"
            description: "Show a resting tonal surface"
            checked: Boolean(ConfigStore.widgetSetting(
                "overview", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "overview", "showBackground", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Label"
            description: "Show Overview beside the icon"
            checked: Boolean(ConfigStore.widgetSetting(
                "overview", "showLabel", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "overview", "showLabel", value
            )
        }
    }
}

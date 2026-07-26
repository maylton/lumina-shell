import QtQuick
import qs.modules.control.settings
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: "System tray"
        description: "StatusNotifier presentation"

        SettingsSwitchRow {
            width: parent.width
            title: "Background"
            description: "Show tonal surfaces behind tray controls"
            checked: Boolean(ConfigStore.widgetSetting(
                "tray", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "tray", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Tray icons"
            description: "Group items in a menu or show them inline"
            options: [
                { value: "grouped", label: "Grouped" },
                { value: "inline", label: "Always visible" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "tray", "mode", "grouped"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "tray", "mode", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Item count"
            description: "Show the number of active tray items"
            available: String(ConfigStore.widgetSetting(
                "tray", "mode", "grouped"
            )) === "grouped"
            checked: Boolean(ConfigStore.widgetSetting(
                "tray", "showCount", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "tray", "showCount", value
            )
        }
    }
}

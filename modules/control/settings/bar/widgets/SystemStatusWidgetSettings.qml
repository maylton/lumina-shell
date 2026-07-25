import QtQuick
import qs.modules.control.settings
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: "Status layout"
        description: "Group available native service information"

        SettingsSwitchRow {
            width: parent.width
            title: "Background"
            description: "Show tonal surfaces behind status items"
            checked: Boolean(ConfigStore.widgetSetting(
                "system-status", "showBackground", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "system-status", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Layout"
            description: "Use one cluster or individual status items"
            options: [
                { value: "grouped", label: "Grouped" },
                { value: "individual", label: "Individual" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "system-status", "layout", "grouped"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "system-status", "layout", value
            )
        }
    }

    SettingsSection {
        title: "Network"
        description: "Only real connectivity data is displayed"

        SettingsSwitchRow {
            width: parent.width
            title: "Show network"
            description: "Keep the network status icon"
            checked: Boolean(ConfigStore.widgetSetting(
                "system-status", "showNetwork", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "system-status", "showNetwork", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Network text"
            description: "Choose the real connection detail"
            available: Boolean(ConfigStore.widgetSetting(
                "system-status", "showNetwork", true
            ))
            options: [
                { value: "icon", label: "Icon only" },
                { value: "summary", label: "Summary" },
                { value: "name", label: "Connection name" },
                { value: "type", label: "Connection type" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "system-status", "networkTextMode", "summary"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "system-status", "networkTextMode", value
            )
        }
    }

    SettingsSection {
        title: "Audio and battery"
        description: "Choose the visible status and text"

        SettingsSwitchRow {
            width: parent.width
            title: "Show audio"
            description: "Show audio when an output is available"
            checked: Boolean(ConfigStore.widgetSetting(
                "system-status", "showAudio", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "system-status", "showAudio", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Audio text"
            description: "Show a percentage, state, or icon only"
            available: Boolean(ConfigStore.widgetSetting(
                "system-status", "showAudio", true
            ))
            options: [
                { value: "icon", label: "Icon only" },
                { value: "percentage", label: "Percentage" },
                { value: "state", label: "State" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "system-status", "audioTextMode", "percentage"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "system-status", "audioTextMode", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Show battery"
            description: "Show battery only when hardware is available"
            checked: Boolean(ConfigStore.widgetSetting(
                "system-status", "showBattery", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "system-status", "showBattery", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Battery text"
            description: "Show a percentage, state, or icon only"
            available: Boolean(ConfigStore.widgetSetting(
                "system-status", "showBattery", true
            ))
            options: [
                { value: "icon", label: "Icon only" },
                { value: "percentage", label: "Percentage" },
                { value: "state", label: "State" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "system-status", "batteryTextMode", "percentage"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "system-status", "batteryTextMode", value
            )
        }
    }
}

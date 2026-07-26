import QtQuick
import qs.modules.control.settings
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: "Window context"
        description: "Focused Niri context in the center"

        SettingsSwitchRow {
            width: parent.width
            title: "Background"
            description: "Show a resting tonal surface"
            checked: Boolean(ConfigStore.widgetSetting(
                "context", "showBackground", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "context", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Visibility"
            description: "Choose when context remains visible"
            options: [
                { value: "always", label: "Always" },
                { value: "contextual", label: "Contextual" },
                { value: "hidden", label: "Hidden" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "context", "mode", "contextual"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "context", "mode", value
            )
        }

        SettingsSliderRow {
            width: parent.width
            title: "Context duration"
            description: "Time before contextual information recedes"
            available: String(ConfigStore.widgetSetting(
                "context", "mode", "contextual"
            )) === "contextual"
            from: 1000
            to: 15000
            stepSize: 500
            value: Number(ConfigStore.widgetSetting(
                "context", "timeout", 3500
            ))
            valueLabel: (value / 1000).toFixed(1) + " s"
            onValueEdited: value => ConfigStore.setBarWidgetSetting(
                "context", "timeout", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Window title"
            description: "Include the focused window title"
            checked: Boolean(ConfigStore.widgetSetting(
                "context", "showWindowTitle", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "context", "showWindowTitle", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Workspace"
            description: "Include the current workspace"
            checked: Boolean(ConfigStore.widgetSetting(
                "context", "showWorkspace", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "context", "showWorkspace", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Application ID"
            description: "Include the focused application ID"
            checked: Boolean(ConfigStore.widgetSetting(
                "context", "showApplicationId", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "context", "showApplicationId", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Column and tile"
            description: "Include the focused Niri column or tile"
            checked: Boolean(ConfigStore.widgetSetting(
                "context", "showColumn", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "context", "showColumn", value
            )
        }
    }
}

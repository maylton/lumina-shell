import QtQuick
import qs.modules.control.settings
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: "Workspace presentation"
        description: "Focused and inactive workspace treatment"

        SettingsSwitchRow {
            width: parent.width
            title: "Group background"
            description: "Place a tonal surface behind the strip"
            checked: Boolean(ConfigStore.widgetSetting(
                "workspaces", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "workspaces", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Labels"
            description: "Choose which workspaces show their name"
            options: [
                { value: "active", label: "Active only" },
                { value: "all", label: "All" },
                { value: "none", label: "None" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "workspaces", "labelMode", "active"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "workspaces", "labelMode", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Inactive workspaces"
            description: "Represent inactive workspaces as dots or numbers"
            options: [
                { value: "dot", label: "Dot" },
                { value: "number", label: "Number" }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "workspaces", "inactiveStyle", "dot"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "workspaces", "inactiveStyle", value
            )
        }
    }
}

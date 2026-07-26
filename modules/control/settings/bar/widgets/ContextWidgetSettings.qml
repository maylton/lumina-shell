import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: I18n.tr("settings.widget.context.section", "Window context")
        description: I18n.tr(
            "settings.widget.context.description",
            "Focused Niri context in the center"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr("settings.widget.common.background", "Background")
            description: I18n.tr(
                "settings.widget.common.backgroundResting",
                "Show a resting tonal surface"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "context", "showBackground", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "context", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr("settings.widget.context.visibility", "Visibility")
            description: I18n.tr(
                "settings.widget.context.visibilityDescription",
                "Choose when context remains visible"
            )
            options: [
                { value: "always", label: I18n.tr("settings.widget.context.always", "Always") },
                { value: "contextual", label: I18n.tr("settings.widget.context.contextual", "Contextual") },
                { value: "hidden", label: I18n.tr("settings.widget.context.hidden", "Hidden") }
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
            title: I18n.tr("settings.widget.context.duration", "Context duration")
            description: I18n.tr(
                "settings.widget.context.durationDescription",
                "Time before contextual information recedes"
            )
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
            title: I18n.tr("settings.widget.context.windowTitle", "Window title")
            description: I18n.tr(
                "settings.widget.context.windowTitleDescription",
                "Include the focused window title"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "context", "showWindowTitle", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "context", "showWindowTitle", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr("settings.widget.context.workspace", "Workspace")
            description: I18n.tr(
                "settings.widget.context.workspaceDescription",
                "Include the current workspace"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "context", "showWorkspace", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "context", "showWorkspace", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr("settings.widget.context.applicationId", "Application ID")
            description: I18n.tr(
                "settings.widget.context.applicationIdDescription",
                "Include the focused application ID"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "context", "showApplicationId", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "context", "showApplicationId", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr("settings.widget.context.column", "Column and tile")
            description: I18n.tr(
                "settings.widget.context.columnDescription",
                "Include the focused Niri column or tile"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "context", "showColumn", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "context", "showColumn", value
            )
        }
    }
}

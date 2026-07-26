import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: I18n.tr(
            "settings.widget.workspaces.section",
            "Workspace presentation"
        )
        description: I18n.tr(
            "settings.widget.workspaces.description",
            "Focused and inactive workspace treatment"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.workspaces.background",
                "Group background"
            )
            description: I18n.tr(
                "settings.widget.workspaces.backgroundDescription",
                "Place a tonal surface behind the strip"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "workspaces", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "workspaces", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.workspaces.labels",
                "Labels"
            )
            description: I18n.tr(
                "settings.widget.workspaces.labelsDescription",
                "Choose which workspaces show their name"
            )
            options: [
                {
                    value: "active",
                    label: I18n.tr(
                        "settings.widget.workspaces.activeOnly",
                        "Active only"
                    )
                },
                {
                    value: "all",
                    label: I18n.tr(
                        "settings.widget.workspaces.all",
                        "All"
                    )
                },
                {
                    value: "none",
                    label: I18n.tr(
                        "settings.widget.workspaces.none",
                        "None"
                    )
                }
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
            title: I18n.tr(
                "settings.widget.workspaces.inactive",
                "Inactive workspaces"
            )
            description: I18n.tr(
                "settings.widget.workspaces.inactiveDescription",
                "Represent inactive workspaces as dots or numbers"
            )
            options: [
                {
                    value: "dot",
                    label: I18n.tr(
                        "settings.widget.workspaces.dot",
                        "Dot"
                    )
                },
                {
                    value: "number",
                    label: I18n.tr(
                        "settings.widget.workspaces.number",
                        "Number"
                    )
                }
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

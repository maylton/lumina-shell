import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: I18n.tr("settings.widget.status.section", "Status layout")
        description: I18n.tr(
            "settings.widget.status.description",
            "Group available native service information"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr("settings.widget.common.background", "Background")
            description: I18n.tr(
                "settings.widget.status.backgroundDescription",
                "Show tonal surfaces behind status items"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "system-status", "showBackground", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "system-status", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr("settings.widget.status.layout", "Layout")
            description: I18n.tr(
                "settings.widget.status.layoutDescription",
                "Use one cluster or individual status items"
            )
            options: [
                {
                    value: "grouped",
                    label: I18n.tr(
                        "settings.widget.status.grouped",
                        "Grouped"
                    )
                },
                {
                    value: "individual",
                    label: I18n.tr(
                        "settings.widget.status.individual",
                        "Individual"
                    )
                }
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
        title: I18n.tr("settings.widget.status.networkSection", "Network")
        description: I18n.tr(
            "settings.widget.status.networkDescription",
            "Only real connectivity data is displayed"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.status.showNetwork",
                "Show network"
            )
            description: I18n.tr(
                "settings.widget.status.showNetworkDescription",
                "Keep the network status icon"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "system-status", "showNetwork", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "system-status", "showNetwork", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.status.networkText",
                "Network text"
            )
            description: I18n.tr(
                "settings.widget.status.networkTextDescription",
                "Choose the real connection detail"
            )
            available: Boolean(ConfigStore.widgetSetting(
                "system-status", "showNetwork", true
            ))
            options: [
                { value: "icon", label: I18n.tr("settings.widget.status.iconOnly", "Icon only") },
                { value: "summary", label: I18n.tr("settings.widget.status.summary", "Summary") },
                { value: "name", label: I18n.tr("settings.widget.status.connectionName", "Connection name") },
                { value: "type", label: I18n.tr("settings.widget.status.connectionType", "Connection type") }
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
        title: I18n.tr("settings.widget.status.audioSection", "Audio")
        description: I18n.tr(
            "settings.widget.status.audioDescription",
            "Choose the visible audio status and text"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr("settings.widget.status.showAudio", "Show audio")
            description: I18n.tr(
                "settings.widget.status.showAudioDescription",
                "Show audio when an output is available"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "system-status", "showAudio", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "system-status", "showAudio", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr("settings.widget.status.audioText", "Audio text")
            description: I18n.tr(
                "settings.widget.status.audioTextDescription",
                "Show a percentage, state, or icon only"
            )
            available: Boolean(ConfigStore.widgetSetting(
                "system-status", "showAudio", true
            ))
            options: [
                { value: "icon", label: I18n.tr("settings.widget.status.iconOnly", "Icon only") },
                { value: "percentage", label: I18n.tr("settings.widget.status.percentage", "Percentage") },
                { value: "state", label: I18n.tr("settings.widget.status.state", "State") }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "system-status", "audioTextMode", "percentage"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "system-status", "audioTextMode", value
            )
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.bar.systemStatus.battery.title",
            "Battery"
        )
        description: I18n.tr(
            "settings.bar.systemStatus.battery.description",
            "Android-inspired level icon with optional text beside it"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.systemStatus.battery.show",
                "Show battery"
            )
            description: I18n.tr(
                "settings.bar.systemStatus.battery.showDescription",
                "Show the battery only when hardware is available"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "system-status", "showBattery", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "system-status", "showBattery", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.systemStatus.battery.text",
                "Text beside icon"
            )
            description: I18n.tr(
                "settings.bar.systemStatus.battery.textDescription",
                "The battery shape never contains text"
            )
            available: Boolean(ConfigStore.widgetSetting(
                "system-status", "showBattery", true
            ))
            options: [
                {
                    value: "icon",
                    label: I18n.tr(
                        "settings.bar.systemStatus.battery.iconOnly",
                        "Icon only"
                    )
                },
                {
                    value: "percentage",
                    label: I18n.tr(
                        "settings.bar.systemStatus.battery.percentage",
                        "Percentage beside icon"
                    )
                },
                {
                    value: "state",
                    label: I18n.tr(
                        "settings.bar.systemStatus.battery.state",
                        "State beside icon"
                    )
                }
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

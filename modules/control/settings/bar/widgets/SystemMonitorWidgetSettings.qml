import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0

    SettingsSection {
        title: I18n.tr(
            "settings.widget.systemMonitor.section",
            "System monitor"
        )
        description: I18n.tr(
            "settings.widget.systemMonitor.description",
            "Choose how live hardware information is displayed"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.common.background",
                "Background"
            )
            description: I18n.tr(
                "settings.widget.common.backgroundResting",
                "Show a resting tonal surface"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "system-monitor",
                "showBackground",
                true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "system-monitor",
                "showBackground",
                value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.systemMonitor.text",
                "Bar content"
            )
            description: I18n.tr(
                "settings.widget.systemMonitor.textDescription",
                "Show processor usage or only the monitor icon"
            )
            options: [
                {
                    value: "icon",
                    label: I18n.tr(
                        "settings.widget.status.iconOnly",
                        "Icon only"
                    )
                },
                {
                    value: "percentage",
                    label: I18n.tr(
                        "settings.widget.status.percentage",
                        "Percentage"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "system-monitor",
                "textMode",
                "percentage"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "system-monitor",
                "textMode",
                value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.systemMonitor.refreshInterval",
                "Refresh interval"
            )
            description: I18n.tr(
                "settings.widget.systemMonitor.refreshIntervalDescription",
                "How often hardware and network data is sampled"
            )
            options: [
                {
                    value: "1000",
                    label: I18n.tr(
                        "settings.widget.systemMonitor.oneSecond",
                        "Every second"
                    )
                },
                {
                    value: "2000",
                    label: I18n.tr(
                        "settings.widget.systemMonitor.twoSeconds",
                        "Every 2 seconds"
                    )
                },
                {
                    value: "5000",
                    label: I18n.tr(
                        "settings.widget.systemMonitor.fiveSeconds",
                        "Every 5 seconds"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "system-monitor",
                "refreshInterval",
                "2000"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "system-monitor",
                "refreshInterval",
                value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.common.openPosition",
                "Open position"
            )
            description: I18n.tr(
                "settings.widget.common.openPositionDescription",
                "Open beside the widget or centered on the screen"
            )
            options: [
                {
                    value: "near-widget",
                    label: I18n.tr(
                        "settings.widget.common.nearWidget",
                        "Near the widget"
                    )
                },
                {
                    value: "centered",
                    label: I18n.tr(
                        "settings.widget.common.centered",
                        "Centered"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "system-monitor",
                "surfacePlacement",
                "near-widget"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "system-monitor",
                "surfacePlacement",
                value
            )
        }
    }
}

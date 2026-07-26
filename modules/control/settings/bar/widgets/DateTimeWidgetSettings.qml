import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: I18n.tr(
            "settings.widget.datetime.section",
            "Clock and date"
        )
        description: I18n.tr(
            "settings.widget.datetime.description",
            "Localized date and time presentation"
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
                "datetime", "showBackground", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "datetime", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.datetime.layout",
                "Layout"
            )
            description: I18n.tr(
                "settings.widget.datetime.layoutDescription",
                "Place date inline or below the clock"
            )
            options: [
                {
                    value: "inline",
                    label: I18n.tr(
                        "settings.widget.datetime.inline",
                        "Inline"
                    )
                },
                {
                    value: "stacked",
                    label: I18n.tr(
                        "settings.widget.datetime.stacked",
                        "Stacked"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "datetime", "clockLayout", "inline"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "datetime", "clockLayout", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.datetime.hourFormat",
                "Hour format"
            )
            description: I18n.tr(
                "settings.widget.datetime.hourFormatDescription",
                "Use the system, 12-hour, or 24-hour format"
            )
            options: [
                {
                    value: "system",
                    label: I18n.tr(
                        "settings.widget.datetime.system",
                        "System"
                    )
                },
                {
                    value: "12",
                    label: I18n.tr(
                        "settings.widget.datetime.12hour",
                        "12-hour"
                    )
                },
                {
                    value: "24",
                    label: I18n.tr(
                        "settings.widget.datetime.24hour",
                        "24-hour"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "datetime", "hourFormat", "24"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "datetime", "hourFormat", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.datetime.seconds",
                "Seconds"
            )
            description: I18n.tr(
                "settings.widget.datetime.secondsDescription",
                "Refresh and show seconds"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "datetime", "showSeconds", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "datetime", "showSeconds", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.datetime.date",
                "Date"
            )
            description: I18n.tr(
                "settings.widget.datetime.dateDescription",
                "Choose the localized date detail"
            )
            options: [
                {
                    value: "hidden",
                    label: I18n.tr(
                        "settings.widget.datetime.hidden",
                        "Hidden"
                    )
                },
                {
                    value: "short",
                    label: I18n.tr(
                        "settings.widget.datetime.short",
                        "Short"
                    )
                },
                {
                    value: "weekday",
                    label: I18n.tr(
                        "settings.widget.datetime.weekday",
                        "Weekday"
                    )
                },
                {
                    value: "full",
                    label: I18n.tr(
                        "settings.widget.datetime.full",
                        "Full"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "datetime", "dateMode", "short"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "datetime", "dateMode", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.datetime.separator",
                "Separator"
            )
            description: I18n.tr(
                "settings.widget.datetime.separatorDescription",
                "Separate the clock and date when inline"
            )
            available: String(ConfigStore.widgetSetting(
                "datetime", "clockLayout", "inline"
            )) === "inline"
            checked: Boolean(ConfigStore.widgetSetting(
                "datetime", "showSeparator", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "datetime", "showSeparator", value
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
                "datetime", "surfacePlacement", "near-widget"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "datetime", "surfacePlacement", value
            )
        }
    }
}

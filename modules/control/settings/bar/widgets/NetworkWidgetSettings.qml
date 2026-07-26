import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0

    SettingsSection {
        title: I18n.tr(
            "settings.widget.status.networkSection",
            "Network"
        )
        description: I18n.tr(
            "settings.widget.status.networkDescription",
            "Only real connectivity data is displayed"
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
                "network", "showBackground", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "network", "showBackground", value
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
            options: [
                {
                    value: "icon",
                    label: I18n.tr(
                        "settings.widget.status.iconOnly",
                        "Icon only"
                    )
                },
                {
                    value: "summary",
                    label: I18n.tr(
                        "settings.widget.status.summary",
                        "Summary"
                    )
                },
                {
                    value: "name",
                    label: I18n.tr(
                        "settings.widget.status.connectionName",
                        "Connection name"
                    )
                },
                {
                    value: "type",
                    label: I18n.tr(
                        "settings.widget.status.connectionType",
                        "Connection type"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "network", "textMode", "summary"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "network", "textMode", value
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
                "network", "surfacePlacement", "near-widget"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "network", "surfacePlacement", value
            )
        }
    }
}

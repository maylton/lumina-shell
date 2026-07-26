import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: I18n.tr(
            "settings.widget.common.presentation",
            "Presentation"
        )
        description: I18n.tr(
            "settings.widget.session.description",
            "Session action on the bar"
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
                "session", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "session", "showBackground", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.common.label",
                "Label"
            )
            description: I18n.tr(
                "settings.widget.session.labelDescription",
                "Show Session beside the icon"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "session", "showLabel", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "session", "showLabel", value
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
                "session", "surfacePlacement", "centered"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "session", "surfacePlacement", value
            )
        }
    }
}

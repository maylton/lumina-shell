import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0

    SettingsSection {
        title: I18n.tr(
            "settings.widget.bluetooth.section",
            "Bluetooth"
        )
        description: I18n.tr(
            "settings.widget.bluetooth.description",
            "Bluetooth button and device panel"
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
                "bluetooth", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "bluetooth", "showBackground", value
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
                "bluetooth",
                "surfacePlacement",
                "near-widget"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "bluetooth", "surfacePlacement", value
            )
        }
    }
}

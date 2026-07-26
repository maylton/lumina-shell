import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: I18n.tr("settings.widget.tray.section", "System tray")
        description: I18n.tr(
            "settings.widget.tray.description",
            "StatusNotifier presentation"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr("settings.widget.common.background", "Background")
            description: I18n.tr(
                "settings.widget.tray.backgroundDescription",
                "Show tonal surfaces behind tray controls"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "tray", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "tray", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr("settings.widget.tray.icons", "Tray icons")
            description: I18n.tr(
                "settings.widget.tray.iconsDescription",
                "Group items in a menu or show them inline"
            )
            options: [
                {
                    value: "grouped",
                    label: I18n.tr(
                        "settings.widget.tray.grouped",
                        "Grouped"
                    )
                },
                {
                    value: "inline",
                    label: I18n.tr(
                        "settings.widget.tray.alwaysVisible",
                        "Always visible"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "tray", "mode", "grouped"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "tray", "mode", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr("settings.widget.tray.count", "Item count")
            description: I18n.tr(
                "settings.widget.tray.countDescription",
                "Show the number of active tray items"
            )
            available: String(ConfigStore.widgetSetting(
                "tray", "mode", "grouped"
            )) === "grouped"
            checked: Boolean(ConfigStore.widgetSetting(
                "tray", "showCount", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "tray", "showCount", value
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
                "tray", "surfacePlacement", "near-widget"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "tray", "surfacePlacement", value
            )
        }
    }
}

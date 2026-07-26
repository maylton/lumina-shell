import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: I18n.tr(
            "settings.widget.notifications.section",
            "Notification state"
        )
        description: I18n.tr(
            "settings.widget.notifications.description",
            "Information shown by the bar button"
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
                "notifications", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "notifications", "showBackground", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.notifications.unreadBadge",
                "Unread badge"
            )
            description: I18n.tr(
                "settings.widget.notifications.unreadBadgeDescription",
                "Show the unread notification count"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "notifications", "showUnreadBadge", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "notifications", "showUnreadBadge", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.notifications.dndState",
                "Do Not Disturb state"
            )
            description: I18n.tr(
                "settings.widget.notifications.dndStateDescription",
                "Show when interruptions are muted"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "notifications", "showDoNotDisturbState", true
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "notifications", "showDoNotDisturbState", value
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
                "notifications", "surfacePlacement", "near-widget"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "notifications", "surfacePlacement", value
            )
        }
    }
}

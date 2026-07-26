pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.services.notifications
import qs.stores.config

SettingsPage {
    id: root

    title: I18n.tr(
        "settings.category.notifications.label",
        "Notifications"
    )
    description: I18n.tr(
        "settings.page.notifications.description",
        "Popup placement, timing, history, and interruptions"
    )

    SettingsSection {
        title: I18n.tr(
            "settings.notifications.interruptions.section",
            "Interruptions"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.notifications.dnd.title",
                "Do Not Disturb"
            )
            description: checked
                ? I18n.tr(
                    "settings.notifications.dnd.enabled",
                    "Popups are paused; history remains available"
                )
                : I18n.tr(
                    "settings.notifications.dnd.disabled",
                    "New notifications may appear as popups"
                )
            checked: ConfigStore.doNotDisturb
            onToggled: value =>
                NotificationService.setDoNotDisturb(value)
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.notifications.popups.section",
            "Popups"
        )

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.notifications.popups.position",
                "Position"
            )
            description: I18n.tr(
                "settings.notifications.popups.positionDescription",
                "Screen corner used for notification popups"
            )
            options: [
                {
                    value: "top-left",
                    label: I18n.tr(
                        "settings.notifications.position.topLeft",
                        "Top left"
                    )
                },
                {
                    value: "top-right",
                    label: I18n.tr(
                        "settings.notifications.position.topRight",
                        "Top right"
                    )
                },
                {
                    value: "bottom-left",
                    label: I18n.tr(
                        "settings.notifications.position.bottomLeft",
                        "Bottom left"
                    )
                },
                {
                    value: "bottom-right",
                    label: I18n.tr(
                        "settings.notifications.position.bottomRight",
                        "Bottom right"
                    )
                }
            ]
            currentValue: ConfigStore.notificationPopupPosition
            onSelected: value =>
                ConfigStore.setNotificationValue(
                    "notificationPopupPosition",
                    value
                )
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr(
                "settings.notifications.popups.duration",
                "Default duration"
            )
            description: I18n.tr(
                "settings.notifications.popups.durationDescription",
                "Applications may request a longer safe timeout"
            )
            from: 3000
            to: 15000
            stepSize: 1000
            value: ConfigStore.notificationPopupDuration
            valueLabel: (value / 1000).toFixed(0) + " s"
            onValueEdited: value =>
                ConfigStore.setNotificationValue(
                    "notificationPopupDuration",
                    value
                )
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr(
                "settings.notifications.popups.maximum",
                "Maximum visible"
            )
            description: I18n.tr(
                "settings.notifications.popups.maximumDescription",
                "Limit simultaneous popup cards"
            )
            from: 1
            to: 5
            stepSize: 1
            value: ConfigStore.notificationPopupMaximum
            valueLabel: Math.round(value).toString()
            onValueEdited: value =>
                ConfigStore.setNotificationValue(
                    "notificationPopupMaximum",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.notifications.popups.images",
                "Show images"
            )
            description: I18n.tr(
                "settings.notifications.popups.imagesDescription",
                "Display application icons and supplied artwork"
            )
            checked: ConfigStore.notificationShowImages
            onToggled: value =>
                ConfigStore.setNotificationValue(
                    "notificationShowImages",
                    value
                )
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.notifications.history.section",
            "History"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.notifications.history.keep",
                "Keep notification history"
            )
            description: I18n.tr(
                "settings.notifications.history.keepDescription",
                "Retain up to 50 entries for this shell session"
            )
            checked: ConfigStore.notificationKeepHistory
            onToggled: value =>
                ConfigStore.setNotificationValue(
                    "notificationKeepHistory",
                    value
                )
        }

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.notifications.history.clear",
                "Clear history"
            )
            description: I18n.tr(
                "settings.notifications.history.entries",
                "%1 entries currently retained",
                [NotificationService.history.length]
            )
            actionLabel: I18n.tr(
                "settings.notifications.history.clearAction",
                "Clear"
            )
            onActivated: NotificationService.clearHistory()
        }
    }
}

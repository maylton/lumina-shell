pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.notifications
import qs.stores.config

SettingsPage {
    id: root

    title: "Notifications"
    description: "Popup placement, timing, history, and interruptions"

    SettingsSection {
        title: "Interruptions"

        SettingsSwitchRow {
            width: parent.width
            title: "Do Not Disturb"
            description: checked
                ? "Popups are paused; history remains available"
                : "New notifications may appear as popups"
            checked: ConfigStore.doNotDisturb
            onToggled: value =>
                NotificationService.setDoNotDisturb(value)
        }
    }

    SettingsSection {
        title: "Popups"

        SettingsComboRow {
            width: parent.width
            title: "Position"
            description: "Screen corner used for notification popups"
            options: [
                { value: "top-left", label: "Top left" },
                { value: "top-right", label: "Top right" },
                { value: "bottom-left", label: "Bottom left" },
                { value: "bottom-right", label: "Bottom right" }
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
            title: "Default duration"
            description: "Applications may request a longer safe timeout"
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
            title: "Maximum visible"
            description: "Limit simultaneous popup cards"
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
            title: "Show images"
            description: "Display application icons and supplied artwork"
            checked: ConfigStore.notificationShowImages
            onToggled: value =>
                ConfigStore.setNotificationValue(
                    "notificationShowImages",
                    value
                )
        }
    }

    SettingsSection {
        title: "History"

        SettingsSwitchRow {
            width: parent.width
            title: "Keep notification history"
            description: "Retain up to 50 entries for this shell session"
            checked: ConfigStore.notificationKeepHistory
            onToggled: value =>
                ConfigStore.setNotificationValue(
                    "notificationKeepHistory",
                    value
                )
        }

        SettingsActionRow {
            width: parent.width
            title: "Clear history"
            description: NotificationService.history.length
                + " entries currently retained"
            actionLabel: "Clear"
            onActivated: NotificationService.clearHistory()
        }
    }
}

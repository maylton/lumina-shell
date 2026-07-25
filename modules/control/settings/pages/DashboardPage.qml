pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

SettingsPage {
    id: root

    title: I18n.tr(
        "settings.category.dashboard.label",
        "Dashboard"
    )
    description: I18n.tr(
        "settings.page.dashboard.description",
        "Opening behavior, density, and visible daily cards"
    )

    SettingsSection {
        title: "Opening"

        SettingsComboRow {
            width: parent.width
            title: "Default page"
            description: "Used when the last page is not remembered"
            options: [
                { value: "dashboard", label: "Dashboard" },
                { value: "settings", label: "Settings" }
            ]
            currentValue: ConfigStore.dashboardDefaultPage
            onSelected: value =>
                ConfigStore.setDashboardValue(
                    "dashboardDefaultPage",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Remember last page"
            description: "Reopen on the page used most recently"
            checked: ConfigStore.dashboardRememberPage
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardRememberPage",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Remember settings category"
            description: "Return to the most recent category"
            checked: ConfigStore.dashboardRememberCategory
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardRememberCategory",
                    value
                )
        }

        SettingsComboRow {
            width: parent.width
            title: "Card density"
            description: "Adjust spacing without shrinking text"
            options: [
                { value: "compact", label: "Compact" },
                { value: "comfortable", label: "Comfortable" },
                { value: "spacious", label: "Spacious" }
            ]
            currentValue: ConfigStore.dashboardDensity
            onSelected: value =>
                ConfigStore.setDashboardValue(
                    "dashboardDensity",
                    value
                )
        }
    }

    SettingsSection {
        title: "Visible cards"
        description: "Disabled cards release their layout space"

        SettingsSwitchRow {
            width: parent.width
            title: "Overview and workspaces"
            checked: ConfigStore.dashboardShowOverview
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowOverview",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Weather"
            description: "Show Open-Meteo below the clock"
            available: ConfigStore.dashboardShowOverview
            availabilityText: "Enable the overview card first"
            checked: ConfigStore.dashboardShowWeather
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowWeather",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Quick controls"
            checked: ConfigStore.dashboardShowControls
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowControls",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Notifications"
            checked: ConfigStore.dashboardShowNotifications
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowNotifications",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Media"
            checked: ConfigStore.dashboardShowMedia
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowMedia",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "System status"
            checked: ConfigStore.dashboardShowSystem
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowSystem",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Calendar"
            checked: ConfigStore.dashboardShowCalendar
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowCalendar",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Session action"
            description: "Show the session shortcut in the header"
            checked: ConfigStore.dashboardShowSessionActions
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowSessionActions",
                    value
                )
        }
    }
}

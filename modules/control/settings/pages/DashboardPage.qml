pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Dialogs
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

    function avatarFileName(source) {
        const value = decodeURIComponent(String(source || ""))
        const separator = value.lastIndexOf("/")

        return separator >= 0
            ? value.slice(separator + 1)
            : value
    }

    FileDialog {
        id: avatarDialog

        title: I18n.tr(
            "settings.dashboard.avatar.dialogTitle",
            "Choose a profile picture"
        )
        fileMode: FileDialog.OpenFile
        nameFilters: [
            I18n.tr(
                "settings.dashboard.fileFilter.images",
                "Images (*.png *.jpg *.jpeg *.webp *.bmp)"
            ),
            I18n.tr(
                "settings.dashboard.fileFilter.all",
                "All files (*)"
            )
        ]
        onAccepted: ConfigStore.setDashboardValue(
            "dashboardUserAvatarPath",
            String(selectedFile)
        )
    }

    SettingsSection {
        title: I18n.tr(
            "settings.dashboard.avatar.section",
            "Personal identity"
        )
        description: I18n.tr(
            "settings.dashboard.avatar.sectionDescription",
            "Shared by the bar entry point and Dashboard welcome card"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.avatar.useImage",
                "Use profile picture"
            )
            description: I18n.tr(
                "settings.dashboard.avatar.useImageDescription",
                "Fall back to account initials when disabled"
            )
            iconName: "avatar-default-symbolic"
            symbol: "●"
            checked: ConfigStore.dashboardUseUserAvatarImage
            onToggled: value => ConfigStore.setDashboardValue(
                "dashboardUseUserAvatarImage",
                value
            )
        }

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.avatar.customImage",
                "Custom picture"
            )
            description: ConfigStore.dashboardUserAvatarPath
                ? root.avatarFileName(
                    ConfigStore.dashboardUserAvatarPath
                )
                : I18n.tr(
                    "settings.dashboard.avatar.priority",
                    "Used after the system account image and .face"
                )
            iconName: "image-x-generic-symbolic"
            symbol: "▣"
            actionLabel: ConfigStore.dashboardUserAvatarPath
                ? I18n.tr(
                    "settings.dashboard.avatar.change",
                    "Change"
                )
                : I18n.tr(
                    "settings.dashboard.avatar.choose",
                    "Choose"
                )
            onActivated: avatarDialog.open()
        }

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.avatar.systemImage",
                "System account picture"
            )
            description: I18n.tr(
                "settings.dashboard.avatar.systemImageDescription",
                "Remove the custom fallback and use system sources"
            )
            available:
                ConfigStore.dashboardUserAvatarPath.length > 0
            availabilityText: I18n.tr(
                "settings.dashboard.avatar.noCustomImage",
                "No custom picture selected"
            )
            iconName: "edit-clear-symbolic"
            symbol: "×"
            actionLabel: I18n.tr(
                "settings.dashboard.avatar.clear",
                "Clear"
            )
            onActivated: ConfigStore.setDashboardValue(
                "dashboardUserAvatarPath",
                ""
            )
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.dashboard.opening.section",
            "Opening"
        )

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.opening.defaultPage",
                "Default page"
            )
            description: I18n.tr(
                "settings.dashboard.opening.defaultPageDescription",
                "Used when the last page is not remembered"
            )
            options: [
                { value: "dashboard", label: "Dashboard" },
                {
                    value: "settings",
                    label: I18n.tr(
                        "settings.dashboard.opening.settings",
                        "Settings"
                    )
                }
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
            title: I18n.tr(
                "settings.dashboard.opening.rememberPage",
                "Remember last page"
            )
            description: I18n.tr(
                "settings.dashboard.opening.rememberPageDescription",
                "Reopen on the page used most recently"
            )
            checked: ConfigStore.dashboardRememberPage
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardRememberPage",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.opening.rememberCategory",
                "Remember settings category"
            )
            description: I18n.tr(
                "settings.dashboard.opening.rememberCategoryDescription",
                "Return to the most recent category"
            )
            checked: ConfigStore.dashboardRememberCategory
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardRememberCategory",
                    value
                )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.density.title",
                "Card density"
            )
            description: I18n.tr(
                "settings.dashboard.density.description",
                "Adjust spacing without shrinking text"
            )
            options: [
                {
                    value: "compact",
                    label: I18n.tr(
                        "settings.dashboard.density.compact",
                        "Compact"
                    )
                },
                {
                    value: "comfortable",
                    label: I18n.tr(
                        "settings.dashboard.density.comfortable",
                        "Comfortable"
                    )
                },
                {
                    value: "spacious",
                    label: I18n.tr(
                        "settings.dashboard.density.spacious",
                        "Spacious"
                    )
                }
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
        title: I18n.tr(
            "settings.dashboard.cards.section",
            "Visible cards"
        )
        description: I18n.tr(
            "settings.dashboard.cards.description",
            "Disabled cards release their layout space"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.cards.overview",
                "Overview and workspaces"
            )
            checked: ConfigStore.dashboardShowOverview
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowOverview",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.weather.enabled",
                "Show weather"
            )
            description: I18n.tr(
                "settings.weather.enabledDescription",
                "Display current conditions below the Dashboard clock"
            )
            available: ConfigStore.dashboardShowOverview
            availabilityText: I18n.tr(
                "settings.dashboard.weather.enableOverviewFirst",
                "Enable the overview card first"
            )
            checked: ConfigStore.dashboardShowWeather
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowWeather",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.cards.controls",
                "Quick controls"
            )
            checked: ConfigStore.dashboardShowControls
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowControls",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.cards.notifications",
                "Notifications"
            )
            checked: ConfigStore.dashboardShowNotifications
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowNotifications",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.cards.media",
                "Media"
            )
            checked: ConfigStore.dashboardShowMedia
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowMedia",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.cards.system",
                "System status"
            )
            checked: ConfigStore.dashboardShowSystem
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowSystem",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.cards.calendar",
                "Calendar"
            )
            checked: ConfigStore.dashboardShowCalendar
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowCalendar",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.dashboard.cards.session",
                "Session action"
            )
            description: I18n.tr(
                "settings.dashboard.cards.sessionDescription",
                "Show the session shortcut in the header"
            )
            checked: ConfigStore.dashboardShowSessionActions
            onToggled: value =>
                ConfigStore.setDashboardValue(
                    "dashboardShowSessionActions",
                    value
                )
        }
    }
}

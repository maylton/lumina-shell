pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.services.session
import qs.stores.config

SettingsPage {
    id: root

    title: I18n.tr(
        "settings.category.session.label",
        "Session"
    )
    description: I18n.tr(
        "settings.page.session.description",
        "Visibility and confirmation for existing session actions"
    )

    SettingsSection {
        title: I18n.tr(
            "settings.session.actions.section",
            "Available actions"
        )
        description: I18n.tr(
            "settings.session.actions.description",
            "Commands remain owned by SessionService"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.session.actions.lock",
                "Show lock"
            )
            description: I18n.tr(
                "settings.session.actions.lockDescription",
                "Uses loginctl; this is not a secure-lock guarantee"
            )
            checked: ConfigStore.sessionShowLock
            onToggled: value =>
                ConfigStore.setSessionValue(
                    "sessionShowLock",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.session.actions.suspend",
                "Show suspend"
            )
            description: SessionService.commandDescription("suspend")
            checked: ConfigStore.sessionShowSuspend
            onToggled: value =>
                ConfigStore.setSessionValue(
                    "sessionShowSuspend",
                    value
                )
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.session.confirmations.section",
            "Confirmations"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.session.confirmations.logout",
                "Confirm logout"
            )
            description: SessionService.commandDescription("logout")
            checked: ConfigStore.sessionConfirmLogout
            onToggled: value =>
                ConfigStore.setSessionValue(
                    "sessionConfirmLogout",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.session.confirmations.restart",
                "Confirm restart"
            )
            description: SessionService.commandDescription("reboot")
            checked: ConfigStore.sessionConfirmReboot
            onToggled: value =>
                ConfigStore.setSessionValue(
                    "sessionConfirmReboot",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.session.confirmations.poweroff",
                "Confirm power off"
            )
            description: SessionService.commandDescription("poweroff")
            checked: ConfigStore.sessionConfirmPoweroff
            onToggled: value =>
                ConfigStore.setSessionValue(
                    "sessionConfirmPoweroff",
                    value
                )
        }
    }
}

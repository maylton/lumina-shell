import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: I18n.tr(
            "settings.widget.avatar.section",
            "Personal entry point"
        )
        description: I18n.tr(
            "settings.widget.avatar.description",
            "Dashboard button identity"
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
                "dashboard", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "dashboard", "showBackground", value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr("settings.widget.avatar.avatar", "Avatar")
            description: I18n.tr(
                "settings.widget.avatar.avatarDescription",
                "Choose image priority or account initials"
            )
            options: [
                {
                    value: "automatic",
                    label: I18n.tr(
                        "settings.widget.avatar.automatic",
                        "Automatic"
                    )
                },
                {
                    value: "image",
                    label: I18n.tr(
                        "settings.widget.avatar.image",
                        "Image"
                    )
                },
                {
                    value: "initials",
                    label: I18n.tr(
                        "settings.widget.avatar.initials",
                        "Initials"
                    )
                }
            ]
            currentValue: String(ConfigStore.widgetSetting(
                "dashboard", "avatarDisplay", "image"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "dashboard", "avatarDisplay", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.avatar.userName",
                "User name"
            )
            description: I18n.tr(
                "settings.widget.avatar.userNameDescription",
                "Show the detected account name"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "dashboard", "showUserName", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "dashboard", "showUserName", value
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
                "dashboard", "surfacePlacement", "centered"
            ))
            onSelected: value => ConfigStore.setBarWidgetSetting(
                "dashboard", "surfacePlacement", value
            )
        }
    }
}

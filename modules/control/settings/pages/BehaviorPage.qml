pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

SettingsPage {
    id: root

    title: I18n.tr(
        "settings.category.behavior.label",
        "Behavior"
    )
    description: I18n.tr(
        "settings.page.behavior.description",
        "Focus, dismissal, and motion across Lumina overlays"
    )

    SettingsSection {
        title: I18n.tr(
            "settings.behavior.controlCenter.section",
            "Control Center"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.behavior.closeOutside.title",
                "Close when clicking outside"
            )
            description: I18n.tr(
                "settings.behavior.closeOutside.description",
                "Keep the panel open when disabled"
            )
            checked: ConfigStore.behaviorCloseOnOutside
            onToggled: value =>
                ConfigStore.setBehaviorValue(
                    "behaviorCloseOnOutside",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.behavior.activeOutput.title",
                "Open on active output"
            )
            description: I18n.tr(
                "settings.behavior.activeOutput.description",
                "Invalid output requests fall back to Niri focus"
            )
            checked: ConfigStore.behaviorOpenOnActiveOutput
            onToggled: value =>
                ConfigStore.setBehaviorValue(
                    "behaviorOpenOnActiveOutput",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.behavior.confirmDestructive.title",
                "Confirm destructive actions"
            )
            description: I18n.tr(
                "settings.behavior.confirmDestructive.description",
                "Logout, restart, power off, and reset"
            )
            checked: ConfigStore.destructiveConfirmations
            onToggled: value =>
                ConfigStore.setBehaviorValue(
                    "destructiveConfirmations",
                    value
                )
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.behavior.motion.section",
            "Motion"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.behavior.reduceMotion.title",
                "Reduce motion"
            )
            description: I18n.tr(
                "settings.behavior.reduceMotion.description",
                "Replace long transitions with minimal feedback"
            )
            checked: ConfigStore.reduceMotion
            onToggled: value =>
                ConfigStore.setBehaviorValue("reduceMotion", value)
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr(
                "settings.behavior.transitionDuration.title",
                "Transition duration"
            )
            description: I18n.tr(
                "settings.behavior.transitionDuration.description",
                "Global scale applied to Material motion"
            )
            available: ConfigStore.animationsEnabled
            availabilityText: I18n.tr(
                "settings.behavior.animationsDisabled",
                "Animations are disabled"
            )
            from: 0.5
            to: 2
            stepSize: 0.25
            value: ConfigStore.behaviorTransitionScale
            valueLabel: value.toFixed(2) + "×"
            onValueEdited: value =>
                ConfigStore.setBehaviorValue(
                    "behaviorTransitionScale",
                    value
                )
        }
    }
}

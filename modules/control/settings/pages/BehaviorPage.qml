pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.stores.config

SettingsPage {
    id: root

    title: "Behavior"
    description: "Focus, dismissal, and motion across Lumina overlays"

    SettingsSection {
        title: "Control Center"

        SettingsSwitchRow {
            width: parent.width
            title: "Close when clicking outside"
            description: "Keep the panel open when disabled"
            checked: ConfigStore.behaviorCloseOnOutside
            onToggled: value =>
                ConfigStore.setBehaviorValue(
                    "behaviorCloseOnOutside",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Open on active output"
            description: "Invalid output requests fall back to Niri focus"
            checked: ConfigStore.behaviorOpenOnActiveOutput
            onToggled: value =>
                ConfigStore.setBehaviorValue(
                    "behaviorOpenOnActiveOutput",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Confirm destructive actions"
            description: "Logout, restart, power off, and reset"
            checked: ConfigStore.destructiveConfirmations
            onToggled: value =>
                ConfigStore.setBehaviorValue(
                    "destructiveConfirmations",
                    value
                )
        }
    }

    SettingsSection {
        title: "Motion"

        SettingsSwitchRow {
            width: parent.width
            title: "Reduce motion"
            description: "Replace long transitions with minimal feedback"
            checked: ConfigStore.reduceMotion
            onToggled: value =>
                ConfigStore.setBehaviorValue("reduceMotion", value)
        }

        SettingsSliderRow {
            width: parent.width
            title: "Transition duration"
            description: "Global scale applied to Material motion"
            available: ConfigStore.animationsEnabled
            availabilityText: "Animations are disabled"
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

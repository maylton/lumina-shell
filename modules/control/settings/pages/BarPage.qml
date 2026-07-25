pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.stores.config

SettingsPage {
    id: root

    title: "Bar"
    description: "Position, density, and the information shown per output"

    SettingsSection {
        title: "Layout"
        description: "Sizing updates every output immediately"

        SettingsComboRow {
            width: parent.width
            title: "Position"
            description: "Anchor the shell bar to the screen edge"
            options: [
                { value: "top", label: "Top" },
                { value: "bottom", label: "Bottom" }
            ]
            currentValue: ConfigStore.barPosition
            onSelected: value =>
                ConfigStore.setBarValue("barPosition", value)
        }

        SettingsSliderRow {
            width: parent.width
            title: "Height"
            description: "Available range: 40–72 pixels"
            from: 40
            to: 72
            stepSize: 2
            value: ConfigStore.barHeight
            valueLabel: Math.round(value) + " px"
            onValueEdited: value =>
                ConfigStore.setBarValue("barHeight", value)
        }

        SettingsSliderRow {
            width: parent.width
            title: "Outer margin"
            description: "Space between the bar surface and screen edge"
            from: 0
            to: 18
            stepSize: 1
            value: ConfigStore.barMargin
            valueLabel: Math.round(value) + " px"
            onValueEdited: value =>
                ConfigStore.setBarValue("barMargin", value)
        }

        SettingsSliderRow {
            width: parent.width
            title: "Widget spacing"
            description: "Horizontal distance between major widgets"
            from: 2
            to: 24
            stepSize: 1
            value: ConfigStore.barWidgetSpacing
            valueLabel: Math.round(value) + " px"
            onValueEdited: value =>
                ConfigStore.setBarValue("barWidgetSpacing", value)
        }
    }

    SettingsSection {
        title: "Window and Niri"
        description: "Choose which compositor context remains visible"

        SettingsSwitchRow {
            width: parent.width
            title: "Window title"
            description: "Show the focused window title"
            checked: ConfigStore.barShowWindowTitle
            onToggled: value =>
                ConfigStore.setBarValue("barShowWindowTitle", value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Center title"
            description: "Center text inside the available title region"
            available: ConfigStore.barShowWindowTitle
            availabilityText: "Enable the window title first"
            checked: ConfigStore.barCenterWindowTitle
            onToggled: value =>
                ConfigStore.setBarValue(
                    "barCenterWindowTitle",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Application ID"
            description: "Show the app ID below the title"
            available: ConfigStore.barShowWindowTitle
            availabilityText: "Enable the window title first"
            checked: ConfigStore.barShowAppId
            onToggled: value =>
                ConfigStore.setBarValue("barShowAppId", value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Workspaces"
            description: "Show Niri workspaces for each output"
            checked: ConfigStore.barShowWorkspaces
            onToggled: value =>
                ConfigStore.setBarValue("barShowWorkspaces", value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Column indicator"
            description: "Show the focused Niri column position"
            checked: ConfigStore.barShowColumnIndicator
            onToggled: value =>
                ConfigStore.setBarValue(
                    "barShowColumnIndicator",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Output details"
            description: "Show Niri state, resolution, and scale"
            checked: ConfigStore.showStatusDetails
            onToggled: value =>
                ConfigStore.setShowStatusDetails(value)
        }
    }

    SettingsSection {
        title: "System widgets"

        SettingsSwitchRow {
            width: parent.width
            title: "System tray"
            description: "Show StatusNotifier items"
            checked: ConfigStore.barShowTray
            onToggled: value =>
                ConfigStore.setBarValue("barShowTray", value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Clock"
            description: "Show time and calendar access"
            checked: ConfigStore.barShowClock
            onToggled: value =>
                ConfigStore.setBarValue("barShowClock", value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: "24-hour format"
            description: "Use HH:mm instead of a 12-hour clock"
            available: ConfigStore.barShowClock
            availabilityText: "Enable the clock first"
            checked: ConfigStore.barClock24Hour
            onToggled: value =>
                ConfigStore.setBarValue("barClock24Hour", value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Show seconds"
            description: "Refresh the clock once per second"
            available: ConfigStore.barShowClock
            availabilityText: "Enable the clock first"
            checked: ConfigStore.barShowSeconds
            onToggled: value =>
                ConfigStore.setBarValue("barShowSeconds", value)
        }
    }
}

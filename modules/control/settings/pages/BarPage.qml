pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.stores.config

SettingsPage {
    id: root

    title: "Bar"
    description: "Surface, context, status, and widgets per output"

    function widgetLabel(widgetId) {
        const labels = {
            launcher: "Launcher",
            overview: "Overview",
            workspaces: "Workspaces",
            datetime: "Date and time",
            tray: "System tray",
            notifications: "Notifications",
            "system-status": "System status",
            dashboard: "Dashboard",
            wallpaper: "Wallpaper",
            session: "Session"
        }

        return labels[String(widgetId || "")] || String(widgetId)
    }

    function widgetDescription(widgetId) {
        const descriptions = {
            launcher: "Application search",
            overview: "Niri overview",
            workspaces: "Workspaces for this output",
            datetime: "Clock, date, and calendar",
            tray: "StatusNotifier items",
            notifications: "Notification center",
            "system-status": "Network, audio, and battery",
            dashboard: "Lumina quick controls",
            wallpaper: "Wallpaper picker",
            session: "Session and layout actions"
        }

        return descriptions[String(widgetId || "")] || ""
    }

    function configurableOrder(order) {
        const result = []

        for (var index = 0; index < order.length; ++index) {
            const id = String(order[index])

            if (["privacy", "keyboard"].indexOf(id) < 0)
                result.push(id)
        }

        return result
    }

    SettingsSection {
        title: "Surface"
        description: ConfigStore.barSurfaceMode === "edge-to-edge"
            ? "Edge-to-edge ignores the outer margin"
            : "Floating reserves margin around the visible surface"

        SettingsSegmentedControl {
            width: parent.width
            height: 44
            options: [
                { value: "edge-to-edge", label: "Edge-to-edge" },
                { value: "floating", label: "Floating" }
            ]
            currentValue: ConfigStore.barSurfaceMode
            onSelected: value => ConfigStore.setBarValue(
                "barSurfaceMode",
                value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: "Position"
            description: "Anchor the bar to the screen edge"
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
            title: "Visible height"
            description: "Expressive surface height, excluding margins"
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
            description: "Space around a floating bar"
            available: ConfigStore.barSurfaceMode === "floating"
            availabilityText:
                "Edge-to-edge mode does not use an outer margin"
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
            title: "Surface opacity"
            description: "Shared tonal-surface opacity"
            from: 0.72
            to: 1
            stepSize: 0.02
            value: ConfigStore.surfaceOpacity
            valueLabel: Math.round(value * 100) + "%"
            onValueEdited: value => ConfigStore.setAppearanceValue(
                "surfaceOpacity",
                value
            )
        }

        SettingsSliderRow {
            width: parent.width
            title: "Widget spacing"
            description: "Horizontal distance between clusters"
            from: 2
            to: 24
            stepSize: 1
            value: ConfigStore.barWidgetSpacing
            valueLabel: Math.round(value) + " px"
            onValueEdited: value => ConfigStore.setBarValue(
                "barWidgetSpacing",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Compact mode"
            description: "Reduce spacing while preserving touch targets"
            checked: ConfigStore.compactMode
            onToggled: value => ConfigStore.setAppearanceValue(
                "compactMode",
                value
            )
        }
    }

    SettingsSection {
        title: "Context"
        description: "Focused Niri context in the center of each output"

        SettingsSegmentedControl {
            width: parent.width
            height: 44
            options: [
                { value: "always", label: "Always" },
                { value: "contextual", label: "Contextual" },
                { value: "hidden", label: "Hidden" }
            ]
            currentValue: ConfigStore.barContextMode
            onSelected: value => ConfigStore.setBarValue(
                "barContextMode",
                value
            )
        }

        SettingsSliderRow {
            width: parent.width
            title: "Context duration"
            description: "Time before contextual information recedes"
            available: ConfigStore.barContextMode === "contextual"
            availabilityText: "Choose Contextual mode first"
            from: 1000
            to: 15000
            stepSize: 500
            value: ConfigStore.barContextTimeout
            valueLabel: (value / 1000).toFixed(1) + " s"
            onValueEdited: value => ConfigStore.setBarValue(
                "barContextTimeout",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Window title"
            description: "Include the focused window title"
            checked: ConfigStore.barShowWindowTitle
            onToggled: value => ConfigStore.setBarValue(
                "barShowWindowTitle",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Application ID"
            description: "Include the focused application ID"
            checked: ConfigStore.barShowAppId
            onToggled: value =>
                ConfigStore.setBarValue("barShowAppId", value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Column"
            description: "Include the focused Niri column or tile"
            checked: ConfigStore.barShowColumnIndicator
            onToggled: value => ConfigStore.setBarValue(
                "barShowColumnIndicator",
                value
            )
        }
    }

    SettingsSection {
        title: "Date and time"

        SettingsSwitchRow {
            width: parent.width
            title: "Show date"
            description: "Place the date beside the clock"
            checked: ConfigStore.barShowDate
            onToggled: value =>
                ConfigStore.setBarValue("barShowDate", value)
        }

        SettingsComboRow {
            width: parent.width
            title: "Date style"
            description: "Choose the localized date detail"
            available: ConfigStore.barShowDate
            availabilityText: "Enable the date first"
            options: [
                { value: "short", label: "25 Jul" },
                { value: "weekday", label: "Fri, 25 Jul" },
                { value: "full", label: "Full" }
            ]
            currentValue: ConfigStore.barDateStyle
            onSelected: value =>
                ConfigStore.setBarValue("barDateStyle", value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: "24-hour format"
            description: "Use HH:mm instead of a 12-hour clock"
            checked: ConfigStore.barClock24Hour
            onToggled: value => ConfigStore.setBarValue(
                "barClock24Hour",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Show seconds"
            description: "Refresh the clock once per second"
            checked: ConfigStore.barShowSeconds
            onToggled: value =>
                ConfigStore.setBarValue("barShowSeconds", value)
        }
    }

    SettingsSection {
        title: "System status"
        description: "Only available native service data is shown"

        SettingsSegmentedControl {
            width: parent.width
            height: 44
            options: [
                { value: "grouped", label: "Grouped" },
                { value: "individual", label: "Individual" }
            ]
            currentValue: ConfigStore.barStatusLayout
            onSelected: value => ConfigStore.setBarValue(
                "barStatusLayout",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Audio"
            description: "Volume, mute, and output availability"
            checked: ConfigStore.barShowAudioStatus
            onToggled: value => ConfigStore.setBarValue(
                "barShowAudioStatus",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Volume text"
            description: "Show percentage or muted state beside the icon"
            available: ConfigStore.barShowAudioStatus
            availabilityText: "Enable the audio widget first"
            checked: ConfigStore.barShowAudioLabel
            onToggled: value => ConfigStore.setBarValue(
                "barShowAudioLabel",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Network"
            description: "Connected network or offline state"
            checked: ConfigStore.barShowNetworkStatus
            onToggled: value => ConfigStore.setBarValue(
                "barShowNetworkStatus",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Network text"
            description: "Show connection name or state beside the icon"
            available: ConfigStore.barShowNetworkStatus
            availabilityText: "Enable the network widget first"
            checked: ConfigStore.barShowNetworkLabel
            onToggled: value => ConfigStore.setBarValue(
                "barShowNetworkLabel",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Battery"
            description: "Shown only when a laptop battery exists"
            checked: ConfigStore.barShowBatteryStatus
            onToggled: value => ConfigStore.setBarValue(
                "barShowBatteryStatus",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "System tray"
            description: "Show StatusNotifier items"
            checked: ConfigStore.barShowTray
            onToggled: value =>
                ConfigStore.setBarWidgetVisible("tray", value)
        }

        SettingsComboRow {
            width: parent.width
            title: "Tray icons"
            description: ConfigStore.barTrayMode === "grouped"
                ? "Keep items in a compact menu"
                : "Keep every active item visible on the bar"
            available: ConfigStore.barShowTray
            availabilityText: "Enable the system tray first"
            options: [
                { value: "grouped", label: "Grouped" },
                { value: "inline", label: "Always visible" }
            ]
            currentValue: ConfigStore.barTrayMode
            onSelected: value =>
                ConfigStore.setBarValue("barTrayMode", value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Notifications"
            description: "Show notification center access"
            checked: ConfigStore.barShowNotifications
            onToggled: value => ConfigStore.setBarWidgetVisible(
                "notifications",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Dashboard button"
            description: "Show dedicated Lumina quick controls"
            checked: ConfigStore.barShowDashboardButton
            onToggled: value => ConfigStore.setBarWidgetVisible(
                "dashboard",
                value
            )
        }
    }

    SettingsSection {
        title: "Optional actions"
        description: "Wallpaper and session remain in the Dashboard"

        SettingsSwitchRow {
            width: parent.width
            title: "Wallpaper button"
            description: "Also expose the wallpaper picker on the bar"
            checked: ConfigStore.barShowWallpaperButton
            onToggled: value => ConfigStore.setBarWidgetVisible(
                "wallpaper",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Session button"
            description: "Also expose session actions on the bar"
            checked: ConfigStore.barShowSessionButton
            onToggled: value => ConfigStore.setBarWidgetVisible(
                "session",
                value
            )
        }
    }

    SettingsSection {
        title: "Left widget order"
        description: "Move and hide widgets without restarting"

        Repeater {
            model: root.configurableOrder(
                ConfigStore.barLeftWidgetOrder
            )

            delegate: BarWidgetOrderRow {
                required property var modelData
                required property int index

                width: parent.width
                widgetTitle: root.widgetLabel(modelData)
                description: root.widgetDescription(modelData)
                checked: ConfigStore.barWidgetVisible(modelData)
                canMoveUp: index > 0
                canMoveDown: index < root.configurableOrder(
                    ConfigStore.barLeftWidgetOrder
                ).length - 1
                onToggled: value =>
                    ConfigStore.setBarWidgetVisible(modelData, value)
                onMoveUp:
                    ConfigStore.moveBarWidget("left", modelData, -1)
                onMoveDown:
                    ConfigStore.moveBarWidget("left", modelData, 1)
            }
        }
    }

    SettingsSection {
        title: "Right widget order"
        description: "Privacy and keyboard indicators remain hidden until a native backend is available"

        Repeater {
            model: root.configurableOrder(
                ConfigStore.barRightWidgetOrder
            )

            delegate: BarWidgetOrderRow {
                required property var modelData
                required property int index

                width: parent.width
                widgetTitle: root.widgetLabel(modelData)
                description: root.widgetDescription(modelData)
                checked: ConfigStore.barWidgetVisible(modelData)
                canMoveUp: index > 0
                canMoveDown: index < root.configurableOrder(
                    ConfigStore.barRightWidgetOrder
                ).length - 1
                onToggled: value =>
                    ConfigStore.setBarWidgetVisible(modelData, value)
                onMoveUp:
                    ConfigStore.moveBarWidget("right", modelData, -1)
                onMoveDown:
                    ConfigStore.moveBarWidget("right", modelData, 1)
            }
        }
    }
}

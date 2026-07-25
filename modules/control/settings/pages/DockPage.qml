pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.dock
import "../../../dock/DockStrings.js" as DockStrings

SettingsPage {
    id: root

    function text(key) {
        return DockStrings.text(I18n.locale, key)
    }

    title: "Dock"
    description: DockPreferences.lastError
        || text("pageDescription")
    customSaveStatus: DockPreferences.lastError
        ? I18n.tr(
            "settings.save.failed",
            "Could not save"
        )
        : DockPreferences.saving || DockPreferences.dirty
            ? I18n.tr(
                "settings.save.saving",
                "Saving…"
            )
            : I18n.tr(
                "settings.save.saved",
                "Saved"
            )
    customSaveFailed: DockPreferences.lastError.length > 0

    SettingsSection {
        title: root.text("visibility")
        description: root.text("visibilityDescription")

        SettingsSwitchRow {
            width: parent.width
            title: root.text("enable")
            description: root.text("enableDescription")
            iconName: "user-desktop-symbolic"
            symbol: "▱"
            checked: DockPreferences.enabled
            onToggled: value => DockPreferences.setEnabled(value)
        }

        SettingsComboRow {
            width: parent.width
            title: root.text("mode")
            description: DockPreferences.mode === "task-panel"
                ? root.text("modeTaskPanelDescription")
                : root.text("modeFloatingDescription")
            options: [
                {
                    value: "floating",
                    label: root.text("modeFloating")
                },
                {
                    value: "task-panel",
                    label: root.text("modeTaskPanel")
                }
            ]
            currentValue: DockPreferences.mode
            available: DockPreferences.enabled
            onSelected: value => DockPreferences.setMode(value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: root.text("autoHide")
            description: root.text("autoHideDescription")
            iconName: "go-down-symbolic"
            symbol: "⌄"
            checked: DockPreferences.autoHide
            available: DockPreferences.enabled
            onToggled: value => DockPreferences.setAutoHide(value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: root.text("showRunning")
            description: root.text("showRunningDescription")
            iconName: "application-x-executable-symbolic"
            symbol: "●"
            checked: DockPreferences.showRunning
            available: DockPreferences.enabled
            onToggled: value => DockPreferences.setShowRunning(value)
        }

        SettingsSwitchRow {
            width: parent.width
            title: root.text("reserveSpace")
            description: root.text("reserveSpaceDescription")
            iconName: "view-paged-symbolic"
            symbol: "▔"
            checked: DockPreferences.reserveSpace
            available: DockPreferences.enabled
                && !DockPreferences.autoHide
            availabilityText: root.text("reserveUnavailable")
            onToggled: value => DockPreferences.setReserveSpace(value)
        }
    }

    SettingsSection {
        title: root.text("appearance")
        description: root.text("appearanceDescription")

        SettingsSliderRow {
            width: parent.width
            title: root.text("iconSize")
            description: root.text("iconSizeDescription")
            iconName: "preferences-desktop-icons-symbolic"
            symbol: "□"
            value: DockPreferences.iconSize
            from: 30
            to: 72
            stepSize: 2
            valueLabel: Math.round(value) + " px"
            available: DockPreferences.enabled
            onValueEdited: value => DockPreferences.setIconSize(value)
        }

        SettingsSliderRow {
            width: parent.width
            title: root.text("margin")
            description: root.text("marginDescription")
            iconName: "format-indent-more-symbolic"
            symbol: "↕"
            value: DockPreferences.margin
            from: 0
            to: 24
            stepSize: 1
            valueLabel: Math.round(value) + " px"
            available: DockPreferences.enabled
                && DockPreferences.mode === "floating"
            availabilityText: root.text("modeFloatingDescription")
            onValueEdited: value => DockPreferences.setMargin(value)
        }
    }

    SettingsSection {
        title: root.text("favorites")
        description: root.text("favoritesDescription")

        SettingsActionRow {
            visible: DockPreferences.favoriteAppIds.length === 0
            width: parent.width
            title: root.text("noFavorites")
            description: root.text("noFavoritesDescription")
            iconName: "starred-symbolic"
            symbol: "☆"
            actionLabel: "—"
            available: false
        }

        Repeater {
            model: DockPreferences.favoriteAppIds

            delegate: SettingsActionRow {
                required property string modelData

                readonly property var desktopEntry:
                    DockStore.entryFor(modelData)

                width: parent.width
                title: DockStore.titleForFavorite(modelData)
                description: modelData
                iconName: desktopEntry && desktopEntry.icon
                    ? String(desktopEntry.icon)
                    : "application-x-executable"
                symbol: "◆"
                actionLabel: root.text("remove")
                destructive: true
                onActivated: DockPreferences.unpin(modelData)
            }
        }

        SettingsActionRow {
            visible: DockPreferences.favoriteAppIds.length > 0
            width: parent.width
            title: root.text("clear")
            description: root.text("clearDescription")
            iconName: "edit-clear-all-symbolic"
            symbol: "×"
            actionLabel: root.text("clear")
            destructive: true
            onActivated: DockPreferences.clearFavorites()
        }
    }

    SettingsSection {
        title: root.text("reset")

        SettingsActionRow {
            width: parent.width
            title: root.text("reset")
            description: root.text("resetDescription")
            iconName: "edit-undo-symbolic"
            symbol: "↶"
            actionLabel: root.text("reset")
            onActivated: DockPreferences.reset()
        }
    }
}

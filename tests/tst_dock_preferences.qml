import QtQuick
import QtTest
import "../stores/dock/DockPreferences.js" as Preferences

TestCase {
    name: "DockPreferences"

    function test_defaultsKeepDockOptional() {
        const state = Preferences.defaults()

        compare(state.enabled, false)
        compare(state.mode, "floating")
        compare(state.autoHide, true)
        compare(state.showRunning, true)
        compare(state.iconSize, 36)
        compare(state.margin, 10)
        compare(state.favoriteAppIds.length, 0)
    }

    function test_valuesAreClampedAndFavoritesDeduplicated() {
        const state = Preferences.normalize({
            schemaVersion: Preferences.CURRENT_VERSION,
            enabled: true,
            mode: "task-panel",
            autoHide: false,
            iconSize: 500,
            margin: -10,
            favoriteAppIds: [
                "firefox.desktop",
                "firefox.desktop",
                "org.kde.dolphin.desktop",
                ""
            ]
        })

        compare(state.enabled, true)
        compare(state.mode, "task-panel")
        compare(state.autoHide, false)
        compare(state.iconSize, 72)
        compare(state.margin, 0)
        compare(state.favoriteAppIds.length, 2)
        compare(state.favoriteAppIds[0], "firefox.desktop")
    }

    function test_iconSizeUsesThirtyPixelMinimum() {
        const state = Preferences.normalize({
            schemaVersion: Preferences.CURRENT_VERSION,
            iconSize: 12
        })

        compare(state.iconSize, 30)
    }

    function test_legacyGeneratedDefaultMigratesToNewBaseline() {
        const state = Preferences.normalize({
            schemaVersion: 1,
            iconSize: 50
        })

        compare(state.schemaVersion, Preferences.CURRENT_VERSION)
        compare(state.iconSize, 36)
    }

    function test_legacyCustomizedSizeIsPreserved() {
        const state = Preferences.normalize({
            schemaVersion: 1,
            iconSize: 44
        })

        compare(state.iconSize, 44)
    }

    function test_invalidValuesFallBackSafely() {
        const state = Preferences.normalize({
            enabled: "yes",
            mode: "panel",
            showRunning: 1,
            reserveSpace: "true",
            iconSize: "invalid",
            favoriteAppIds: "firefox"
        })

        compare(state.enabled, false)
        compare(state.mode, "floating")
        compare(state.showRunning, true)
        compare(state.reserveSpace, false)
        compare(state.iconSize, 36)
        compare(state.favoriteAppIds.length, 0)
    }
}

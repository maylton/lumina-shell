import QtQuick
import QtTest
import "../stores/config/ConfigSchema.js" as ConfigSchema

TestCase {
    name: "ConfigSchema"

    function test_defaultsUseSchema4() {
        const state = ConfigSchema.defaults()

        compare(state.schemaVersion, 4)
        compare(state.themeMode, "auto")
        compare(state.barHeight, 48)
        compare(state.notificationPopupMaximum, 3)
        compare(state.osdDuration, 1800)
        verify(state.dashboardCardOrder.length > 0)
    }

    function test_schema3MigrationPreservesExistingValues() {
        const migrated = ConfigSchema.migrate({
            schemaVersion: 3,
            doNotDisturb: true,
            dynamicTheme: false,
            wallpaperDirectory: "/tmp/wallpapers",
            osdDuration: 3000,
            showStatusDetails: false
        })

        compare(migrated.schemaVersion, 4)
        compare(migrated.doNotDisturb, true)
        compare(migrated.dynamicTheme, false)
        compare(migrated.wallpaperDirectory, "/tmp/wallpapers")
        compare(migrated.osdDuration, 3000)
        compare(migrated.showStatusDetails, false)
        compare(migrated.themeMode, "auto")
    }

    function test_legacyWallpaperStringMigrates() {
        const migrated = ConfigSchema.migrate({
            schemaVersion: 3,
            wallpapers: "/tmp/legacy.png"
        })

        compare(migrated.defaultWallpaper, "/tmp/legacy.png")
        compare(Object.keys(migrated.wallpapers).length, 0)
    }

    function test_numericValuesAreClamped() {
        const state = ConfigSchema.normalize({
            surfaceOpacity: 0.1,
            animationScale: 8,
            cornerRadiusScale: 0,
            barHeight: 500,
            barMargin: -4,
            notificationPopupDuration: 100,
            notificationPopupMaximum: 50,
            osdDuration: 9000,
            osdSize: 3
        })

        compare(state.surfaceOpacity, 0.72)
        compare(state.animationScale, 2)
        compare(state.cornerRadiusScale, 0.6)
        compare(state.barHeight, 72)
        compare(state.barMargin, 0)
        compare(state.notificationPopupDuration, 3000)
        compare(state.notificationPopupMaximum, 5)
        compare(state.osdDuration, 5000)
        compare(state.osdSize, 1.4)
    }

    function test_resetCategoryIsScoped() {
        const appearance =
            ConfigSchema.defaultsForCategory("appearance")
        const bar = ConfigSchema.defaultsForCategory("bar")

        compare(appearance.themeMode, "auto")
        verify(appearance.barHeight === undefined)
        compare(bar.barHeight, 48)
        verify(bar.themeMode === undefined)
    }

    function test_resetAllMatchesDefaults() {
        const reset = ConfigSchema.defaults()
        const normalized = ConfigSchema.normalize(reset)

        compare(JSON.stringify(normalized), JSON.stringify(reset))
    }

    function test_categoryNormalization() {
        compare(
            ConfigSchema.normalizeSettingsCategory("wallpaper"),
            "appearance"
        )
        compare(
            ConfigSchema.normalizeSettingsCategory("about"),
            "about"
        )
        compare(
            ConfigSchema.normalizeSettingsCategory("unknown"),
            "appearance"
        )
    }

    function test_serializationRestoresSettings() {
        const configured = ConfigSchema.normalize({
            themeMode: "light",
            barPosition: "bottom",
            dashboardShowMedia: false,
            notificationPopupPosition: "bottom-left",
            osdSize: 1.2,
            sessionConfirmPoweroff: false
        })
        const restored = ConfigSchema.migrate(
            JSON.parse(JSON.stringify(configured))
        )

        compare(restored.themeMode, "light")
        compare(restored.barPosition, "bottom")
        compare(restored.dashboardShowMedia, false)
        compare(
            restored.notificationPopupPosition,
            "bottom-left"
        )
        compare(restored.osdSize, 1.2)
        compare(restored.sessionConfirmPoweroff, false)
    }
}

import QtQuick
import QtTest
import "../stores/config/ConfigSchema.js" as ConfigSchema

TestCase {
    name: "ConfigSchema"

    function test_defaultsUseSchema5ExpressiveBar() {
        const state = ConfigSchema.defaults()

        compare(state.schemaVersion, 5)
        compare(state.themeMode, "auto")
        compare(state.paletteStyle, "auto")
        compare(state.barVisualStyle, "expressive")
        compare(state.barSurfaceMode, "edge-to-edge")
        compare(state.barContextMode, "contextual")
        compare(state.barStatusLayout, "grouped")
        compare(state.barContextTimeout, 3500)
        compare(state.barHeight, 48)
        compare(state.barShowWallpaperButton, false)
        compare(state.barShowSessionButton, false)
        compare(state.barLeftWidgetOrder.length, 4)
        compare(state.barRightWidgetOrder.length, 6)
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

        compare(migrated.schemaVersion, 5)
        compare(migrated.doNotDisturb, true)
        compare(migrated.dynamicTheme, false)
        compare(migrated.wallpaperDirectory, "/tmp/wallpapers")
        compare(migrated.osdDuration, 3000)
        compare(migrated.showStatusDetails, false)
        compare(migrated.themeMode, "auto")
        compare(migrated.paletteStyle, "auto")
    }

    function test_schema4MigrationPreservesClassicBarValues() {
        const migrated = ConfigSchema.migrate({
            schemaVersion: 4,
            barPosition: "bottom",
            barHeight: 56,
            barMargin: 9,
            barWidgetSpacing: 14,
            barShowClock: false,
            barWidgetOrder: ["clock", "tray"]
        })

        compare(migrated.schemaVersion, 5)
        compare(migrated.barPosition, "bottom")
        compare(migrated.barHeight, 56)
        compare(migrated.barMargin, 9)
        compare(migrated.barWidgetSpacing, 14)
        compare(migrated.barShowClock, false)
        compare(
            JSON.stringify(migrated.barWidgetOrder),
            JSON.stringify(["clock", "tray"])
        )
        compare(migrated.barVisualStyle, "expressive")
        compare(migrated.barSurfaceMode, "edge-to-edge")
    }

    function test_paletteStyleNormalization() {
        const expressive = ConfigSchema.normalize({
            paletteStyle: "expressive"
        })
        const invalid = ConfigSchema.normalize({
            paletteStyle: "unsupported"
        })

        compare(expressive.paletteStyle, "expressive")
        compare(invalid.paletteStyle, "auto")
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
            barContextTimeout: 50,
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
        compare(state.barContextTimeout, 1000)
        compare(state.notificationPopupDuration, 3000)
        compare(state.notificationPopupMaximum, 5)
        compare(state.osdDuration, 5000)
        compare(state.osdSize, 1.4)
    }

    function test_expressiveBarChoiceNormalization() {
        const valid = ConfigSchema.normalize({
            barVisualStyle: "classic",
            barSurfaceMode: "floating",
            barContextMode: "always",
            barStatusLayout: "individual",
            barDateStyle: "full"
        })
        const invalid = ConfigSchema.normalize({
            barVisualStyle: "glass",
            barSurfaceMode: "detached",
            barContextMode: "polling",
            barStatusLayout: "stacked",
            barDateStyle: "numeric"
        })

        compare(valid.barVisualStyle, "classic")
        compare(valid.barSurfaceMode, "floating")
        compare(valid.barContextMode, "always")
        compare(valid.barStatusLayout, "individual")
        compare(valid.barDateStyle, "full")
        compare(invalid.barVisualStyle, "expressive")
        compare(invalid.barSurfaceMode, "edge-to-edge")
        compare(invalid.barContextMode, "contextual")
        compare(invalid.barStatusLayout, "grouped")
        compare(invalid.barDateStyle, "short")
    }

    function test_barWidgetOrdersAreUniqueAndComplete() {
        const state = ConfigSchema.normalize({
            barLeftWidgetOrder: [
                "workspaces",
                "unknown",
                "workspaces",
                "launcher"
            ],
            barRightWidgetOrder: [
                "dashboard",
                "session",
                "dashboard",
                "invalid"
            ]
        })

        compare(
            JSON.stringify(state.barLeftWidgetOrder),
            JSON.stringify([
                "workspaces",
                "launcher",
                "overview",
                "datetime"
            ])
        )
        compare(
            JSON.stringify(state.barRightWidgetOrder),
            JSON.stringify([
                "dashboard",
                "session",
                "privacy",
                "keyboard",
                "tray",
                "notifications",
                "system-status"
            ])
        )
    }

    function test_emptyBarWidgetOrdersRestoreRequiredIds() {
        const state = ConfigSchema.normalize({
            barLeftWidgetOrder: [],
            barRightWidgetOrder: "invalid"
        })
        const base = ConfigSchema.defaults()

        compare(
            JSON.stringify(state.barLeftWidgetOrder),
            JSON.stringify(base.barLeftWidgetOrder)
        )
        compare(
            JSON.stringify(state.barRightWidgetOrder),
            JSON.stringify(base.barRightWidgetOrder)
        )
    }

    function test_resetCategoryIsScoped() {
        const appearance =
            ConfigSchema.defaultsForCategory("appearance")
        const bar = ConfigSchema.defaultsForCategory("bar")

        compare(appearance.themeMode, "auto")
        compare(appearance.paletteStyle, "auto")
        verify(appearance.barHeight === undefined)
        compare(bar.barHeight, 48)
        compare(bar.barVisualStyle, "expressive")
        compare(bar.barContextMode, "contextual")
        compare(bar.barShowDashboardButton, true)
        compare(bar.barRightWidgetOrder.length, 6)
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
            paletteStyle: "fruit-salad",
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
        compare(restored.paletteStyle, "fruit-salad")
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

import QtQuick
import QtTest
import "../stores/config/ConfigSchema.js" as ConfigSchema

TestCase {
    name: "ConfigSchema"

    function test_defaultsUseSchema6Bar() {
        const state = ConfigSchema.defaults()

        compare(state.schemaVersion, 6)
        compare(state.themeMode, "auto")
        compare(state.paletteStyle, "auto")
        verify(state.barVisualStyle === undefined)
        verify(state.barWidgetOrder === undefined)
        compare(state.barSurfaceMode, "edge-to-edge")
        compare(state.barBackgroundMode, "solid")
        compare(state.barSurfaceOpacity, 0.86)
        compare(state.barAutoScaleContents, true)
        compare(state.barContentScale, 1)
        compare(state.barContextMode, "contextual")
        compare(state.barStatusLayout, "grouped")
        compare(state.barTrayMode, "grouped")
        compare(state.barShowAudioLabel, true)
        compare(state.barShowNetworkLabel, true)
        compare(state.barContextTimeout, 3500)
        compare(state.barHeight, 56)
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

        compare(migrated.schemaVersion, 6)
        compare(migrated.doNotDisturb, true)
        compare(migrated.dynamicTheme, false)
        compare(migrated.wallpaperDirectory, "/tmp/wallpapers")
        compare(migrated.osdDuration, 3000)
        compare(migrated.showStatusDetails, false)
        compare(migrated.themeMode, "auto")
        compare(migrated.paletteStyle, "auto")
    }

    function test_schema4MigrationPreservesBarValues() {
        const migrated = ConfigSchema.migrate({
            schemaVersion: 4,
            barPosition: "bottom",
            barHeight: 56,
            barMargin: 9,
            barWidgetSpacing: 14,
            barShowClock: false,
            barWidgetOrder: ["clock", "tray"]
        })

        compare(migrated.schemaVersion, 6)
        compare(migrated.barPosition, "bottom")
        compare(migrated.barHeight, 56)
        compare(migrated.barMargin, 9)
        compare(migrated.barWidgetSpacing, 14)
        compare(migrated.barShowClock, false)
        verify(migrated.barWidgetOrder === undefined)
        verify(migrated.barVisualStyle === undefined)
        compare(migrated.barSurfaceMode, "edge-to-edge")
        compare(migrated.barShowAudioLabel, true)
        compare(migrated.barShowNetworkLabel, true)
    }

    function test_schema5LegacyBarKeysAreIgnored() {
        const migrated = ConfigSchema.migrate({
            schemaVersion: 5,
            barVisualStyle: "classic",
            barWidgetOrder: ["clock", "tray"],
            barSurfaceMode: "floating",
            barLeftWidgetOrder: [
                "workspaces",
                "launcher",
                "overview",
                "datetime"
            ],
            barRightWidgetOrder: [
                "dashboard",
                "tray",
                "notifications",
                "system-status",
                "privacy",
                "keyboard"
            ]
        })

        verify(migrated.barVisualStyle === undefined)
        verify(migrated.barWidgetOrder === undefined)
        compare(migrated.barSurfaceMode, "floating")
        compare(migrated.barBackgroundMode, "solid")
        compare(migrated.barSurfaceOpacity, 0.86)
        compare(migrated.barAutoScaleContents, true)
        compare(migrated.barContentScale, 1)
        compare(
            JSON.stringify(migrated.barLeftWidgetOrder),
            JSON.stringify([
                "workspaces",
                "launcher",
                "overview",
                "datetime"
            ])
        )
        compare(
            JSON.stringify(migrated.barRightWidgetOrder),
            JSON.stringify([
                "dashboard",
                "tray",
                "notifications",
                "system-status",
                "privacy",
                "keyboard"
            ])
        )
    }

    function test_schema5TransparencyMigratesToBarSurface() {
        const migrated = ConfigSchema.migrate({
            schemaVersion: 5,
            transparencyEnabled: true,
            surfaceOpacity: 0.78,
            barLeftWidgetOrder: [
                "datetime",
                "workspaces",
                "launcher",
                "overview"
            ]
        })

        compare(migrated.schemaVersion, 6)
        compare(migrated.transparencyEnabled, true)
        compare(migrated.surfaceOpacity, 0.78)
        compare(migrated.barBackgroundMode, "translucent")
        compare(migrated.barSurfaceOpacity, 0.78)
        compare(migrated.barAutoScaleContents, true)
        compare(migrated.barContentScale, 1)
        compare(
            JSON.stringify(migrated.barLeftWidgetOrder),
            JSON.stringify([
                "datetime",
                "workspaces",
                "launcher",
                "overview"
            ])
        )
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
            barSurfaceOpacity: -2,
            barContentScale: 8,
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
        compare(state.barSurfaceOpacity, 0)
        compare(state.barContentScale, 1.4)
        compare(state.animationScale, 2)
        compare(state.cornerRadiusScale, 0.6)
        compare(state.barHeight, 80)
        compare(state.barMargin, 0)
        compare(state.barContextTimeout, 1000)
        compare(state.notificationPopupDuration, 3000)
        compare(state.notificationPopupMaximum, 5)
        compare(state.osdDuration, 5000)
        compare(state.osdSize, 1.4)
    }

    function test_barChoiceNormalization() {
        const valid = ConfigSchema.normalize({
            barSurfaceMode: "floating",
            barBackgroundMode: "transparent",
            barContextMode: "always",
            barStatusLayout: "individual",
            barTrayMode: "inline",
            barDateStyle: "full"
        })
        const invalid = ConfigSchema.normalize({
            barSurfaceMode: "detached",
            barBackgroundMode: "blurred",
            barContextMode: "polling",
            barStatusLayout: "stacked",
            barTrayMode: "floating",
            barDateStyle: "numeric"
        })

        compare(valid.barSurfaceMode, "floating")
        compare(valid.barBackgroundMode, "transparent")
        compare(valid.barContextMode, "always")
        compare(valid.barStatusLayout, "individual")
        compare(valid.barTrayMode, "inline")
        compare(valid.barDateStyle, "full")
        compare(invalid.barSurfaceMode, "edge-to-edge")
        compare(invalid.barBackgroundMode, "solid")
        compare(invalid.barContextMode, "contextual")
        compare(invalid.barStatusLayout, "grouped")
        compare(invalid.barTrayMode, "grouped")
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

    function test_arrayLikeWidgetOrdersArePreserved() {
        const state = ConfigSchema.normalize({
            barLeftWidgetOrder: {
                0: "datetime",
                1: "workspaces",
                2: "launcher",
                3: "overview",
                length: 4
            },
            barRightWidgetOrder: {
                0: "dashboard",
                1: "system-status",
                2: "notifications",
                3: "tray",
                4: "privacy",
                5: "keyboard",
                length: 6
            }
        })

        compare(
            JSON.stringify(state.barLeftWidgetOrder),
            JSON.stringify([
                "datetime",
                "workspaces",
                "launcher",
                "overview"
            ])
        )
        compare(
            JSON.stringify(state.barRightWidgetOrder),
            JSON.stringify([
                "dashboard",
                "system-status",
                "notifications",
                "tray",
                "privacy",
                "keyboard"
            ])
        )
    }

    function test_resetCategoryIsScoped() {
        const appearance =
            ConfigSchema.defaultsForCategory("appearance")
        const bar = ConfigSchema.defaultsForCategory("bar")

        compare(appearance.themeMode, "auto")
        compare(appearance.paletteStyle, "auto")
        verify(appearance.barHeight === undefined)
        compare(bar.barHeight, 56)
        verify(bar.barVisualStyle === undefined)
        verify(bar.barWidgetOrder === undefined)
        compare(bar.barSurfaceMode, "edge-to-edge")
        compare(bar.barBackgroundMode, "solid")
        compare(bar.barSurfaceOpacity, 0.86)
        compare(bar.barAutoScaleContents, true)
        compare(bar.barContentScale, 1)
        compare(bar.barContextMode, "contextual")
        compare(bar.barTrayMode, "grouped")
        compare(bar.barShowAudioLabel, true)
        compare(bar.barShowNetworkLabel, true)
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
            barTrayMode: "inline",
            barShowAudioLabel: false,
            barShowNetworkLabel: false,
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
        compare(restored.barTrayMode, "inline")
        compare(restored.barShowAudioLabel, false)
        compare(restored.barShowNetworkLabel, false)
        compare(restored.dashboardShowMedia, false)
        compare(
            restored.notificationPopupPosition,
            "bottom-left"
        )
        compare(restored.osdSize, 1.2)
        compare(restored.sessionConfirmPoweroff, false)
    }
}

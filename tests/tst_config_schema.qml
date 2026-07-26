import QtQuick
import QtTest
import "../stores/config/ConfigSchema.js" as ConfigSchema

TestCase {
    name: "ConfigSchema"

    function test_defaultsUseSchema9WidgetSettings() {
        const state = ConfigSchema.defaults()

        compare(state.schemaVersion, 9)
        compare(state.themeMode, "auto")
        compare(state.shellBackgroundMode, "solid")
        compare(state.shellSurfaceOpacity, 0.82)
        verify(state.transparencyEnabled === undefined)
        verify(state.surfaceOpacity === undefined)
        compare(state.paletteStyle, "auto")
        verify(state.barVisualStyle === undefined)
        verify(state.barWidgetOrder === undefined)
        compare(state.barSurfaceMode, "edge-to-edge")
        compare(state.barBackgroundMode, "solid")
        compare(state.barSurfaceOpacity, 0.86)
        compare(state.barAutoScaleContents, true)
        compare(state.barContentScale, 1)
        compare(state.barWidgetSettings.context.mode, "contextual")
        compare(
            state.barWidgetSettings["system-status"].layout,
            "grouped"
        )
        compare(state.barWidgetSettings.tray.mode, "grouped")
        compare(
            state.barWidgetSettings.datetime.hourFormat,
            "24"
        )
        compare(state.barWidgetSettings.launcher.showBackground, false)
        compare(
            state.barWidgetSettings.launcher.surfacePlacement,
            "centered"
        )
        compare(
            state.barWidgetSettings.datetime.surfacePlacement,
            "near-widget"
        )
        compare(state.dashboardUseUserAvatarImage, true)
        compare(state.dashboardUserAvatarPath, "")
        compare(state.barWidgetSettings.context.timeout, 3500)
        compare(state.barHeight, 56)
        compare(state.barPanelGap, 8)
        compare(state.barShowWallpaperButton, false)
        compare(state.barShowSessionButton, false)
        compare(state.barLeftWidgetOrder.length, 4)
        compare(state.barRightWidgetOrder.length, 4)
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

        compare(migrated.schemaVersion, 9)
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

        compare(migrated.schemaVersion, 9)
        compare(migrated.barPosition, "bottom")
        compare(migrated.barHeight, 56)
        compare(migrated.barMargin, 9)
        compare(migrated.barWidgetSpacing, 14)
        compare(migrated.barShowClock, false)
        verify(migrated.barWidgetOrder === undefined)
        verify(migrated.barVisualStyle === undefined)
        compare(migrated.barSurfaceMode, "edge-to-edge")
        compare(
            migrated.barWidgetSettings["system-status"].audioTextMode,
            "percentage"
        )
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
                "system-status"
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

        compare(migrated.schemaVersion, 9)
        verify(migrated.transparencyEnabled === undefined)
        verify(migrated.surfaceOpacity === undefined)
        compare(migrated.shellBackgroundMode, "blur")
        compare(migrated.shellSurfaceOpacity, 0.78)
        compare(migrated.barBackgroundMode, "blur")
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

    function test_schema6MigratesIndividualWidgetSettings() {
        const migrated = ConfigSchema.migrate({
            schemaVersion: 6,
            barWidgetPillsEnabled: false,
            barContextMode: "always",
            barContextTimeout: 8000,
            barShowWindowTitle: false,
            barShowAppId: false,
            barShowColumnIndicator: false,
            barShowDate: false,
            barClock24Hour: false,
            barShowSeconds: true,
            barTrayMode: "inline",
            barStatusLayout: "individual",
            barShowNetworkStatus: false,
            barShowAudioStatus: true,
            barShowBatteryStatus: false,
            barShowAudioLabel: false,
            barShowDashboardButton: false
        })

        compare(migrated.schemaVersion, 9)
        compare(migrated.barWidgetSettings.launcher.showBackground, false)
        compare(migrated.barWidgetSettings.context.mode, "always")
        compare(migrated.barWidgetSettings.context.timeout, 8000)
        compare(
            migrated.barWidgetSettings.context.showWindowTitle,
            false
        )
        compare(
            migrated.barWidgetSettings.context.showApplicationId,
            false
        )
        compare(migrated.barWidgetSettings.context.showColumn, false)
        compare(migrated.barWidgetSettings.datetime.dateMode, "hidden")
        compare(migrated.barWidgetSettings.datetime.hourFormat, "12")
        compare(migrated.barWidgetSettings.datetime.showSeconds, true)
        compare(migrated.barWidgetSettings.tray.mode, "inline")
        compare(
            migrated.barWidgetSettings["system-status"].layout,
            "individual"
        )
        compare(
            migrated.barWidgetSettings["system-status"].showNetwork,
            false
        )
        compare(
            migrated.barWidgetSettings["system-status"].audioTextMode,
            "icon"
        )
        compare(
            migrated.barWidgetSettings["system-status"].showBattery,
            false
        )
        compare(migrated.barShowSystemStatus, true)
        compare(migrated.barShowDashboardButton, false)
        verify(migrated.barWidgetPillsEnabled === undefined)
        verify(migrated.barContextMode === undefined)
        verify(migrated.barTrayMode === undefined)
    }

    function test_widgetSettingsIgnoreUnknownKeysAndInvalidValues() {
        const state = ConfigSchema.normalize({
            barWidgetSettings: {
                unknown: { enabled: true },
                datetime: {
                    hourFormat: "decimal",
                    showSeconds: "yes",
                    extra: "ignored"
                },
                "system-status": {
                    networkTextMode: "fictional"
                }
            }
        })

        verify(state.barWidgetSettings.unknown === undefined)
        compare(state.barWidgetSettings.datetime.hourFormat, "24")
        compare(state.barWidgetSettings.datetime.showSeconds, false)
        verify(state.barWidgetSettings.datetime.extra === undefined)
        compare(
            state.barWidgetSettings["system-status"].networkTextMode,
            "summary"
        )
    }

    function test_schema7TransparencyMigratesToShellSurfaceStyle() {
        const migrated = ConfigSchema.migrate({
            schemaVersion: 7,
            transparencyEnabled: true,
            surfaceOpacity: 0.74,
            barBackgroundMode: "frosted"
        })

        compare(migrated.schemaVersion, 9)
        compare(migrated.shellBackgroundMode, "blur")
        compare(migrated.shellSurfaceOpacity, 0.74)
        compare(migrated.barBackgroundMode, "frosted")
        verify(migrated.transparencyEnabled === undefined)
        verify(migrated.surfaceOpacity === undefined)
    }

    function test_schema8MigrationAddsPanelGap() {
        const migrated = ConfigSchema.migrate({
            schemaVersion: 8,
            barHeight: 64
        })

        compare(migrated.schemaVersion, 9)
        compare(migrated.barHeight, 64)
        compare(migrated.barPanelGap, 8)
    }

    function test_widgetSurfacePlacementNormalization() {
        const state = ConfigSchema.normalize({
            barWidgetSettings: {
                launcher: { surfacePlacement: "near-widget" },
                datetime: { surfacePlacement: "follow-pointer" }
            }
        })

        compare(
            state.barWidgetSettings.launcher.surfacePlacement,
            "near-widget"
        )
        compare(
            state.barWidgetSettings.datetime.surfacePlacement,
            "near-widget"
        )
        verify(
            state.barWidgetSettings.context.surfacePlacement === undefined
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
            shellSurfaceOpacity: 0.1,
            barSurfaceOpacity: -2,
            barContentScale: 8,
            animationScale: 8,
            cornerRadiusScale: 0,
            barHeight: 500,
            barMargin: -4,
            barPanelGap: 80,
            barWidgetSettings: {
                context: { timeout: 50 }
            },
            notificationPopupDuration: 100,
            notificationPopupMaximum: 50,
            osdDuration: 9000,
            osdSize: 3
        })

        compare(state.shellSurfaceOpacity, 0.55)
        compare(state.barSurfaceOpacity, 0)
        compare(state.barContentScale, 1.4)
        compare(state.animationScale, 2)
        compare(state.cornerRadiusScale, 0.6)
        compare(state.barHeight, 80)
        compare(state.barMargin, 0)
        compare(state.barPanelGap, 48)
        compare(state.barWidgetSettings.context.timeout, 1000)
        compare(state.notificationPopupDuration, 3000)
        compare(state.notificationPopupMaximum, 5)
        compare(state.osdDuration, 5000)
        compare(state.osdSize, 1.4)
    }

    function test_barAppearanceValuesUseIndependentBounds() {
        const minimum = ConfigSchema.normalize({
            barHeight: 2,
            barPanelGap: -5,
            barSurfaceOpacity: -1,
            barContentScale: 0.1
        })
        const maximum = ConfigSchema.normalize({
            barHeight: 200,
            barPanelGap: 80,
            barSurfaceOpacity: 5,
            barContentScale: 3
        })

        compare(minimum.barHeight, 40)
        compare(minimum.barPanelGap, 0)
        compare(minimum.barSurfaceOpacity, 0)
        compare(minimum.barContentScale, 0.8)
        compare(maximum.barHeight, 80)
        compare(maximum.barPanelGap, 48)
        compare(maximum.barSurfaceOpacity, 1)
        compare(maximum.barContentScale, 1.4)
    }

    function test_barChoiceNormalization() {
        const valid = ConfigSchema.normalize({
            barSurfaceMode: "floating",
            barBackgroundMode: "frosted",
            barWidgetSettings: {
                context: { mode: "always" },
                "system-status": { layout: "individual" },
                tray: { mode: "inline" },
                datetime: { dateMode: "full" }
            }
        })
        const invalid = ConfigSchema.normalize({
            barSurfaceMode: "detached",
            barBackgroundMode: "blurred",
            barWidgetSettings: {
                context: { mode: "polling" },
                "system-status": { layout: "stacked" },
                tray: { mode: "floating" },
                datetime: { dateMode: "numeric" }
            }
        })
        const translucent = ConfigSchema.normalize({
            barBackgroundMode: "translucent"
        })

        compare(valid.barSurfaceMode, "floating")
        compare(valid.barBackgroundMode, "frosted")
        compare(valid.barWidgetSettings.context.mode, "always")
        compare(
            valid.barWidgetSettings["system-status"].layout,
            "individual"
        )
        compare(valid.barWidgetSettings.tray.mode, "inline")
        compare(valid.barWidgetSettings.datetime.dateMode, "full")
        compare(translucent.barBackgroundMode, "translucent")
        compare(invalid.barSurfaceMode, "edge-to-edge")
        compare(invalid.barBackgroundMode, "solid")
        compare(invalid.barWidgetSettings.context.mode, "contextual")
        compare(
            invalid.barWidgetSettings["system-status"].layout,
            "grouped"
        )
        compare(invalid.barWidgetSettings.tray.mode, "grouped")
        compare(invalid.barWidgetSettings.datetime.dateMode, "short")
    }

    function test_schema6LegacyTranslucentKeepsBlurSemantics() {
        const migrated = ConfigSchema.migrate({
            schemaVersion: 6,
            barBackgroundMode: "translucent"
        })

        compare(migrated.schemaVersion, 9)
        compare(migrated.barBackgroundMode, "blur")
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
                length: 4
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
                "tray"
            ])
        )
    }

    function test_resetCategoryIsScoped() {
        const appearance =
            ConfigSchema.defaultsForCategory("appearance")
        const bar = ConfigSchema.defaultsForCategory("bar")
        const dashboard =
            ConfigSchema.defaultsForCategory("dashboard")

        compare(appearance.themeMode, "auto")
        compare(appearance.paletteStyle, "auto")
        verify(appearance.barHeight === undefined)
        compare(bar.barHeight, 56)
        compare(bar.barPanelGap, 8)
        verify(bar.barVisualStyle === undefined)
        verify(bar.barWidgetOrder === undefined)
        compare(bar.barSurfaceMode, "edge-to-edge")
        compare(bar.barBackgroundMode, "solid")
        compare(bar.barSurfaceOpacity, 0.86)
        compare(bar.barAutoScaleContents, true)
        compare(bar.barContentScale, 1)
        compare(bar.barWidgetSettings.context.mode, "contextual")
        compare(bar.barWidgetSettings.tray.mode, "grouped")
        compare(bar.barShowDashboardButton, true)
        compare(bar.barRightWidgetOrder.length, 4)
        verify(bar.themeMode === undefined)
        compare(dashboard.dashboardUseUserAvatarImage, true)
        compare(dashboard.dashboardUserAvatarPath, "")
        verify(dashboard.barHeight === undefined)
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
            barWidgetSettings: {
                tray: { mode: "inline" },
                "system-status": {
                    audioTextMode: "icon",
                    networkTextMode: "icon"
                }
            },
            dashboardUseUserAvatarImage: false,
            dashboardUserAvatarPath:
                "  file:///tmp/avatar.png  ",
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
        compare(restored.barWidgetSettings.tray.mode, "inline")
        compare(
            restored.barWidgetSettings["system-status"].audioTextMode,
            "icon"
        )
        compare(
            restored.barWidgetSettings["system-status"].networkTextMode,
            "icon"
        )
        compare(restored.dashboardUseUserAvatarImage, false)
        compare(
            restored.dashboardUserAvatarPath,
            "file:///tmp/avatar.png"
        )
        compare(restored.dashboardShowMedia, false)
        compare(
            restored.notificationPopupPosition,
            "bottom-left"
        )
        compare(restored.osdSize, 1.2)
        compare(restored.sessionConfirmPoweroff, false)
    }
}

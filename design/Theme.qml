pragma Singleton

import QtQuick
import qs.stores.config
import "../modules/bar/BarScalePolicy.js" as BarScalePolicy
import "../modules/bar/BarSurfacePolicy.js" as BarSurfacePolicy
import "ThemePalette.js" as ThemePalette

QtObject {
    id: root

    readonly property string resolvedMode:
        ThemePalette.normalizedMode(ConfigStore.themeMode)
    readonly property bool lightMode: resolvedMode === "light"
    readonly property bool automaticMode:
        ConfigStore.themeMode === "auto"
    readonly property real surfaceAlpha:
        ConfigStore.transparencyEnabled
            ? ConfigStore.surfaceOpacity
            : 1
    readonly property real motionScale:
        !ConfigStore.animationsEnabled
            ? 0
            : ConfigStore.reduceMotion
                ? 0.08
                : ConfigStore.animationScale
                    * ConfigStore.behaviorTransitionScale
    readonly property real radiusScale:
        ConfigStore.cornerRadiusScale
    readonly property real barContentScale:
        BarScalePolicy.effectiveScale(
            ConfigStore.barHeight,
            ConfigStore.barAutoScaleContents,
            ConfigStore.barContentScale,
            ConfigStore.compactMode
        )
    readonly property real barSpacingScale: barContentScale
    readonly property real barTypographyScale: barContentScale
    readonly property real barShapeScale:
        barContentScale * radiusScale

    property var dynamicLightPalette: ({})
    property var dynamicDarkPalette: ({})
    property bool dynamicPaletteActive: false

    readonly property var activePalette:
        ThemePalette.activePalette(
            resolvedMode,
            dynamicPaletteActive,
            dynamicLightPalette,
            dynamicDarkPalette
        )
    readonly property color primaryColor: activePalette.primary
    readonly property color onPrimaryColor: activePalette.onPrimary
    readonly property color accentContainerColor:
        activePalette.accentContainer
    readonly property color accentForegroundColor:
        activePalette.onAccentContainer
    readonly property color outlineColor: activePalette.outline
    readonly property color outlineVariantColor:
        activePalette.outlineVariant
    readonly property color surfaceLowestColor:
        activePalette.surfaceLowest
    readonly property color surfaceLowColor:
        activePalette.surfaceLow
    readonly property color surfaceBaseColor:
        activePalette.surfaceBase
    readonly property color surfaceContainerColor:
        activePalette.surfaceContainer
    readonly property color surfaceHighColor:
        activePalette.surfaceHigh
    readonly property color surfaceMutedColor:
        activePalette.surfaceMuted
    readonly property color onSurfaceColor:
        activePalette.onSurface
    readonly property color textMutedColor:
        activePalette.textMuted
    readonly property color scrimColor: activePalette.scrim

    function withAlpha(colorValue, opacityValue) {
        return Qt.rgba(
            colorValue.r,
            colorValue.g,
            colorValue.b,
            opacityValue
        )
    }

    function applyDynamicPalettes(lightPalette, darkPalette) {
        if (!ThemePalette.complete(lightPalette)
            || !ThemePalette.complete(darkPalette)) {
            resetPalette()
            return
        }

        dynamicLightPalette = lightPalette
        dynamicDarkPalette = darkPalette
        dynamicPaletteActive = true
    }

    function resetPalette() {
        dynamicLightPalette = ({})
        dynamicDarkPalette = ({})
        dynamicPaletteActive = false
    }

    function previewPalette(mode) {
        return ThemePalette.basePalette(mode)
    }

    readonly property var luminaTokens: ({
        color: {
            surfaceLowest: root.withAlpha(
                root.surfaceLowestColor,
                root.surfaceAlpha
            ),
            surfaceLow: root.withAlpha(
                root.surfaceLowColor,
                root.surfaceAlpha
            ),
            surfaceBase: root.withAlpha(
                root.surfaceBaseColor,
                root.surfaceAlpha
            ),
            surfaceContainer: root.withAlpha(
                root.surfaceContainerColor,
                root.surfaceAlpha
            ),
            surfaceHigh: root.withAlpha(
                root.surfaceHighColor,
                Math.max(0.84, root.surfaceAlpha)
            ),
            surfaceMuted: root.withAlpha(
                root.surfaceMutedColor,
                Math.max(0.78, root.surfaceAlpha)
            ),
            scrim: root.withAlpha(
                root.scrimColor,
                root.lightMode ? 0.48 : 0.70
            ),
            onSurface: root.onSurfaceColor,
            textMuted: root.textMutedColor,
            primary: root.primaryColor,
            onPrimary: root.onPrimaryColor,
            accentContainer: root.accentContainerColor,
            onAccentContainer: root.accentForegroundColor,
            outline: root.outlineColor,
            outlineVariant: root.outlineVariantColor,
            divider: root.lightMode
                ? root.withAlpha(root.outlineVariantColor, 0.64)
                : root.withAlpha(root.outlineColor, 0.24),
            urgent: root.activePalette.urgent,
            errorContainer: root.activePalette.errorContainer,
            onErrorContainer: root.activePalette.onErrorContainer,
            hoverState: root.withAlpha(
                root.onSurfaceColor,
                0.08
            ),
            pressedState: root.withAlpha(
                root.onSurfaceColor,
                0.12
            ),
            barSolidBackground: root.surfaceContainerColor,
            barTranslucentBackground: root.surfaceContainerColor,
            barBlurTint: root.surfaceContainerColor,
            barBlurContrastProtection: root.surfaceBaseColor,
            barFrostedTint: root.surfaceMutedColor,
            barFrostedHighlight: root.lightMode
                ? root.surfaceBaseColor
                : root.onSurfaceColor
        },
        effect: {
            barBackgroundAlpha:
                BarSurfacePolicy.backgroundAlpha(
                    ConfigStore.barBackgroundMode,
                    ConfigStore.barSurfaceOpacity
                ),
            barTintAlpha:
                BarSurfacePolicy.tintAlpha(
                    ConfigStore.barBackgroundMode,
                    ConfigStore.barSurfaceOpacity,
                    root.lightMode
                ),
            barContrastProtectionAlpha:
                BarSurfacePolicy.contrastProtectionAlpha(
                    ConfigStore.barBackgroundMode,
                    ConfigStore.barSurfaceOpacity,
                    root.lightMode
                ),
            barBlurFallbackAlpha:
                BarSurfacePolicy.fallbackAlpha(
                    "blur",
                    ConfigStore.barSurfaceOpacity,
                    root.lightMode
                ),
            barFrostedFallbackAlpha:
                BarSurfacePolicy.fallbackAlpha(
                    "frosted",
                    ConfigStore.barSurfaceOpacity,
                    root.lightMode
                ),
            barFrostedHighlightAlpha:
                BarSurfacePolicy.frostedHighlightAlpha(
                    ConfigStore.barBackgroundMode,
                    ConfigStore.barSurfaceOpacity,
                    root.lightMode
                ),
            barFrostedGrainAlpha:
                BarSurfacePolicy.frostedGrainAlpha(
                    ConfigStore.barBackgroundMode,
                    ConfigStore.barSurfaceOpacity,
                    root.lightMode
                ),
            barDividerAlpha:
                BarSurfacePolicy.dividerAlpha(
                    ConfigStore.barBackgroundMode,
                    ConfigStore.barSurfaceOpacity
                ),
            barBorderAlpha:
                BarSurfacePolicy.borderAlpha(
                    ConfigStore.barBackgroundMode,
                    ConfigStore.barSurfaceOpacity
                )
        },
        shape: {
            none: 0,
            extraSmall: Math.round(4 * root.radiusScale),
            small: Math.round(8 * root.radiusScale),
            medium: Math.round(16 * root.radiusScale),
            controlIconActivated:
                Math.round(14 * root.radiusScale),
            large: Math.round(24 * root.radiusScale),
            largeIncreased: Math.round(28 * root.radiusScale),
            extraLarge: Math.round(32 * root.radiusScale),
            extraLargeIncreased: Math.round(40 * root.radiusScale),
            extraExtraLarge: Math.round(48 * root.radiusScale),
            barSmall: BarScalePolicy.scaled(
                8,
                root.barShapeScale,
                4,
                12
            ),
            barMedium: BarScalePolicy.scaled(
                16,
                root.barShapeScale,
                8,
                24
            ),
            barIconActivated: BarScalePolicy.scaled(
                12,
                root.barShapeScale,
                6,
                18
            ),
            barLarge: BarScalePolicy.scaled(
                24,
                root.barShapeScale,
                12,
                36
            ),
            workspaceResting: Math.round(12 * root.radiusScale),
            workspaceActive: 999,
            full: 999
        },
        spacing: {
            extraSmall: 4,
            small: ConfigStore.compactMode ? 4 : 6,
            medium: ConfigStore.compactMode ? 8 : 10,
            large: ConfigStore.compactMode ? 11 : 14,
            extraLarge: ConfigStore.compactMode ? 14 : 18,
            barItemGap: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 4 : 6,
                root.barSpacingScale,
                2,
                9
            ),
            barClusterGap: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 12 : 18,
                root.barSpacingScale,
                8,
                26
            ),
            barContentInset: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 12 : 18,
                root.barSpacingScale,
                8,
                26
            ),
            barHorizontalPadding: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 12 : 16,
                root.barSpacingScale,
                7,
                23
            ),
            barWidgetPadding: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 8 : 10,
                root.barSpacingScale,
                5,
                15
            ),
            barConfiguredWidgetGap: BarScalePolicy.scaled(
                ConfigStore.barWidgetSpacing,
                root.barSpacingScale,
                2,
                35
            ),
            barPanelGap: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 10 : 14,
                root.barSpacingScale,
                7,
                20
            ),
            controlItemGap: ConfigStore.compactMode ? 10 : 14,
            controlCardGap: ConfigStore.compactMode ? 12 : 18,
            controlSectionGap: ConfigStore.compactMode ? 14 : 20,
            controlContentInset: ConfigStore.compactMode ? 16 : 22
        },
        size: {
            barHeight: ConfigStore.barHeight,
            barWindowHeight: ConfigStore.barHeight
                + (
                    ConfigStore.barSurfaceMode === "floating"
                        ? ConfigStore.barMargin * 2
                        : 0
                ),
            expressiveBarHeight: 56,
            barContentScale: root.barContentScale,
            barTouchTarget: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 38 : 40,
                root.barContentScale,
                30,
                57
            ),
            barIcon: BarScalePolicy.scaled(
                18,
                root.barContentScale,
                12,
                26
            ),
            barNotificationIcon: BarScalePolicy.scaled(
                22,
                root.barContentScale,
                15,
                32
            ),
            barSmallIcon: BarScalePolicy.scaled(
                16,
                root.barContentScale,
                11,
                23
            ),
            barTrayIcon: BarScalePolicy.scaled(
                18,
                root.barContentScale,
                12,
                26
            ),
            barWorkspaceMarker: BarScalePolicy.scaled(
                10,
                root.barContentScale,
                7,
                15
            ),
            barWorkspaceActiveHeight: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 34 : 38,
                root.barContentScale,
                25,
                54
            ),
            barStatusIcon: BarScalePolicy.scaled(
                17,
                root.barContentScale,
                11,
                25
            ),
            barBadgeHeight: BarScalePolicy.scaled(
                17,
                root.barContentScale,
                11,
                24
            ),
            barBadgePadding: BarScalePolicy.scaled(
                7,
                root.barSpacingScale,
                4,
                10
            ),
            barStatusDot: BarScalePolicy.scaled(
                8,
                root.barContentScale,
                5,
                12
            ),
            barDividerDot: BarScalePolicy.scaled(
                3,
                root.barContentScale,
                2,
                4
            ),
            calendarWidth: 336,
            chipHeight: ConfigStore.compactMode ? 28 : 30,
            controlCenterHeight: 920,
            controlCenterWidth: 1440,
            controlDashboardMinimumHeight: 752,
            controlDashboardMinimumWidth: 1280,
            dayCell: 40,
            launcherHeight: 620,
            launcherIcon: 34,
            launcherRowHeight: 58,
            launcherWidth: 680,
            notificationCenterEmptyHeight: 300,
            notificationCenterMaxHeight: 720,
            notificationCenterWidth: 420,
            notificationIcon: 38,
            notificationWidth: 390,
            sessionMenuHeight: 620,
            sessionMenuWidth: 720,
            settingsMenuItemHeight: 42,
            statusDot: 8,
            trayIcon: 18,
            wallpaperPickerHeight: 650,
            wallpaperPickerWidth: 780
        },
        typography: {
            labelSmall: 10,
            labelMedium: 12,
            bodyMedium: 13,
            barClock: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 14 : 15,
                root.barTypographyScale,
                10,
                22
            ),
            barSecondary: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 11 : 12,
                root.barTypographyScale,
                8,
                17
            ),
            barWorkspace: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 11 : 12,
                root.barTypographyScale,
                8,
                17
            ),
            barContextPrimary: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 12 : 13,
                root.barTypographyScale,
                9,
                19
            ),
            barContextSecondary: BarScalePolicy.scaled(
                ConfigStore.compactMode ? 10 : 11,
                root.barTypographyScale,
                8,
                16
            ),
            barBadge: BarScalePolicy.scaled(
                10,
                root.barTypographyScale,
                7,
                14
            ),
            titleMedium: 14,
            titleLarge: 20
        },
        progress: {
            trackThickness: 4,
            waveAmplitude: 3,
            waveLength: 40,
            waveHeight: 10,
            trackGap: 4,
            stopSize: 4
        },
        slider: {
            trackHeight: 16,
            handleWidth: 6,
            handleHeight: 28,
            handleGap: 6,
            trackInsideRadius: 2,
            stopSize: 4,
            stateLayerSize: 32
        },
        motion: {
            fast: Math.max(1, Math.round(120 * root.motionScale)),
            medium: Math.max(1, Math.round(220 * root.motionScale)),
            slow: Math.max(1, Math.round(380 * root.motionScale)),
            effectsFast:
                Math.max(1, Math.round(100 * root.motionScale)),
            effectsDefault:
                Math.max(1, Math.round(180 * root.motionScale)),
            effectsSlow:
                Math.max(1, Math.round(300 * root.motionScale)),
            spatialFast:
                Math.max(1, Math.round(180 * root.motionScale)),
            spatialDefault:
                Math.max(1, Math.round(300 * root.motionScale)),
            spatialSlow:
                Math.max(1, Math.round(450 * root.motionScale)),
            press:
                Math.max(1, Math.round(90 * root.motionScale)),
            pageTransition:
                Math.max(1, Math.round(360 * root.motionScale)),
            workspaceTransform:
                Math.max(1, Math.round(300 * root.motionScale)),
            mediaProgressMorph:
                Math.max(1, Math.round(420 * root.motionScale)),
            mediaWaveCycle:
                Math.max(1, Math.round(1600 * root.motionScale)),
            effectsEasing: Easing.OutCubic,
            continuousEasing: Easing.InOutCubic,
            spatialEasing: ConfigStore.reduceMotion
                || !ConfigStore.animationsEnabled
                    ? Easing.OutCubic
                    : Easing.OutBack,
            spatialOvershoot: ConfigStore.reduceMotion
                || !ConfigStore.animationsEnabled
                    ? 0
                    : 0.55
        }
    })
}

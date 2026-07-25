pragma Singleton

import QtQuick
import qs.stores.config

QtObject {
    id: root

    readonly property bool lightMode: ConfigStore.themeMode === "light"
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

    property color primaryColor: lightMode ? "#305EA8" : "#ADC6FF"
    property color accentContainerColor:
        lightMode ? "#D7E3FF" : "#294777"
    property color accentForegroundColor:
        lightMode ? "#102F5C" : "#D7E3FF"
    property color outlineColor:
        lightMode ? "#74777F" : "#8E9099"
    property color surfaceBaseColor:
        lightMode ? "#F8F9FF" : "#111318"
    property color surfaceContainerColor:
        lightMode ? "#EFF0F7" : "#1D2026"
    property color surfaceMutedColor:
        lightMode ? "#E2E3EA" : "#292C33"
    property color onSurfaceColor:
        lightMode ? "#1A1B20" : "#E2E2E9"
    property color textMutedColor:
        lightMode ? "#44474F" : "#C3C6CF"
    property bool dynamicPaletteActive: false

    function withAlpha(colorValue, opacityValue) {
        return Qt.rgba(
            colorValue.r,
            colorValue.g,
            colorValue.b,
            opacityValue
        )
    }

    function applyDynamicPalette(
        primary,
        accentContainer,
        outline,
        neutral
    ) {
        primaryColor = primary
        accentContainerColor = accentContainer
        accentForegroundColor = lightMode ? "#102030" : "#F4F7FF"
        outlineColor = outline

        if (neutral) {
            surfaceBaseColor = neutral.surfaceBase
            surfaceContainerColor = neutral.surfaceContainer
            surfaceMutedColor = neutral.surfaceMuted
            onSurfaceColor = neutral.onSurface
            textMutedColor = neutral.textMuted
        }

        dynamicPaletteActive = true
    }

    function resetPalette() {
        primaryColor = lightMode ? "#305EA8" : "#ADC6FF"
        accentContainerColor = lightMode ? "#D7E3FF" : "#294777"
        accentForegroundColor = lightMode ? "#102F5C" : "#D7E3FF"
        outlineColor = lightMode ? "#74777F" : "#8E9099"
        surfaceBaseColor = lightMode ? "#F8F9FF" : "#111318"
        surfaceContainerColor = lightMode ? "#EFF0F7" : "#1D2026"
        surfaceMutedColor = lightMode ? "#E2E3EA" : "#292C33"
        onSurfaceColor = lightMode ? "#1A1B20" : "#E2E2E9"
        textMutedColor = lightMode ? "#44474F" : "#C3C6CF"
        dynamicPaletteActive = false
    }

    onLightModeChanged: {
        if (!dynamicPaletteActive)
            resetPalette()
    }

    readonly property var luminaTokens: ({
        color: {
            surfaceBase: root.withAlpha(
                root.surfaceBaseColor,
                root.surfaceAlpha
            ),
            surfaceContainer: root.withAlpha(
                root.surfaceContainerColor,
                root.surfaceAlpha
            ),
            surfaceMuted: root.withAlpha(
                root.surfaceMutedColor,
                Math.max(0.78, root.surfaceAlpha)
            ),
            scrim: root.lightMode ? "#8F111318" : "#B3111318",
            onSurface: root.onSurfaceColor,
            textMuted: root.textMutedColor,
            primary: root.primaryColor,
            accentContainer: root.accentContainerColor,
            onAccentContainer: root.accentForegroundColor,
            outline: root.outlineColor,
            divider: root.withAlpha(
                root.outlineColor,
                root.lightMode ? 0.18 : 0.24
            ),
            urgent: root.lightMode ? "#BA1A1A" : "#FFB4AB"
        },
        shape: {
            none: 0,
            extraSmall: Math.round(4 * root.radiusScale),
            small: Math.round(8 * root.radiusScale),
            medium: Math.round(16 * root.radiusScale),
            large: Math.round(24 * root.radiusScale),
            largeIncreased: Math.round(28 * root.radiusScale),
            extraLarge: Math.round(32 * root.radiusScale),
            extraLargeIncreased: Math.round(40 * root.radiusScale),
            extraExtraLarge: Math.round(48 * root.radiusScale),
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
            barItemGap: ConfigStore.compactMode ? 4 : 6,
            barClusterGap: ConfigStore.compactMode ? 12 : 18,
            barContentInset: ConfigStore.compactMode ? 12 : 18,
            barPanelGap: ConfigStore.compactMode ? 10 : 14,
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
            barTouchTarget: ConfigStore.compactMode ? 36 : 40,
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
            statusDot: 8,
            trayIcon: 18,
            wallpaperPickerHeight: 650,
            wallpaperPickerWidth: 780
        },
        typography: {
            labelSmall: 10,
            labelMedium: 12,
            bodyMedium: 13,
            barClock: ConfigStore.compactMode ? 14 : 15,
            barSecondary: 12,
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

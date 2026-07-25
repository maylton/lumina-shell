pragma Singleton

import QtQuick

QtObject {
    id: root

    property color primaryColor: "#ADC6FF"
    property color accentContainerColor: "#294777"
    property color accentForegroundColor: "#D7E3FF"
    property color outlineColor: "#8E9099"
    property bool dynamicPaletteActive: false

    function applyDynamicPalette(primary, accentContainer, outline) {
        primaryColor = primary
        accentContainerColor = accentContainer
        accentForegroundColor = "#F4F7FF"
        outlineColor = outline
        dynamicPaletteActive = true
    }

    function resetPalette() {
        primaryColor = "#ADC6FF"
        accentContainerColor = "#294777"
        accentForegroundColor = "#D7E3FF"
        outlineColor = "#8E9099"
        dynamicPaletteActive = false
    }

    readonly property var luminaTokens: ({
        color: {
            surfaceBase: "#111318",
            surfaceContainer: "#1D2026",
            surfaceMuted: "#292C33",
            scrim: "#B3111318",
            onSurface: "#E2E2E9",
            textMuted: "#C3C6CF",
            primary: root.primaryColor,
            accentContainer: root.accentContainerColor,
            onAccentContainer: root.accentForegroundColor,
            outline: root.outlineColor,
            urgent: "#FFB4AB"
        },
        shape: {
            small: 10,
            medium: 14,
            large: 22,
            extraLarge: 30,
            full: 999
        },
        spacing: {
            extraSmall: 4,
            small: 6,
            medium: 10,
            large: 14,
            extraLarge: 18
        },
        size: {
            barHeight: 48,
            calendarWidth: 336,
            chipHeight: 30,
            controlCenterHeight: 900,
            controlCenterWidth: 1480,
            dayCell: 40,
            launcherHeight: 620,
            launcherIcon: 34,
            launcherRowHeight: 58,
            launcherWidth: 680,
            notificationCenterWidth: 430,
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
            titleMedium: 14,
            titleLarge: 20
        },
        motion: {
            fast: 120,
            medium: 220,
            slow: 380
        }
    })
}

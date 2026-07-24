pragma Singleton

import QtQml

QtObject {
    readonly property var luminaTokens: ({
        color: {
            surfaceBase: "#111318",
            surfaceContainer: "#1D2026",
            surfaceMuted: "#292C33",
            scrim: "#B3111318",
            onSurface: "#E2E2E9",
            textMuted: "#C3C6CF",
            primary: "#ADC6FF",
            accentContainer: "#294777",
            onAccentContainer: "#D7E3FF",
            outline: "#8E9099",
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
            dayCell: 40,
            launcherHeight: 620,
            launcherIcon: 34,
            launcherRowHeight: 58,
            launcherWidth: 680,
            statusDot: 8,
            trayIcon: 18
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

pragma Singleton

import QtQml

QtObject {
    readonly property var luminaTokens: ({
        color: {
            surfaceBase: "#111318",
            surfaceContainer: "#1D2026",
            surfaceMuted: "#292C33",
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
            statusDot: 8
        },
        typography: {
            labelSmall: 10,
            labelMedium: 12,
            bodyMedium: 13,
            titleMedium: 14
        },
        motion: {
            fast: 120,
            medium: 220,
            slow: 380
        }
    })
}

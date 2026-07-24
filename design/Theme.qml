pragma Singleton

import QtQml

QtObject {
    readonly property var luminaColors: ({
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
    })

    readonly property var luminaMetrics: ({
        barHeight: 48,
        radiusSmall: 10,
        radiusMedium: 14,
        radiusLarge: 22,
        spacingSmall: 6,
        spacingMedium: 10,
        spacingLarge: 14
    })
}

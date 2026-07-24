pragma Singleton

import QtQuick

QtObject {
    readonly property color surfaceBaseColor: "#111318"
    readonly property color surfaceContainerColor: "#1D2026"
    readonly property color surfaceMutedColor: "#292C33"
    readonly property color onSurfaceColor: "#E2E2E9"
    readonly property color textMutedColor: "#C3C6CF"
    readonly property color primaryColor: "#ADC6FF"
    readonly property color accentContainerColor: "#294777"
    readonly property color onAccentContainerColor: "#D7E3FF"
    readonly property color outlineColor: "#8E9099"
    readonly property color urgentColor: "#FFB4AB"

    readonly property int barHeight: 48
    readonly property int radiusSmall: 10
    readonly property int radiusMedium: 14
    readonly property int radiusLarge: 22
    readonly property int spacingSmall: 6
    readonly property int spacingMedium: 10
    readonly property int spacingLarge: 14
}

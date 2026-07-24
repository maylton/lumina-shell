pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property color surfaceBase: "#111318"
    readonly property color surfaceContainer: "#1D2026"
    readonly property color surfaceMuted: "#292C33"
    readonly property color onSurface: "#E2E2E9"
    readonly property color textMuted: "#C3C6CF"
    readonly property color primary: "#ADC6FF"
    readonly property color accentContainer: "#294777"
    readonly property color onAccentContainer: "#D7E3FF"
    readonly property color outline: "#8E9099"
    readonly property color urgent: "#FFB4AB"

    readonly property int barHeight: 48
    readonly property int radiusSmall: 10
    readonly property int radiusMedium: 14
    readonly property int radiusLarge: 22
    readonly property int spacingSmall: 6
    readonly property int spacingMedium: 10
    readonly property int spacingLarge: 14
}

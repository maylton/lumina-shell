.pragma library

function normalizedMode(mode) {
    return String(mode || "") === "light" ? "light" : "dark"
}

function darkPalette() {
    return {
        mode: "dark",
        primary: "#ADC6FF",
        onPrimary: "#0B305F",
        accentContainer: "#294777",
        onAccentContainer: "#D7E3FF",
        surfaceLowest: "#0C0E13",
        surfaceLow: "#171A20",
        surfaceBase: "#111318",
        surfaceContainer: "#1D2026",
        surfaceHigh: "#23262C",
        surfaceMuted: "#292C33",
        onSurface: "#E2E2E9",
        textMuted: "#C3C6CF",
        outline: "#8E9099",
        outlineVariant: "#44474F",
        urgent: "#FFB4AB",
        errorContainer: "#3A171B",
        onErrorContainer: "#FFDAD6",
        scrim: "#111318"
    }
}

function lightPalette() {
    return {
        mode: "light",
        primary: "#305EA8",
        onPrimary: "#FFFFFF",
        accentContainer: "#D7E3FF",
        onAccentContainer: "#102F5C",
        surfaceLowest: "#FFFFFF",
        surfaceLow: "#F3F3FA",
        surfaceBase: "#F9F9FF",
        surfaceContainer: "#EDEEF5",
        surfaceHigh: "#E7E8EF",
        surfaceMuted: "#E2E3EA",
        onSurface: "#1A1B20",
        textMuted: "#44474F",
        outline: "#74777F",
        outlineVariant: "#C4C6D0",
        urgent: "#BA1A1A",
        errorContainer: "#FFDAD6",
        onErrorContainer: "#410002",
        scrim: "#000000"
    }
}

function basePalette(mode) {
    return normalizedMode(mode) === "light"
        ? lightPalette()
        : darkPalette()
}

function complete(palette) {
    if (!palette || typeof palette !== "object")
        return false

    const required = [
        "primary",
        "onPrimary",
        "accentContainer",
        "onAccentContainer",
        "surfaceLowest",
        "surfaceLow",
        "surfaceBase",
        "surfaceContainer",
        "surfaceHigh",
        "surfaceMuted",
        "onSurface",
        "textMuted",
        "outline",
        "outlineVariant",
        "urgent",
        "errorContainer",
        "onErrorContainer",
        "scrim"
    ]

    for (var index = 0; index < required.length; ++index) {
        if (palette[required[index]] === undefined)
            return false
    }

    return true
}

function activePalette(
    mode,
    dynamicPaletteActive,
    dynamicLightPalette,
    dynamicDarkPalette
) {
    const resolvedMode = normalizedMode(mode)
    const dynamicPalette = resolvedMode === "light"
        ? dynamicLightPalette
        : dynamicDarkPalette

    return dynamicPaletteActive && complete(dynamicPalette)
        ? dynamicPalette
        : basePalette(resolvedMode)
}

function rgbFromHex(color) {
    const value = String(color || "").replace("#", "")

    if (value.length !== 6)
        return null

    return {
        r: parseInt(value.slice(0, 2), 16) / 255,
        g: parseInt(value.slice(2, 4), 16) / 255,
        b: parseInt(value.slice(4, 6), 16) / 255
    }
}

function linearChannel(channel) {
    return channel <= 0.04045
        ? channel / 12.92
        : Math.pow((channel + 0.055) / 1.055, 2.4)
}

function relativeLuminance(color) {
    const rgb = rgbFromHex(color)

    if (!rgb)
        return 0

    return linearChannel(rgb.r) * 0.2126
        + linearChannel(rgb.g) * 0.7152
        + linearChannel(rgb.b) * 0.0722
}

function contrastRatio(foreground, background) {
    const foregroundLuminance = relativeLuminance(foreground)
    const backgroundLuminance = relativeLuminance(background)
    const lighter = Math.max(
        foregroundLuminance,
        backgroundLuminance
    )
    const darker = Math.min(
        foregroundLuminance,
        backgroundLuminance
    )

    return (lighter + 0.05) / (darker + 0.05)
}

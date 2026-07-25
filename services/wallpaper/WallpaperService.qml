pragma Singleton

import QtQuick
import Quickshell
import qs.design
import qs.stores.config
import qs.stores.niri
import qs.stores.shell

Singleton {
    id: root

    readonly property bool dynamicThemeEnabled: ConfigStore.dynamicTheme
    readonly property string paletteStyle: ConfigStore.paletteStyle
    readonly property string wallpaperDirectory: ConfigStore.wallpaperDirectory
    readonly property var wallpapers: ConfigStore.wallpapers
    readonly property string defaultWallpaper: ConfigStore.defaultWallpaper
    readonly property string themeOutputName: focusedOutputName()
    readonly property string themeWallpaper: wallpaperFor(themeOutputName)
    readonly property string themeSource: urlForPath(themeWallpaper)
    readonly property string pickerOutputName:
        OverlayStore.activeSurface === "wallpaper"
            ? OverlayStore.activeOutputName
            : ""

    function cloneMap(source) {
        const result = {}

        if (!source || typeof source !== "object")
            return result

        for (const key in source)
            result[key] = source[key]

        return result
    }

    function focusedOutputName() {
        const workspaces = WorkspaceStore.workspaces || []

        for (var i = 0; i < workspaces.length; ++i) {
            if (workspaces[i].is_focused
                && workspaces[i].output
                && outputExists(workspaces[i].output)) {
                return String(workspaces[i].output)
            }
        }

        const screens = Quickshell.screens || []

        return screens.length > 0 ? String(screens[0].name || "") : ""
    }

    function outputExists(outputName) {
        const name = String(outputName || "")
        const screens = Quickshell.screens || []

        for (var i = 0; i < screens.length; ++i) {
            if (String(screens[i].name || "") === name)
                return true
        }

        return false
    }

    function resolvedOutputName(outputName) {
        const requested = String(outputName || "")

        return outputExists(requested) ? requested : focusedOutputName()
    }

    function urlForPath(path) {
        const value = String(path || "")

        if (!value)
            return ""

        if (value.indexOf("file:") === 0
            || value.indexOf("qrc:") === 0
            || value.indexOf("http:") === 0
            || value.indexOf("https:") === 0) {
            return value
        }

        return encodeURI("file://" + value)
    }

    function wallpaperFor(outputName) {
        const name = String(outputName || "")
        const map = ConfigStore.wallpapers || {}

        if (name && map[name])
            return String(map[name])

        return String(ConfigStore.defaultWallpaper || "")
    }

    function setWallpaper(outputName, path) {
        const name = resolvedOutputName(outputName)
        const value = String(path || "")

        if (!name || !value)
            return

        const next = cloneMap(ConfigStore.wallpapers)

        next[name] = value
        ConfigStore.setWallpapers(next)
        closePicker()
    }

    function setDefaultWallpaper(path) {
        const value = String(path || "")

        if (value)
            ConfigStore.setDefaultWallpaper(value)
    }

    function setWallpaperDirectory(path) {
        const value = String(path || "")

        if (value)
            ConfigStore.setWallpaperDirectory(value)
    }

    function openPicker(outputName) {
        OverlayStore.openFor(
            "wallpaper",
            resolvedOutputName(outputName)
        )
    }

    function closePicker() {
        OverlayStore.close("wallpaper")
    }

    function togglePicker(outputName) {
        const targetOutput = resolvedOutputName(outputName)

        if (pickerOutputName === targetOutput)
            closePicker()
        else
            openPicker(targetOutput)
    }

    function colorSaturation(color) {
        const maximum = Math.max(color.r, color.g, color.b)
        const minimum = Math.min(color.r, color.g, color.b)

        return maximum - minimum
    }

    function colorLuminance(color) {
        return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
    }

    function linearColorChannel(channel) {
        return channel <= 0.04045
            ? channel / 12.92
            : Math.pow((channel + 0.055) / 1.055, 2.4)
    }

    function relativeColorLuminance(color) {
        return linearColorChannel(color.r) * 0.2126
            + linearColorChannel(color.g) * 0.7152
            + linearColorChannel(color.b) * 0.0722
    }

    function colorContrast(first, second) {
        const firstLuminance = relativeColorLuminance(first)
        const secondLuminance = relativeColorLuminance(second)
        const lighter = Math.max(firstLuminance, secondLuminance)
        const darker = Math.min(firstLuminance, secondLuminance)

        return (lighter + 0.05) / (darker + 0.05)
    }

    function contrastColor(
        hue,
        saturation,
        initialLightness,
        background,
        target,
        lighten
    ) {
        var lightness = initialLightness
        var candidate = colorTone(hue, saturation, lightness)

        for (var index = 0;
            index < 48
                && colorContrast(candidate, background) < target;
            ++index) {
            lightness = clamped(
                lightness + (lighten ? 0.015 : -0.015),
                0.03,
                0.99
            )
            candidate = colorTone(hue, saturation, lightness)
        }

        return candidate
    }

    function chooseAccent(colors) {
        if (!colors || colors.length === 0)
            return null

        var selected = colors[0]
        var selectedScore = -1

        for (var i = 0; i < colors.length; ++i) {
            const color = colors[i]
            const saturation = colorSaturation(color)
            const luminance = colorLuminance(color)
            const middleTone = 1 - Math.abs(luminance - 0.5)
            const score = saturation * 2 + middleTone

            if (score > selectedScore) {
                selected = color
                selectedScore = score
            }
        }

        return selected
    }

    function normalizedHue(hue) {
        const value = Number(hue)

        if (!isFinite(value) || value < 0)
            return 0.58

        return ((value % 1) + 1) % 1
    }

    function clamped(value, minimum, maximum) {
        return Math.max(minimum, Math.min(maximum, Number(value)))
    }

    function colorTone(hue, saturation, lightness) {
        return Qt.hsla(
            normalizedHue(hue),
            clamped(saturation, 0, 1),
            clamped(lightness, 0, 1),
            1
        )
    }

    function resolvedPaletteStyle(style, sourceColor) {
        const requested = String(style || "auto")

        if (requested !== "auto")
            return requested

        const saturation = sourceColor
            ? Number(sourceColor.hslSaturation)
            : 0

        if (saturation < 0.18)
            return "content"

        if (saturation < 0.48)
            return "neutral"

        return "tonal-spot"
    }

    function paletteFor(style, sourceColor, mode) {
        const source = sourceColor || Qt.color("#4F83CC")
        const sourceHue = normalizedHue(source.hslHue)
        const sourceSaturation = clamped(
            source.hslSaturation < 0 ? 0 : source.hslSaturation,
            0,
            1
        )
        const selected = resolvedPaletteStyle(style, source)
        var primaryHue = sourceHue
        var containerHue = sourceHue
        var primarySaturation = 0.5
        var containerSaturation = 0.32
        var neutralSaturation = 0.06
        var neutralVariantSaturation = 0.12

        if (selected === "content") {
            primarySaturation = clamped(sourceSaturation, 0.32, 0.82)
            containerSaturation = primarySaturation * 0.58
            neutralSaturation = clamped(
                sourceSaturation * 0.1,
                0.03,
                0.09
            )
            neutralVariantSaturation = clamped(
                sourceSaturation * 0.18,
                0.07,
                0.15
            )
        } else if (selected === "expressive") {
            primaryHue += 0.16
            containerHue -= 0.12
            primarySaturation = 0.74
            containerSaturation = 0.52
            neutralSaturation = 0.08
            neutralVariantSaturation = 0.15
        } else if (selected === "fidelity") {
            primarySaturation = sourceSaturation
            containerSaturation = sourceSaturation * 0.72
            neutralSaturation = clamped(
                sourceSaturation * 0.14,
                0.02,
                0.12
            )
            neutralVariantSaturation = clamped(
                sourceSaturation * 0.22,
                0.06,
                0.18
            )
        } else if (selected === "fruit-salad") {
            primaryHue -= 0.12
            containerHue += 0.1
            primarySaturation = 0.72
            containerSaturation = 0.56
            neutralSaturation = 0.09
            neutralVariantSaturation = 0.16
        } else if (selected === "monochrome") {
            primarySaturation = 0
            containerSaturation = 0
            neutralSaturation = 0
            neutralVariantSaturation = 0
        } else if (selected === "neutral") {
            primarySaturation = 0.16
            containerSaturation = 0.1
            neutralSaturation = 0.025
            neutralVariantSaturation = 0.055
        } else if (selected === "rainbow") {
            primaryHue += 0.24
            containerHue -= 0.18
            primarySaturation = 0.78
            containerSaturation = 0.64
            neutralSaturation = 0.1
            neutralVariantSaturation = 0.18
        } else {
            primarySaturation = 0.52
            containerSaturation = 0.34
            neutralSaturation = 0.06
            neutralVariantSaturation = 0.12
        }

        const darkMode = String(mode || "dark") !== "light"
        const surfaceLowest = colorTone(
            sourceHue,
            neutralSaturation,
            darkMode ? 0.04 : 1
        )
        const surfaceLow = colorTone(
            sourceHue,
            neutralSaturation,
            darkMode ? 0.10 : 0.965
        )
        const surfaceBase = colorTone(
            sourceHue,
            neutralSaturation,
            darkMode ? 0.075 : 0.985
        )
        const surfaceContainer = colorTone(
            sourceHue,
            neutralSaturation,
            darkMode ? 0.125 : 0.94
        )
        const surfaceHigh = colorTone(
            sourceHue,
            neutralVariantSaturation,
            darkMode ? 0.155 : 0.91
        )
        const surfaceMuted = colorTone(
            sourceHue,
            neutralVariantSaturation,
            darkMode ? 0.19 : 0.87
        )
        const primary = contrastColor(
            primaryHue,
            primarySaturation,
            darkMode ? 0.76 : 0.38,
            surfaceBase,
            4.5,
            darkMode
        )
        const accentContainer = colorTone(
            containerHue,
            containerSaturation,
            darkMode ? 0.29 : 0.88
        )

        return {
            mode: darkMode ? "dark" : "light",
            style: selected,
            primary: primary,
            onPrimary: contrastColor(
                primaryHue,
                primarySaturation,
                darkMode ? 0.16 : 0.99,
                primary,
                4.5,
                !darkMode
            ),
            accentContainer: accentContainer,
            onAccentContainer: contrastColor(
                containerHue,
                containerSaturation * 0.82,
                darkMode ? 0.91 : 0.18,
                accentContainer,
                4.5,
                darkMode
            ),
            outline: colorTone(
                sourceHue,
                neutralVariantSaturation,
                darkMode ? 0.62 : 0.48
            ),
            outlineVariant: colorTone(
                sourceHue,
                neutralVariantSaturation,
                darkMode ? 0.32 : 0.79
            ),
            surfaceLowest: surfaceLowest,
            surfaceLow: surfaceLow,
            surfaceBase: surfaceBase,
            surfaceContainer: surfaceContainer,
            surfaceHigh: surfaceHigh,
            surfaceMuted: surfaceMuted,
            onSurface: colorTone(
                sourceHue,
                neutralSaturation * 0.55,
                darkMode ? 0.9 : 0.1
            ),
            textMuted: colorTone(
                sourceHue,
                neutralVariantSaturation * 0.6,
                darkMode ? 0.74 : 0.32
            ),
            urgent: Qt.color(darkMode ? "#FFB4AB" : "#BA1A1A"),
            errorContainer:
                Qt.color(darkMode ? "#3A171B" : "#FFDAD6"),
            onErrorContainer:
                Qt.color(darkMode ? "#FFDAD6" : "#410002"),
            scrim: Qt.color(darkMode ? "#111318" : "#000000")
        }
    }

    function previewColors(style) {
        const source = chooseAccent(wallpaperColors.colors)
            || Qt.color("#4F83CC")
        const palette = paletteFor(
            style,
            source,
            Theme.resolvedMode
        )

        return [
            palette.primary,
            palette.accentContainer,
            palette.surfaceMuted,
            palette.outline
        ]
    }

    function applyColors(colors) {
        if (!dynamicThemeEnabled) {
            Theme.resetPalette()
            return
        }

        const accent = chooseAccent(colors)

        if (!accent)
            return

        Theme.applyDynamicPalettes(
            paletteFor(paletteStyle, accent, "light"),
            paletteFor(paletteStyle, accent, "dark")
        )
    }

    function setDynamicTheme(enabled) {
        ConfigStore.setDynamicTheme(enabled)

        if (!Boolean(enabled))
            Theme.resetPalette()
        else
            applyColors(wallpaperColors.colors)
    }

    function setPaletteStyle(style) {
        ConfigStore.setPaletteStyle(style)

        if (dynamicThemeEnabled)
            applyColors(wallpaperColors.colors)
    }

    onDynamicThemeEnabledChanged: {
        if (dynamicThemeEnabled)
            applyColors(wallpaperColors.colors)
        else
            Theme.resetPalette()
    }

    Connections {
        target: ConfigStore

        function onThemeModeChanged() {
            if (root.dynamicThemeEnabled)
                root.applyColors(wallpaperColors.colors)
            else
                Theme.resetPalette()
        }

        function onPaletteStyleChanged() {
            if (root.dynamicThemeEnabled)
                root.applyColors(wallpaperColors.colors)
        }
    }

    ColorQuantizer {
        id: wallpaperColors

        source: root.dynamicThemeEnabled ? root.themeSource : ""
        depth: 3
        rescaleSize: 72
        onColorsChanged: root.applyColors(colors)
    }
}

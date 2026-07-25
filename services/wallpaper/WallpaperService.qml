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

    function paletteFor(style, sourceColor) {
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
        var outlineHue = sourceHue
        var primarySaturation = 0.5
        var containerSaturation = 0.32
        var outlineSaturation = 0.2

        if (selected === "content") {
            primarySaturation = clamped(sourceSaturation, 0.32, 0.82)
            containerSaturation = primarySaturation * 0.58
            outlineSaturation = primarySaturation * 0.32
        } else if (selected === "expressive") {
            primaryHue += 0.16
            containerHue -= 0.12
            outlineHue += 0.32
            primarySaturation = 0.74
            containerSaturation = 0.52
            outlineSaturation = 0.38
        } else if (selected === "fidelity") {
            primarySaturation = sourceSaturation
            containerSaturation = sourceSaturation * 0.72
            outlineSaturation = sourceSaturation * 0.45
        } else if (selected === "fruit-salad") {
            primaryHue -= 0.12
            containerHue += 0.1
            outlineHue += 0.25
            primarySaturation = 0.72
            containerSaturation = 0.56
            outlineSaturation = 0.36
        } else if (selected === "monochrome") {
            primarySaturation = 0
            containerSaturation = 0
            outlineSaturation = 0
        } else if (selected === "neutral") {
            primarySaturation = 0.16
            containerSaturation = 0.1
            outlineSaturation = 0.08
        } else if (selected === "rainbow") {
            primaryHue += 0.24
            containerHue -= 0.18
            outlineHue += 0.42
            primarySaturation = 0.78
            containerSaturation = 0.64
            outlineSaturation = 0.48
        } else {
            primarySaturation = 0.52
            containerSaturation = 0.34
            outlineSaturation = 0.22
        }

        const darkMode = !Theme.lightMode

        return {
            style: selected,
            primary: colorTone(
                primaryHue,
                primarySaturation,
                darkMode ? 0.76 : 0.38
            ),
            container: colorTone(
                containerHue,
                containerSaturation,
                darkMode ? 0.29 : 0.88
            ),
            outline: colorTone(
                outlineHue,
                outlineSaturation,
                darkMode ? 0.62 : 0.48
            )
        }
    }

    function previewColors(style) {
        const source = chooseAccent(wallpaperColors.colors)
            || Qt.color("#4F83CC")
        const palette = paletteFor(style, source)

        return [
            palette.primary,
            palette.container,
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

        const palette = paletteFor(paletteStyle, accent)

        Theme.applyDynamicPalette(
            palette.primary,
            palette.container,
            palette.outline
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

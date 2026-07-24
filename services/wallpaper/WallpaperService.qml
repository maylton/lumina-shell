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

    function applyColors(colors) {
        if (!dynamicThemeEnabled) {
            Theme.resetPalette()
            return
        }

        const accent = chooseAccent(colors)

        if (!accent)
            return

        const luminance = colorLuminance(accent)
        const primary = luminance < 0.62
            ? Qt.lighter(accent, 1.75)
            : Qt.darker(accent, 1.12)
        const container = Qt.darker(accent, luminance < 0.35 ? 1.18 : 1.65)
        const outline = Qt.lighter(container, 1.55)

        Theme.applyDynamicPalette(primary, container, outline)
    }

    function setDynamicTheme(enabled) {
        ConfigStore.setDynamicTheme(enabled)

        if (!Boolean(enabled))
            Theme.resetPalette()
        else
            applyColors(wallpaperColors.colors)
    }

    onDynamicThemeEnabledChanged: {
        if (dynamicThemeEnabled)
            applyColors(wallpaperColors.colors)
        else
            Theme.resetPalette()
    }

    ColorQuantizer {
        id: wallpaperColors

        source: root.dynamicThemeEnabled ? root.themeSource : ""
        depth: 3
        rescaleSize: 72
        onColorsChanged: root.applyColors(colors)
    }
}

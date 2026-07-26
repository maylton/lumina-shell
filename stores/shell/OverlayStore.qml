pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool open: activeSurface.length > 0

    property string activeSurface: ""
    property string activeOutputName: ""

    signal surfaceOpened(string surfaceName, string outputName)
    signal surfaceClosed(string surfaceName)

    function outputExists(outputName) {
        const name = String(outputName || "")
        const screens = Quickshell.screens || []

        for (var i = 0; i < screens.length; ++i) {
            if (String(screens[i].name || "") === name)
                return true
        }

        return false
    }

    function defaultOutputName() {
        const screens = Quickshell.screens || []

        return screens.length > 0 ? String(screens[0].name || "") : ""
    }

    function resolvedOutputName(outputName) {
        const requested = String(outputName || "")

        return outputExists(requested) ? requested : defaultOutputName()
    }

    function isOpenFor(surfaceName, outputName) {
        return activeSurface === String(surfaceName)
            && activeOutputName === String(outputName)
    }

    function openFor(surfaceName, outputName) {
        const surface = String(surfaceName || "")
        const output = resolvedOutputName(outputName)

        if (!surface || !output)
            return

        activeSurface = surface
        activeOutputName = output
        surfaceOpened(surface, output)
    }

    function close(surfaceName) {
        const requested = String(surfaceName || "")

        if (requested && activeSurface !== requested)
            return

        const closedSurface = activeSurface

        activeSurface = ""
        activeOutputName = ""

        if (closedSurface)
            surfaceClosed(closedSurface)
    }

    function toggle(surfaceName, outputName) {
        const surface = String(surfaceName || "")
        const output = resolvedOutputName(outputName)

        if (isOpenFor(surface, output))
            close(surface)
        else
            openFor(surface, output)
    }

    Connections {
        target: Quickshell

        function onScreensChanged() {
            if (root.open && !root.outputExists(root.activeOutputName))
                root.close()
        }
    }
}

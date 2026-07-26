pragma Singleton

import QtQuick
import Quickshell
import "SurfacePlacementPolicy.js" as SurfacePlacementPolicy

Singleton {
    id: root

    readonly property bool open: activeSurface.length > 0

    property string activeSurface: ""
    property string activeOutputName: ""
    property string activePlacement: SurfacePlacementPolicy.CENTERED
    property real activeAnchorX: -1

    property string pendingSurface: ""
    property string pendingOutputName: ""
    property string pendingPlacement: SurfacePlacementPolicy.CENTERED
    property real pendingAnchorX: -1

    signal surfaceOpened(string surfaceName, string outputName)
    signal surfaceClosed(string surfaceName)

    function clearPending() {
        pendingSurface = ""
        pendingOutputName = ""
        pendingPlacement = SurfacePlacementPolicy.CENTERED
        pendingAnchorX = -1
    }

    function prepareFor(
        surfaceName,
        outputName,
        placement,
        anchorX,
        anchorTop,
        anchorBottom
    ) {
        const surface = String(surfaceName || "")
        const output = resolvedOutputName(outputName)
        const numericAnchor = Number(anchorX)
        const normalizedPlacement = SurfacePlacementPolicy.normalize(placement)

        if (!surface || !output) {
            clearPending()
            SurfacePlacementPolicy.clearAnchorGeometry()
            return
        }

        pendingSurface = surface
        pendingOutputName = output
        pendingPlacement = normalizedPlacement
        pendingAnchorX = isFinite(numericAnchor) ? numericAnchor : -1

        if (normalizedPlacement === SurfacePlacementPolicy.NEAR_WIDGET) {
            SurfacePlacementPolicy.captureAnchorGeometry(
                anchorTop,
                anchorBottom
            )
        } else {
            SurfacePlacementPolicy.clearAnchorGeometry()
        }
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

        if (!surface || !output) {
            clearPending()
            SurfacePlacementPolicy.clearAnchorGeometry()
            return
        }

        const prepared = pendingSurface === surface
            && pendingOutputName === output

        activePlacement = prepared
            ? SurfacePlacementPolicy.normalize(pendingPlacement)
            : SurfacePlacementPolicy.CENTERED
        activeAnchorX = prepared ? pendingAnchorX : -1

        if (!prepared)
            SurfacePlacementPolicy.clearAnchorGeometry()

        clearPending()
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
        activePlacement = SurfacePlacementPolicy.CENTERED
        activeAnchorX = -1
        clearPending()
        SurfacePlacementPolicy.clearAnchorGeometry()

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

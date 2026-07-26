pragma Singleton

import QtQml
import "SurfacePlacementPolicy.js" as SurfacePlacementPolicy

QtObject {
    id: root

    readonly property bool open: activeSurface.length > 0

    property string activeSurface: ""
    property string activeOutputName: ""
    property string activePlacement: SurfacePlacementPolicy.CENTERED
    property real activeAnchorX: -1
    property real activeAnchorTop: -1
    property real activeAnchorBottom: -1
    property string activeAnchorEdge: ""

    property string pendingSurface: ""
    property string pendingOutputName: ""
    property string pendingPlacement: SurfacePlacementPolicy.CENTERED
    property real pendingAnchorX: -1
    property real pendingAnchorTop: -1
    property real pendingAnchorBottom: -1
    property string pendingAnchorEdge: ""

    signal surfaceOpened(string surfaceName, string outputName)
    signal surfaceClosed(string surfaceName)

    function clearPending() {
        pendingSurface = ""
        pendingOutputName = ""
        pendingPlacement = SurfacePlacementPolicy.CENTERED
        pendingAnchorX = -1
        pendingAnchorTop = -1
        pendingAnchorBottom = -1
        pendingAnchorEdge = ""
    }

    function prepareFor(
        surfaceName,
        outputName,
        placement,
        anchorX,
        anchorTop,
        anchorBottom,
        anchorEdge
    ) {
        const surface = String(surfaceName || "")
        const output = resolvedOutputName(outputName)
        const numericAnchor = Number(anchorX)
        const numericAnchorTop = Number(anchorTop)
        const numericAnchorBottom = Number(anchorBottom)
        const normalizedPlacement = SurfacePlacementPolicy.normalize(placement)
        const nearWidget = normalizedPlacement
            === SurfacePlacementPolicy.NEAR_WIDGET
        const validVerticalAnchor = isFinite(numericAnchorTop)
            && isFinite(numericAnchorBottom)
            && numericAnchorTop >= 0
            && numericAnchorBottom >= numericAnchorTop

        if (!surface || !output) {
            clearPending()
            return
        }

        pendingSurface = surface
        pendingOutputName = output
        pendingPlacement = normalizedPlacement
        pendingAnchorX = nearWidget && isFinite(numericAnchor)
            ? numericAnchor
            : -1
        pendingAnchorTop = validVerticalAnchor ? numericAnchorTop : -1
        pendingAnchorBottom = validVerticalAnchor
            ? numericAnchorBottom
            : -1
        pendingAnchorEdge = nearWidget
            && validVerticalAnchor
            && String(anchorEdge || "") === "above"
                ? "above"
                : ""
    }

    function resolvedOutputName(outputName) {
        return String(outputName || "").trim()
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
            return
        }

        const prepared = pendingSurface === surface
            && pendingOutputName === output

        activePlacement = prepared
            ? SurfacePlacementPolicy.normalize(pendingPlacement)
            : SurfacePlacementPolicy.CENTERED
        activeAnchorX = prepared ? pendingAnchorX : -1
        activeAnchorTop = prepared ? pendingAnchorTop : -1
        activeAnchorBottom = prepared ? pendingAnchorBottom : -1
        activeAnchorEdge = prepared ? pendingAnchorEdge : ""

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
        activeAnchorTop = -1
        activeAnchorBottom = -1
        activeAnchorEdge = ""
        clearPending()

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

}

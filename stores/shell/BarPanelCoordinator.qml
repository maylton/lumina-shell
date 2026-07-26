pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool busy: transitionPhase !== "idle"

    property string activePanelId: ""
    property string activeOutputName: ""
    property string pendingPanelId: ""
    property string pendingOutputName: ""
    property string pendingPlacement: "centered"
    property real pendingAnchorX: -1
    property real pendingAnchorTop: -1
    property real pendingAnchorBottom: -1
    property string transitionPhase: "idle"
    property string observedOverlaySurface: ""
    property string observedOverlayOutput: ""

    signal openRequested(
        string panelId,
        string outputName,
        string placement,
        real anchorX,
        real anchorTop,
        real anchorBottom
    )
    signal closeRequested(string panelId, string outputName)

    function normalized(value) {
        return String(value || "").trim()
    }

    function overlayPanelId(surfaceName) {
        switch (normalized(surfaceName)) {
        case "launcher":
            return "launcher"
        case "notifications":
            return "notifications"
        case "control":
            return "dashboard"
        case "wallpaper":
            return "wallpaper"
        case "session":
            return "session"
        default:
            return ""
        }
    }

    function clearPending() {
        pendingPanelId = ""
        pendingOutputName = ""
        pendingPlacement = "centered"
        pendingAnchorX = -1
        pendingAnchorTop = -1
        pendingAnchorBottom = -1
    }

    function setPending(
        panelId,
        outputName,
        placement,
        anchorX,
        anchorTop,
        anchorBottom
    ) {
        pendingPanelId = normalized(panelId)
        pendingOutputName = normalized(outputName)
        pendingPlacement = normalized(placement) || "centered"
        pendingAnchorX = Number(anchorX)
        pendingAnchorTop = Number(anchorTop)
        pendingAnchorBottom = Number(anchorBottom)
    }

    function requestToggle(
        panelId,
        outputName,
        placement,
        anchorX,
        anchorTop,
        anchorBottom
    ) {
        const panel = normalized(panelId)
        const output = normalized(outputName)

        if (!panel || !output)
            return

        if (transitionPhase === "closing") {
            if (activePanelId === panel && activeOutputName === output) {
                clearPending()
            } else {
                setPending(
                    panel,
                    output,
                    placement,
                    anchorX,
                    anchorTop,
                    anchorBottom
                )
            }
            return
        }

        if (transitionPhase === "opening") {
            setPending(
                panel,
                output,
                placement,
                anchorX,
                anchorTop,
                anchorBottom
            )
            return
        }

        if (activePanelId === panel && activeOutputName === output) {
            clearPending()
            beginClose()
            return
        }

        setPending(
            panel,
            output,
            placement,
            anchorX,
            anchorTop,
            anchorBottom
        )

        if (activePanelId)
            beginClose()
        else
            openPending()
    }

    function beginClose() {
        if (!activePanelId) {
            openPending()
            return
        }

        transitionPhase = "closing"
        transitionTimer.restart()
        closeRequested(activePanelId, activeOutputName)
    }

    function openPending() {
        if (!pendingPanelId) {
            transitionPhase = "idle"
            transitionTimer.stop()
            return
        }

        const panel = pendingPanelId
        const output = pendingOutputName
        const placement = pendingPlacement
        const anchorX = pendingAnchorX
        const anchorTop = pendingAnchorTop
        const anchorBottom = pendingAnchorBottom

        clearPending()
        transitionPhase = "opening"
        transitionTimer.restart()

        Qt.callLater(function() {
            root.openRequested(
                panel,
                output,
                placement,
                anchorX,
                anchorTop,
                anchorBottom
            )
        })
    }

    function reportOpened(panelId, outputName) {
        const panel = normalized(panelId)
        const output = normalized(outputName)

        if (!panel || !output)
            return

        activePanelId = panel
        activeOutputName = output
        transitionTimer.stop()

        if (pendingPanelId) {
            transitionPhase = "idle"
            beginClose()
        } else {
            transitionPhase = "idle"
        }
    }

    function reportClosed(panelId, outputName) {
        const panel = normalized(panelId)
        const output = normalized(outputName)
        const matchesActive = activePanelId === panel
            && (!output || activeOutputName === output)

        if (!matchesActive)
            return

        activePanelId = ""
        activeOutputName = ""
        transitionTimer.stop()

        if (transitionPhase === "closing") {
            Qt.callLater(function() {
                root.openPending()
            })
        } else {
            transitionPhase = "idle"
        }
    }

    function synchronizeIndependentPanel(panelId, outputName, visible) {
        if (Boolean(visible))
            reportOpened(panelId, outputName)
        else
            reportClosed(panelId, outputName)
    }

    function handleOverlayChange() {
        const previousPanel = overlayPanelId(observedOverlaySurface)
        const previousOutput = observedOverlayOutput
        const currentSurface = normalized(OverlayStore.activeSurface)
        const currentOutput = normalized(OverlayStore.activeOutputName)
        const currentPanel = overlayPanelId(currentSurface)
        const changed = observedOverlaySurface !== currentSurface
            || observedOverlayOutput !== currentOutput

        if (!changed)
            return

        observedOverlaySurface = currentSurface
        observedOverlayOutput = currentOutput

        if (previousPanel)
            reportClosed(previousPanel, previousOutput)

        if (currentPanel)
            reportOpened(currentPanel, currentOutput)
    }

    Component.onCompleted: {
        observedOverlaySurface = normalized(OverlayStore.activeSurface)
        observedOverlayOutput = normalized(OverlayStore.activeOutputName)

        const panel = overlayPanelId(observedOverlaySurface)
        if (panel)
            reportOpened(panel, observedOverlayOutput)
    }

    Connections {
        target: OverlayStore

        function onActiveSurfaceChanged() {
            root.handleOverlayChange()
        }

        function onActiveOutputNameChanged() {
            root.handleOverlayChange()
        }
    }

    Timer {
        id: transitionTimer

        interval: 350
        repeat: false
        onTriggered: {
            if (root.transitionPhase === "closing") {
                root.activePanelId = ""
                root.activeOutputName = ""
                root.openPending()
            } else if (root.transitionPhase === "opening") {
                root.transitionPhase = "idle"
            }
        }
    }
}

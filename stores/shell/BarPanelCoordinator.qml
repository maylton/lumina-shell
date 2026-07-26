pragma Singleton

import QtQuick

QtObject {
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
    property string pendingAnchorEdge: ""
    property string transitionPhase: "idle"

    signal openRequested(
        string panelId,
        string outputName,
        string placement,
        real anchorX,
        real anchorTop,
        real anchorBottom,
        string anchorEdge
    )
    signal closeRequested(string panelId, string outputName)

    function normalized(value) {
        return String(value || "").trim()
    }

    function clearPending() {
        pendingPanelId = ""
        pendingOutputName = ""
        pendingPlacement = "centered"
        pendingAnchorX = -1
        pendingAnchorTop = -1
        pendingAnchorBottom = -1
        pendingAnchorEdge = ""
    }

    function reset() {
        handoffTimer.stop()
        transitionTimer.stop()
        activePanelId = ""
        activeOutputName = ""
        transitionPhase = "idle"
        clearPending()
    }

    function setPending(
        panelId,
        outputName,
        placement,
        anchorX,
        anchorTop,
        anchorBottom,
        anchorEdge
    ) {
        pendingPanelId = normalized(panelId)
        pendingOutputName = normalized(outputName)
        pendingPlacement = normalized(placement) || "centered"
        pendingAnchorX = Number(anchorX)
        pendingAnchorTop = Number(anchorTop)
        pendingAnchorBottom = Number(anchorBottom)
        pendingAnchorEdge = String(anchorEdge || "") === "above"
            ? "above"
            : ""
    }

    function requestToggle(
        panelId,
        outputName,
        placement,
        anchorX,
        anchorTop,
        anchorBottom,
        anchorEdge
    ) {
        const panel = normalized(panelId)
        const output = normalized(outputName)

        if (!panel || !output)
            return

        PerformanceTrace.recordInstant(
            "coordinator",
            panel,
            "toggle",
            {
                output: output,
                phase: transitionPhase,
                activePanel: activePanelId,
                pendingPanel: pendingPanelId
            }
        )

        if (transitionPhase === "closing") {
            setPending(
                panel,
                output,
                placement,
                anchorX,
                anchorTop,
                anchorBottom,
                anchorEdge
            )
            return
        }

        if (transitionPhase === "opening") {
            const togglesOpeningPanel = activePanelId === panel
                && activeOutputName === output

            if (togglesOpeningPanel) {
                clearPending()
            } else {
                setPending(
                    panel,
                    output,
                    placement,
                    anchorX,
                    anchorTop,
                    anchorBottom,
                    anchorEdge
                )
            }

            if (activePanelId)
                beginClose()
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
            anchorBottom,
            anchorEdge
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

        handoffTimer.stop()
        transitionPhase = "closing"
        transitionTimer.restart()
        closeRequested(activePanelId, activeOutputName)
    }

    function openPending() {
        handoffTimer.stop()

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
        const anchorEdge = pendingAnchorEdge

        clearPending()
        activePanelId = panel
        activeOutputName = output
        transitionPhase = "opening"
        transitionTimer.restart()

        Qt.callLater(function() {
            root.openRequested(
                panel,
                output,
                placement,
                anchorX,
                anchorTop,
                anchorBottom,
                anchorEdge
            )
        })
    }

    function reportOpened(panelId, outputName) {
        const panel = normalized(panelId)
        const output = normalized(outputName)

        if (!panel || !output)
            return

        if (activePanelId
            && (activePanelId !== panel || activeOutputName !== output)) {
            return
        }

        activePanelId = panel
        activeOutputName = output
        transitionTimer.stop()

        if (pendingPanelId) {
            const closesJustOpenedPanel = pendingPanelId === panel
                && pendingOutputName === output

            if (closesJustOpenedPanel)
                clearPending()

            transitionPhase = "idle"
            beginClose()
        } else {
            transitionPhase = "idle"
        }
    }

    function reportPanelLogicalVisibility(
        panelId,
        outputName,
        visible
    ) {
        const panel = normalized(panelId)
        const output = normalized(outputName)

        if (!panel || !output)
            return

        if (Boolean(visible)) {
            if (!activePanelId) {
                activePanelId = panel
                activeOutputName = output
            }
            return
        }

        reportClosed(panel, output)
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
            handoffTimer.restart()
        } else {
            transitionPhase = "idle"
        }
    }

    function reportPanelWindowVisibility(
        panelId,
        outputName,
        visible
    ) {
        if (Boolean(visible))
            reportOpened(panelId, outputName)
        else
            reportClosed(panelId, outputName)
    }

    property Timer handoffTimerObject: Timer {
        id: handoffTimer

        interval: 32
        repeat: false
        onTriggered: root.openPending()
    }

    property Timer transitionTimerObject: Timer {
        id: transitionTimer

        interval: 350
        repeat: false
        onTriggered: {
            PerformanceTrace.record(
                "coordinator",
                root.transitionPhase === "closing"
                    ? root.activePanelId
                    : root.pendingPanelId,
                "timeout",
                interval,
                {
                    phase: root.transitionPhase,
                    activePanel: root.activePanelId,
                    pendingPanel: root.pendingPanelId
                }
            )

            if (root.transitionPhase === "closing") {
                root.activePanelId = ""
                root.activeOutputName = ""
                root.openPending()
            } else if (root.transitionPhase === "opening") {
                root.transitionPhase = "idle"
                if (root.pendingPanelId) {
                    if (root.activePanelId)
                        root.beginClose()
                    else
                        root.openPending()
                }
            }
        }
    }
}

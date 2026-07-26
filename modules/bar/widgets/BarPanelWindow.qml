pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.stores.config
import qs.stores.shell
import "../../control/ShellSurfacePolicy.js" as ShellSurfacePolicy
import "../../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

PanelWindow {
    id: root

    property string panelId: ""
    property string panelOutputName: ""
    property bool panelVisible: false
    property string layerNamespace: "lumina-bar-panel-" + panelId
    property color scrimColor: "transparent"
    property Item surfaceItem: null
    property real surfaceRadius: 0
    property string surfaceAnchorEdge: ""
    property real surfaceAnchorTop: -1
    property double visibilityRequestedAt: 0
    property double hidingRequestedAt: 0
    property double settleRequestedAt: 0

    default property alias panelData: panelLayer.data

    signal dismissRequested()

    function adjacentSurfaceY(surfaceHeight) {
        const height = Math.max(0, Number(surfaceHeight) || 0)
        const maximum = Math.max(0, root.height - height)
        const gap = Math.max(0, Number(ConfigStore.barPanelGap) || 0)

        return ConfigStore.barPosition === "bottom"
            ? Math.max(0, maximum - gap)
            : Math.min(gap, maximum)
    }

    function resolvedSurfaceY(surfaceHeight) {
        if (surfaceAnchorEdge !== "above" || surfaceAnchorTop < 0)
            return adjacentSurfaceY(surfaceHeight)

        const localAnchor = panelLayer.mapFromGlobal(
            Qt.point(0, surfaceAnchorTop)
        )

        return SurfacePlacementPolicy.aboveAnchorY(
            localAnchor.y,
            surfaceHeight,
            root.height,
            ConfigStore.barPanelGap
        )
    }

    visible: panelVisible
    color: "transparent"
    surfaceFormat.opaque: false
    focusable: panelVisible
    exclusiveZone: 0

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: layerNamespace
    WlrLayershell.keyboardFocus: panelVisible
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    onPanelVisibleChanged: {
        if (panelVisible) {
            visibilityRequestedAt = Date.now()
            PerformanceTrace.recordInstant(
                "panel",
                panelId,
                "requested",
                { output: panelOutputName }
            )
        } else {
            hidingRequestedAt = Date.now()
        }

        BarPanelCoordinator.reportPanelLogicalVisibility(
            panelId,
            panelOutputName,
            panelVisible
        )
    }

    BackgroundEffect.blurRegion:
        surfaceItem
        && ShellSurfacePolicy.requestsBackdropBlur(
            ConfigStore.shellBackgroundMode
        )
            ? panelBlurRegion
            : null

    onBackingWindowVisibleChanged: {
        if (backingWindowVisible && visibilityRequestedAt > 0) {
            settleRequestedAt = visibilityRequestedAt
            PerformanceTrace.record(
                "panel",
                panelId,
                "visible",
                Date.now() - visibilityRequestedAt,
                { output: panelOutputName }
            )
            visibilityRequestedAt = 0
            Qt.callLater(function() {
                if (!root.panelVisible || root.settleRequestedAt <= 0)
                    return

                PerformanceTrace.record(
                    "panel",
                    root.panelId,
                    "settled",
                    Date.now() - root.settleRequestedAt,
                    { output: root.panelOutputName }
                )
                root.settleRequestedAt = 0
            })
        } else if (!backingWindowVisible && hidingRequestedAt > 0) {
            PerformanceTrace.record(
                "panel",
                panelId,
                "hidden",
                Date.now() - hidingRequestedAt,
                { output: panelOutputName }
            )
            hidingRequestedAt = 0
            settleRequestedAt = 0
        }

        BarPanelCoordinator.reportPanelWindowVisibility(
            panelId,
            panelOutputName,
            backingWindowVisible && panelVisible
        )
    }

    Component.onDestruction: {
        if (OverlayStore.isOpenFor(panelId, panelOutputName))
            OverlayStore.close(panelId)
    }

    Region {
        id: panelBlurRegion

        Region {
            x: root.surfaceItem ? root.surfaceItem.x : 0
            y: root.surfaceItem ? root.surfaceItem.y : 0
            width: root.surfaceItem ? root.surfaceItem.width : 0
            height: root.surfaceItem ? root.surfaceItem.height : 0
            radius: root.surfaceRadius
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.scrimColor

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissRequested()
        }
    }

    Item {
        id: panelLayer

        anchors.fill: parent
    }

    Binding {
        target: root.surfaceItem
        property: "y"
        value: root.resolvedSurfaceY(
            root.surfaceItem ? root.surfaceItem.height : 0
        )
        when: root.surfaceItem !== null
    }
}

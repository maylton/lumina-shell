pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.stores.config
import qs.stores.shell
import "../../control/ShellSurfacePolicy.js" as ShellSurfacePolicy

PanelWindow {
    id: root

    property string panelId: ""
    property string panelOutputName: ""
    property bool panelVisible: false
    property string layerNamespace: "lumina-bar-panel-" + panelId
    property color scrimColor: "transparent"
    property Item surfaceItem: null
    property real surfaceRadius: 0

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

    BackgroundEffect.blurRegion:
        surfaceItem
        && ShellSurfacePolicy.requestsBackdropBlur(
            ConfigStore.shellBackgroundMode
        )
            ? panelBlurRegion
            : null

    onBackingWindowVisibleChanged: {
        BarPanelCoordinator.reportPanelWindowVisibility(
            panelId,
            panelOutputName,
            backingWindowVisible
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
        value: root.adjacentSurfaceY(
            root.surfaceItem ? root.surfaceItem.height : 0
        )
        when: root.surfaceItem !== null
    }
}

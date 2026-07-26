pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.stores.config
import "../../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

PopupWindow {
    id: root

    property var anchorItem: null
    property var panelWindow: null
    property string placement: "near-widget"
    property real anchorX: -1
    property var items: []
    property bool requestedVisible: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property int itemCount: items ? items.length : 0
    readonly property int columnCount: Math.min(4, Math.max(1, itemCount))

    function toggle() {
        requestedVisible = !requestedVisible
    }

    function dismiss() {
        requestedVisible = false
    }

    visible: requestedVisible
        && itemCount > 0
        && anchorItem !== null
        && panelWindow !== null
    implicitWidth: trayGrid.implicitWidth
        + luminaDesign.spacing.medium * 2
    implicitHeight: trayGrid.implicitHeight
        + luminaDesign.spacing.medium * 2
    color: "transparent"
    grabFocus: true

    anchor.window: root.panelWindow
    anchor.rect.x: SurfacePlacementPolicy.horizontalX(
        root.placement,
        root.anchorX,
        root.implicitWidth,
        root.panelWindow && root.panelWindow.screen
            ? root.panelWindow.screen.width
            : 0,
        root.luminaDesign.spacing.medium
    )
    anchor.rect.y: SurfacePlacementPolicy.popupY(
        root.placement,
        ConfigStore.barPosition,
        root.implicitHeight,
        root.panelWindow && root.panelWindow.screen
            ? root.panelWindow.screen.height
            : 0,
        root.panelWindow ? root.panelWindow.height : 0,
        root.luminaDesign.spacing.barPanelGap,
        root.luminaDesign.spacing.medium
    )
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.All

    onClosed: dismiss()

    Rectangle {
        anchors.fill: parent
        radius: root.luminaDesign.shape.large
        color: root.luminaDesign.color.surfaceContainer
        border.width: 1
        border.color: root.luminaDesign.color.outline
        opacity: root.visible ? 1 : 0
        scale: root.visible ? 1 : 0.96

        Behavior on opacity {
            NumberAnimation {
                duration: root.luminaDesign.motion.effectsDefault
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.luminaDesign.motion.spatialDefault
                easing.type: root.luminaDesign.motion.spatialEasing
                easing.overshoot:
                    root.luminaDesign.motion.spatialOvershoot
            }
        }

        Grid {
            id: trayGrid

            anchors.centerIn: parent
            columns: root.columnCount
            spacing: root.luminaDesign.spacing.extraSmall

            Repeater {
                model: root.items

                delegate: TrayItem {
                    required property var modelData

                    trayItem: modelData
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.stores.config
import qs.stores.shell
import "../../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

BarPanelWindow {
    id: root

    required property string outputName
    property var panelWindow: null
    property var items: []

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property int itemCount: items ? items.length : 0
    readonly property int columnCount: Math.min(4, Math.max(1, itemCount))

    function dismiss() {
        OverlayStore.close("tray")
    }

    panelId: "tray"
    panelOutputName: outputName
    panelVisible: itemCount > 0
        && panelWindow !== null
        && OverlayStore.isOpenFor("tray", outputName)
    layerNamespace: "lumina-tray-panel"
    screen: panelWindow ? panelWindow.screen : null
    surfaceItem: traySurface
    surfaceRadius: traySurface.radius
    onDismissRequested: dismiss()

    onClosed: dismiss()

    Rectangle {
        id: traySurface

        x: SurfacePlacementPolicy.horizontalX(
            OverlayStore.activePlacement,
            OverlayStore.activeAnchorX,
            width,
            root.width,
            root.luminaDesign.spacing.medium
        )
        width: trayGrid.implicitWidth + root.luminaDesign.spacing.medium * 2
        height: trayGrid.implicitHeight + root.luminaDesign.spacing.medium * 2
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

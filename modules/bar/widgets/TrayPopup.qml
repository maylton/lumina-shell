pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.stores.config

PopupWindow {
    id: root

    property var anchorItem: null
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

    visible: requestedVisible && itemCount > 0 && anchorItem !== null
    implicitWidth: trayGrid.implicitWidth
        + luminaDesign.spacing.medium * 2
    implicitHeight: trayGrid.implicitHeight
        + luminaDesign.spacing.medium * 2
    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.edges: ConfigStore.barPosition === "top"
        ? Edges.Bottom | Edges.Right
        : Edges.Top | Edges.Right
    anchor.gravity: ConfigStore.barPosition === "top"
        ? Edges.Bottom | Edges.Left
        : Edges.Top | Edges.Left
    anchor.margins.top: ConfigStore.barPosition === "top"
        ? luminaDesign.spacing.barPanelGap
        : 0
    anchor.margins.bottom: ConfigStore.barPosition === "bottom"
        ? luminaDesign.spacing.barPanelGap
        : 0
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
                duration: root.luminaDesign.motion.medium
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.luminaDesign.motion.medium
                easing.type: Easing.OutBack
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

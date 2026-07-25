pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.stores.config

PopupWindow {
    id: root

    property var anchorItem: null
    property var trayItem: null
    property bool requestedVisible: false
    property int closeRevision: 0

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property int entryCount: menuOpener.children
        ? menuOpener.children.values.length
        : 0

    function show() {
        if (!trayItem || !trayItem.hasMenu)
            return

        requestedVisible = true
    }

    function dismiss() {
        requestedVisible = false
        closeRevision += 1
    }

    visible: requestedVisible && entryCount > 0 && anchorItem !== null
    implicitWidth: 272
    implicitHeight: Math.min(
        480,
        menuColumn.implicitHeight + luminaDesign.spacing.medium * 2
    )
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

    onImplicitHeightChanged: {
        if (visible)
            Qt.callLater(() => root.anchor.updateAnchor())
    }

    QsMenuOpener {
        id: menuOpener
        menu: root.trayItem && root.trayItem.hasMenu ? root.trayItem.menu : null
    }

    Rectangle {
        anchors.fill: parent
        radius: root.luminaDesign.shape.large
        color: root.luminaDesign.color.surfaceContainer
        border.width: 1
        border.color: root.luminaDesign.color.outline
        opacity: root.visible ? 1.0 : 0.0
        scale: root.visible ? 1.0 : 0.96

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

        Flickable {
            anchors {
                fill: parent
                margins: root.luminaDesign.spacing.medium
            }

            contentHeight: menuColumn.implicitHeight
            clip: true
            interactive: contentHeight > height

            Column {
                id: menuColumn

                width: parent.width
                spacing: root.luminaDesign.spacing.extraSmall

                Repeater {
                    model: menuOpener.children

                    delegate: TrayMenuEntry {
                        required property var modelData

                        width: menuColumn.width
                        menuEntry: modelData
                        closeRevision: root.closeRevision
                        onActionTriggered: root.dismiss()
                    }
                }
            }
        }
    }
}

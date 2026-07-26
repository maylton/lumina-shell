pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.design
import qs.modules.control
import qs.services.i18n
import qs.stores.config
import qs.stores.dock
import qs.stores.shell
import "../control/ShellSurfacePolicy.js" as ShellSurfacePolicy
import "DockStrings.js" as DockStrings

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: panel

                required property var modelData

                readonly property string outputName:
                    modelData && modelData.name
                        ? String(modelData.name)
                        : ""
                readonly property bool taskPanel:
                    DockPreferences.mode === "task-panel"
                readonly property int bottomBarOffset:
                    ConfigStore.barPosition === "bottom"
                        ? ConfigStore.barHeight
                            + (ConfigStore.barSurfaceMode === "floating"
                                ? ConfigStore.barMargin * 2
                                : 0)
                        : 0
                readonly property int effectiveMargin:
                    taskPanel ? 0 : DockPreferences.margin
                readonly property int reservedWindowGap:
                    !taskPanel
                    && DockPreferences.reserveSpace
                    && !DockPreferences.autoHide
                        ? 8
                        : 0
                readonly property int surfaceHeight:
                    DockPreferences.iconSize + 24
                readonly property int expandedHeight:
                    bottomBarOffset
                        + surfaceHeight
                        + effectiveMargin
                        + reservedWindowGap
                // Keep the layer-shell window stable while live settings resize
                // the visible dock: 72 px icon + chrome + margin + reserve gap.
                readonly property int stableWindowHeight:
                    bottomBarOffset
                        + 72
                        + 24
                        + 24
                        + 8
                readonly property int desiredFloatingWidth:
                    Math.max(112, dockRow.implicitWidth + 24)
                readonly property int maximumFloatingWidth:
                    Math.max(160, width - DockPreferences.margin * 2)
                readonly property int surfaceWidth: taskPanel
                    ? width
                    : Math.min(maximumFloatingWidth, desiredFloatingWidth)
                readonly property bool contextMenuOpen: dockPinMenu.opened
                readonly property int contextMenuExtraHeight:
                    contextMenuOpen ? dockPinMenu.height + 12 : 0
                readonly property bool pointerInside:
                    revealHover.hovered
                    || surfaceHover.hovered
                    || contextMenuOpen
                readonly property bool expanded:
                    !DockPreferences.autoHide
                    || revealRequested
                    || pointerInside

                property bool revealRequested: !DockPreferences.autoHide
                property var contextItem: null
                property real contextAnchorX: width / 2
                readonly property string launcherSurfacePlacement: String(
                    ConfigStore.widgetSetting(
                        "launcher",
                        "surfacePlacement",
                        "centered"
                    )
                )

                function closeContextMenu() {
                    const wasOpen = dockPinMenu.opened
                    dockPinMenu.close()
                    contextItem = null

                    if (wasOpen
                        && DockPreferences.autoHide
                        && !revealHover.hovered
                        && !surfaceHover.hovered) {
                        hideTimer.restart()
                    }
                }

                function openContextMenu(item, sourceItem) {
                    if (!item || !sourceItem)
                        return

                    const point = sourceItem.mapToItem(panel, 0, 0)
                    contextItem = item
                    contextAnchorX = point.x + sourceItem.width / 2
                    revealRequested = true
                    hideTimer.stop()
                    dockPinMenu.open()
                }

                screen: modelData
                visible: DockPreferences.initialized
                    && DockPreferences.enabled
                implicitHeight:
                    stableWindowHeight + contextMenuExtraHeight
                exclusiveZone: DockPreferences.reserveSpace
                    && !DockPreferences.autoHide
                        ? expandedHeight
                        : 0
                color: "transparent"
                focusable: contextMenuOpen
                surfaceFormat.opaque: false

                anchors {
                    left: true
                    right: true
                    bottom: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "lumina-dock"
                WlrLayershell.keyboardFocus: contextMenuOpen
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                mask: Region {
                    Region {
                        x: 0
                        y: 0
                        width: panel.contextMenuOpen ? panel.width : 0
                        height: panel.contextMenuOpen ? panel.height : 0
                    }

                    Region {
                        x: dockSurface.x
                        y: dockSurface.y
                        width: panel.expanded ? dockSurface.width : 0
                        height: panel.expanded ? dockSurface.height : 0
                        radius: dockSurface.radius
                    }

                    Region {
                        x: revealZone.x
                        y: revealZone.y
                        width: revealZone.width
                        height: revealZone.height
                        radius: revealZone.height / 2
                    }
                }

                BackgroundEffect.blurRegion:
                    panel.expanded
                    && ShellSurfacePolicy.requestsBackdropBlur(
                        ConfigStore.shellBackgroundMode
                    )
                        ? dockBlurRegion
                        : null

                Region {
                    id: dockBlurRegion

                    Region {
                        x: dockSurface.x
                        y: dockSurface.y
                        width: dockSurface.width
                        height: dockSurface.height
                        radius: dockSurface.radius
                    }
                }

                Timer {
                    id: hideTimer

                    interval: 650
                    repeat: false
                    onTriggered: {
                        if (DockPreferences.autoHide && !panel.pointerInside)
                            panel.revealRequested = false
                    }
                }

                Connections {
                    target: DockPreferences

                    function onAutoHideChanged() {
                        panel.closeContextMenu()
                        panel.revealRequested = !DockPreferences.autoHide
                        hideTimer.stop()
                    }

                    function onModeChanged() {
                        panel.closeContextMenu()
                    }

                    function onEnabledChanged() {
                        if (!DockPreferences.enabled) {
                            panel.closeContextMenu()
                            hideTimer.stop()
                            panel.revealRequested = !DockPreferences.autoHide
                        }
                    }
                }

                Item {
                    id: revealZone

                    x: panel.taskPanel
                        ? 0
                        : Math.max(0, (panel.width - width) / 2)
                    y: Math.max(
                        0,
                        panel.height - panel.bottomBarOffset - height
                    )
                    width: panel.taskPanel
                        ? panel.width
                        : Math.min(
                            panel.width,
                            Math.max(260, panel.surfaceWidth)
                        )
                    height: 7

                    HoverHandler {
                        id: revealHover

                        onHoveredChanged: {
                            if (hovered) {
                                hideTimer.stop()
                                panel.revealRequested = true
                            } else if (DockPreferences.autoHide
                                && !surfaceHover.hovered
                                && !panel.contextMenuOpen) {
                                hideTimer.restart()
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: 1
                    visible: panel.contextMenuOpen
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: panel.closeContextMenu()
                }

                ShellSurface {
                    id: dockSurface

                    z: 2
                    x: panel.taskPanel
                        ? 0
                        : Math.max(0, (panel.width - width) / 2)
                    anchors {
                        bottom: parent.bottom
                        bottomMargin:
                            panel.bottomBarOffset + panel.effectiveMargin
                    }
                    visible: panel.expanded
                    width: panel.surfaceWidth
                    height: panel.surfaceHeight
                    radius: panel.taskPanel
                        ? root.luminaDesign.shape.none
                        : root.luminaDesign.shape.extraLarge

                    HoverHandler {
                        id: surfaceHover

                        onHoveredChanged: {
                            if (hovered) {
                                hideTimer.stop()
                                panel.revealRequested = true
                            } else if (DockPreferences.autoHide
                                && !revealHover.hovered
                                && !panel.contextMenuOpen) {
                                hideTimer.restart()
                            }
                        }
                    }

                    Flickable {
                        id: dockFlick

                        anchors {
                            fill: parent
                            leftMargin: panel.taskPanel ? 18 : 12
                            rightMargin: panel.taskPanel ? 18 : 12
                            topMargin: 6
                            bottomMargin: 6
                        }
                        contentWidth: Math.max(width, dockRow.implicitWidth)
                        contentHeight: height
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        flickableDirection: Flickable.HorizontalFlick

                        Row {
                            id: dockRow

                            x: Math.max(
                                0,
                                (dockFlick.width - implicitWidth) / 2
                            )
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: root.luminaDesign.spacing.small

                            Rectangle {
                                id: launcherButton

                                width: DockPreferences.iconSize + 12
                                height: width
                                radius: root.luminaDesign.shape.full
                                color: "transparent"
                                activeFocusOnTab: true
                                border.width: activeFocus ? 2 : 0
                                border.color:
                                    root.luminaDesign.color.primary

                                Accessible.role: Accessible.Button
                                Accessible.name:
                                    DockStrings.text(I18n.locale, "launcher")
                                Accessible.description:
                                    DockStrings.text(
                                        I18n.locale,
                                        "openLauncher"
                                    )
                                Accessible.focusable: true
                                Accessible.focused: activeFocus
                                Accessible.onPressAction:
                                    launcherButton.activate()

                                function anchorGeometry() {
                                    const horizontal = launcherButton.mapToItem(
                                        null,
                                        launcherButton.width / 2,
                                        0
                                    )
                                    const globalTop = launcherButton.mapToGlobal(
                                        Qt.point(
                                            launcherButton.width / 2,
                                            0
                                        )
                                    )
                                    const globalBottom =
                                        launcherButton.mapToGlobal(
                                            Qt.point(
                                                launcherButton.width / 2,
                                                launcherButton.height
                                            )
                                        )

                                    return {
                                        x: Number(horizontal.x),
                                        top: Number(globalTop.y),
                                        bottom: Number(globalBottom.y)
                                    }
                                }

                                function activate() {
                                    panel.closeContextMenu()
                                    const anchor = anchorGeometry()
                                    BarPanelCoordinator.requestToggle(
                                        "launcher",
                                        panel.outputName,
                                        panel.launcherSurfacePlacement,
                                        anchor.x,
                                        anchor.top,
                                        anchor.bottom,
                                        "above"
                                    )
                                }

                                function activateFromPointer() {
                                    launcherButton.forceActiveFocus()
                                    launcherButton.focus = false
                                    activate()
                                }

                                Keys.onSpacePressed: event => {
                                    launcherButton.activate()
                                    event.accepted = true
                                }

                                Keys.onReturnPressed: event => {
                                    launcherButton.activate()
                                    event.accepted = true
                                }

                                Item {
                                    id: launcherGlyph

                                    anchors.centerIn: parent
                                    width: Math.round(
                                        DockPreferences.iconSize * 0.68
                                    )
                                    height: width
                                    scale: launcherMouse.pressed
                                        ? 0.95
                                        : launcherMouse.containsMouse
                                            ? 1.05
                                            : 1

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.press
                                            easing.type:
                                                root.luminaDesign.motion.effectsEasing
                                        }
                                    }

                                    Grid {
                                        id: launcherGrid

                                        readonly property int cellSize:
                                            Math.max(
                                                4,
                                                Math.floor(
                                                    (launcherGlyph.width
                                                        - spacing * 2) / 3
                                                )
                                            )

                                        anchors.centerIn: parent
                                        rows: 3
                                        columns: 3
                                        spacing: Math.max(
                                            2,
                                            Math.round(
                                                launcherGlyph.width * 0.08
                                            )
                                        )

                                        Repeater {
                                            model: 9

                                            delegate: Rectangle {
                                                width: launcherGrid.cellSize
                                                height: width
                                                radius: Math.max(
                                                    1,
                                                    Math.round(width * 0.24)
                                                )
                                                color:
                                                    root.luminaDesign.color.onSurface
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: launcherMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked:
                                        launcherButton.activateFromPointer()
                                }
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: DockStore.items.length > 0
                                width: 1
                                height: Math.round(
                                    DockPreferences.iconSize * 0.62
                                )
                                color: root.luminaDesign.color.divider
                            }

                            Repeater {
                                model: DockStore.items

                                delegate: DockItem {
                                    required property var modelData

                                    item: modelData
                                    iconSize: DockPreferences.iconSize
                                    onActivated: {
                                        panel.closeContextMenu()
                                        DockStore.activate(modelData)
                                    }
                                    onContextMenuRequested: sourceItem =>
                                        panel.openContextMenu(
                                            modelData,
                                            sourceItem
                                        )
                                }
                            }
                        }
                    }
                }

                DockPinMenu {
                    id: dockPinMenu

                    z: 3
                    x: Math.max(
                        12,
                        Math.min(
                            panel.width - width - 12,
                            panel.contextAnchorX - width / 2
                        )
                    )
                    y: dockSurface.y - height - 8
                    pinned: panel.contextItem
                        ? Boolean(panel.contextItem.pinned)
                        : false
                    applicationTitle: panel.contextItem
                        ? String(panel.contextItem.title || "")
                        : ""
                    onActionTriggered: {
                        DockStore.togglePinned(panel.contextItem)
                        panel.closeContextMenu()
                    }
                    onCloseRequested: panel.closeContextMenu()
                }
            }
        }
    }
}

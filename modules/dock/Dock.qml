pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.design
import qs.modules.control
import qs.services.i18n
import qs.stores.config
import qs.stores.dock
import qs.stores.launcher
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
                readonly property int collapsedHeight:
                    bottomBarOffset + 7
                readonly property int desiredFloatingWidth:
                    Math.max(112, dockRow.implicitWidth + 24)
                readonly property int maximumFloatingWidth:
                    Math.max(160, width - DockPreferences.margin * 2)
                readonly property int surfaceWidth: taskPanel
                    ? width
                    : Math.min(
                        maximumFloatingWidth,
                        desiredFloatingWidth
                    )
                readonly property bool pointerInside:
                    revealHover.hovered || surfaceHover.hovered
                readonly property bool expanded:
                    !DockPreferences.autoHide
                    || revealRequested
                    || pointerInside

                property bool revealRequested: !DockPreferences.autoHide

                screen: modelData
                visible: DockPreferences.initialized
                    && DockPreferences.enabled
                implicitHeight: expanded ? expandedHeight : collapsedHeight
                exclusiveZone: DockPreferences.reserveSpace
                    && !DockPreferences.autoHide
                        ? expandedHeight
                        : 0
                color: "transparent"
                focusable: false
                surfaceFormat.opaque: false

                anchors {
                    left: true
                    right: true
                    bottom: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "lumina-dock"

                mask: Region {
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

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: root.luminaDesign.motion.spatialDefault
                        easing.type: root.luminaDesign.motion.spatialEasing
                        easing.overshoot:
                            root.luminaDesign.motion.spatialOvershoot
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
                        panel.revealRequested = !DockPreferences.autoHide
                        hideTimer.stop()
                    }

                    function onEnabledChanged() {
                        if (!DockPreferences.enabled)
                            panel.revealRequested = !DockPreferences.autoHide
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
                                && !surfaceHover.hovered) {
                                hideTimer.restart()
                            }
                        }
                    }
                }

                ShellSurface {
                    id: dockSurface

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
                                && !revealHover.hovered) {
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
                                    LauncherStore.toggle(panel.outputName)

                                Keys.onSpacePressed: event => {
                                    LauncherStore.toggle(panel.outputName)
                                    event.accepted = true
                                }

                                Keys.onReturnPressed: event => {
                                    LauncherStore.toggle(panel.outputName)
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
                                                    root.luminaDesign.color.primary
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: launcherMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        launcherButton.forceActiveFocus(
                                            Qt.MouseFocusReason
                                        )
                                        LauncherStore.toggle(panel.outputName)
                                    }
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
                                    onActivated:
                                        DockStore.activate(modelData)
                                    onPinToggled:
                                        DockStore.togglePinned(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

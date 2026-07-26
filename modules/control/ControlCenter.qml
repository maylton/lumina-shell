pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.design
import qs.services.notifications
import qs.stores.config
import qs.stores.control
import qs.stores.settings
import qs.stores.time
import qs.stores.shell
import "ShellSurfacePolicy.js" as ShellSurfacePolicy
import "../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    IpcHandler {
        target: "control"

        function open(outputName: string): void {
            ControlCenterStore.openFor(outputName, "dashboard")
        }

        function close(): void {
            ControlCenterStore.close()
        }

        function toggle(outputName: string): void {
            ControlCenterStore.toggle(outputName)
        }

        function page(pageName: string): void {
            ControlCenterStore.setPage(pageName)
        }

        function tab(tabName: string): void {
            ControlCenterStore.setPage(tabName)
        }

        function status(): string {
            return JSON.stringify({
                open: ControlCenterStore.open,
                output: ControlCenterStore.activeOutputName,
                page: ControlCenterStore.activePage,
                tab: ControlCenterStore.activePage,
                settingsCategory:
                    ControlCenterStore.settingsCategory
            })
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: controlWindow

                required property var modelData
                readonly property string outputName:
                    modelData && modelData.name
                        ? String(modelData.name)
                        : ""
                readonly property bool centerVisible:
                    ControlCenterStore.activeOutputName === outputName
                readonly property real safeMargin:
                    root.luminaDesign.spacing.extraLarge
                readonly property real barWindowHeight:
                    SurfacePlacementPolicy.barWindowHeight(
                        ConfigStore.barHeight,
                        ConfigStore.barSurfaceMode,
                        ConfigStore.barMargin
                    )
                readonly property real panelScale:
                    ControlCenterStore.activePage === "settings"
                    ? 1
                    : Math.min(
                        1,
                        dashboardArea.width
                            / root.luminaDesign.size.controlDashboardMinimumWidth,
                        dashboardArea.height
                            / root.luminaDesign.size.controlDashboardMinimumHeight
                    )

                screen: modelData
                visible: centerVisible
                color: "transparent"
                surfaceFormat.opaque: false
                focusable: centerVisible
                exclusiveZone: 0

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lumina-control-center"
                WlrLayershell.keyboardFocus: centerVisible
          ? WlrKeyboardFocus.Exclusive
          : WlrKeyboardFocus.None

      BackgroundEffect.blurRegion:
          ShellSurfacePolicy.requestsBackdropBlur(
              ConfigStore.shellBackgroundMode
          )
              ? shellBlurRegion
              : null

      Region {
          id: shellBlurRegion

          Region {
              x: dashboardSurface.x
              y: dashboardSurface.y
              width: dashboardSurface.width
              height: dashboardSurface.height
              radius: dashboardSurface.radius
          }
      }

                onCenterVisibleChanged: {
                    if (centerVisible) {
                        NotificationService.markAllRead()
                        CalendarStore.goToToday()
                    }
                }

                FocusScope {
                    anchors.fill: parent
                    focus: controlWindow.centerVisible

                    Keys.onEscapePressed: event => {
                        if (SettingsStore.resetConfirmation)
                            SettingsStore.cancelReset()
                        else
                            ControlCenterStore.close()

                        event.accepted = true
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: root.luminaDesign.color.scrim

                    MouseArea {
                        anchors.fill: parent
                        enabled: ConfigStore.behaviorCloseOnOutside
                        onClicked: ControlCenterStore.close()
                    }
                }

                Item {
                    id: availableArea

                    anchors {
                        fill: parent
                        topMargin:
                            ConfigStore.barPosition === "top"
                                ? root.luminaDesign.size.barWindowHeight
                                    + root.luminaDesign.spacing.barPanelGap
                                : root.luminaDesign.spacing.barPanelGap
                        bottomMargin:
                            ConfigStore.barPosition === "bottom"
                                ? root.luminaDesign.size.barWindowHeight
                                    + root.luminaDesign.spacing.barPanelGap
                                : root.luminaDesign.spacing.barPanelGap
                        leftMargin: controlWindow.safeMargin
                        rightMargin: controlWindow.safeMargin
                    }
                }

                ShellSurface {
          id: dashboardSurface

                    x: SurfacePlacementPolicy.horizontalX(
                        OverlayStore.activePlacement,
                        OverlayStore.activeAnchorX,
                        width,
                        controlWindow.width,
                        controlWindow.safeMargin
                    )
                    y: SurfacePlacementPolicy.verticalY(
                        OverlayStore.activePlacement,
                        ConfigStore.barPosition,
                        height,
                        controlWindow.height,
                        controlWindow.barWindowHeight,
                        4,
                        controlWindow.safeMargin
                    )
                    width: Math.min(
                        root.luminaDesign.size.controlCenterWidth,
                        availableArea.width
                    )
                    height: Math.min(
                        root.luminaDesign.size.controlCenterHeight,
                        availableArea.height
                    )
                    radius: root.luminaDesign.shape.extraLarge
          clip: true

                    MouseArea {
                        anchors.fill: parent
                    }

                    Column {
                        anchors {
                            fill: parent
                            margins:
                                root.luminaDesign.spacing.controlContentInset
                        }

                        spacing: root.luminaDesign.spacing.controlItemGap

                        DashboardHeader {
                            width: parent.width
                            height: 52
                            outputName: controlWindow.outputName
                        }

                        ControlTabBar {
                            width: parent.width
                        }

                        Item {
                            id: dashboardArea

                            width: parent.width
                            height: parent.height
                                - 52
                                - 44
                                - parent.spacing * 2
                            clip: true

                            Item {
                                id: scaledContent

                                anchors.centerIn: parent
                                width: parent.width
                                    / controlWindow.panelScale
                                height: parent.height
                                    / controlWindow.panelScale
                                scale: controlWindow.panelScale

                                DashboardView {
                                    readonly property bool pageActive:
                                        ControlCenterStore.activePage
                                            === "dashboard"

                                    width: parent.width
                                    height: parent.height
                                    x: pageActive
                                        ? 0
                                        : -Math.min(
                                            48,
                                            Math.round(width * 0.04)
                                        )
                                    opacity: pageActive ? 1 : 0
                                    visible: pageActive || opacity > 0.01
                                    enabled: pageActive
                                    active: pageActive
                                    outputName:
                                        controlWindow.outputName

                                    Behavior on x {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.pageTransition
                                            easing.type:
                                                root.luminaDesign.motion.spatialEasing
                                            easing.overshoot:
                                                root.luminaDesign.motion.spatialOvershoot
                                        }
                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.effectsDefault
                                            easing.type:
                                                root.luminaDesign.motion.effectsEasing
                                        }
                                    }
                                }

                                ShellSettingsView {
                                    readonly property bool pageActive:
                                        ControlCenterStore.activePage
                                            === "settings"

                                    width: parent.width
                                    height: parent.height
                                    x: pageActive
                                        ? 0
                                        : Math.min(
                                            48,
                                            Math.round(width * 0.04)
                                        )
                                    opacity: pageActive ? 1 : 0
                                    visible: pageActive || opacity > 0.01
                                    enabled: pageActive
                                    active: pageActive
                                    outputName:
                                        controlWindow.outputName

                                    Behavior on x {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.pageTransition
                                            easing.type:
                                                root.luminaDesign.motion.spatialEasing
                                            easing.overshoot:
                                                root.luminaDesign.motion.spatialOvershoot
                                        }
                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.effectsDefault
                                            easing.type:
                                                root.luminaDesign.motion.effectsEasing
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

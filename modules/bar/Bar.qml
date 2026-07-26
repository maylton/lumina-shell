pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services.niri
import qs.stores.config
import qs.stores.niri
import "BarSurfacePolicy.js" as BarSurfacePolicy

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: panel

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property string storeOutputName: NiriService.demoMode
                    ? "demo"
                    : outputName
                readonly property var niriOutput: OutputStore.byName(storeOutputName)
                readonly property var visibleWorkspaces: NiriService.demoMode
                    ? WorkspaceStore.workspaces
                    : WorkspaceStore.forOutput(outputName)
                readonly property var activeWorkspace: WorkspaceStore.activeForOutput(storeOutputName)
                readonly property var activeWindow: activeWorkspace
                    ? WindowStore.byId(activeWorkspace.active_window_id)
                    : WindowStore.focusedWindow
                readonly property bool showActionError: NiriService.actionFeedbackVisible
                    && NiriService.lastActionError.length > 0
                readonly property string effectiveSurfaceMode:
                    ConfigStore.barSurfaceMode
                readonly property int effectiveMargin:
                    effectiveSurfaceMode === "floating"
                        ? ConfigStore.barMargin
                        : 0
                readonly property var blurGeometry:
                    BarSurfacePolicy.blurRegionGeometry(
                        width,
                        height,
                        effectiveSurfaceMode,
                        effectiveMargin,
                        barSurface.radius
                    )
                readonly property string activeWindowTitle: WindowStore.titleFor(activeWindow)
                readonly property string activeWindowAppId: WindowStore.appIdFor(activeWindow)
                readonly property string columnLabel: WindowStore.columnLabelFor(activeWindow)
                readonly property string activeWorkspaceLabel:
                    activeWorkspace
                        ? WorkspaceStore.labelFor(activeWorkspace)
                        : "Desktop"
                readonly property string outputSummary: {
                    const name = outputName || (niriOutput ? String(niriOutput.name) : "Output")

                    if (!niriOutput)
                        return name

                    const resolution = OutputStore.resolutionLabel(niriOutput)
                    const scale = OutputStore.scaleLabel(niriOutput)
                    var summary = name + " · " + resolution

                    if (scale)
                        summary += " · " + scale

                    return summary
                }

                screen: modelData
                implicitHeight: ConfigStore.barHeight
                    + (effectiveMargin * 2)
                exclusiveZone: implicitHeight
                color: "transparent"
                focusable: false
                surfaceFormat.opaque: false

                anchors {
                    top: ConfigStore.barPosition === "top"
                    bottom: ConfigStore.barPosition === "bottom"
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "lumina-bar"

                BackgroundEffect.blurRegion:
                    BarSurfacePolicy.requestsBackdropBlur(
                        ConfigStore.barBackgroundMode
                    )
                        ? barBlurRegion
                        : null

                Region {
                    id: barBlurRegion

                    Region {
                        x: panel.blurGeometry.x
                        y: panel.blurGeometry.y
                        width: panel.blurGeometry.width
                        height: panel.blurGeometry.height
                        radius: panel.blurGeometry.radius
                    }
                }

                BarSurface {
                    id: barSurface

                    anchors.fill: parent
                    outerMargin: panel.effectiveMargin
                    surfaceMode: panel.effectiveSurfaceMode
                    barPosition: ConfigStore.barPosition

                    BarLayout {
                        anchors.fill: parent
                        outputName: panel.outputName
                        visibleWorkspaces: panel.visibleWorkspaces
                        activeWindowTitle: panel.activeWindowTitle
                        activeWindowAppId: panel.activeWindowAppId
                        columnLabel: panel.columnLabel
                        workspaceLabel: panel.activeWorkspaceLabel
                        showActionError: panel.showActionError
                    }
                }
            }
        }
    }
}

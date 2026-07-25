pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services.niri
import qs.stores.config
import qs.stores.niri

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
                readonly property string activeWindowTitle: WindowStore.titleFor(activeWindow)
                readonly property string activeWindowAppId: WindowStore.appIdFor(activeWindow)
                readonly property string columnLabel: WindowStore.columnLabelFor(activeWindow)
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
                exclusiveZone: ConfigStore.barHeight
                color: "transparent"
                focusable: false

                anchors {
                    top: ConfigStore.barPosition === "top"
                    bottom: ConfigStore.barPosition === "bottom"
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "lumina-bar"

                BarSurface {
                    anchors.fill: parent
                    outerMargin: ConfigStore.barMargin

                    ClassicBarLayout {
                        anchors.fill: parent
                        outputName: panel.outputName
                        visibleWorkspaces: panel.visibleWorkspaces
                        activeWindowTitle: panel.activeWindowTitle
                        activeWindowAppId: panel.activeWindowAppId
                        columnLabel: panel.columnLabel
                        outputSummary: panel.outputSummary
                        showActionError: panel.showActionError
                    }
                }
            }
        }
    }
}

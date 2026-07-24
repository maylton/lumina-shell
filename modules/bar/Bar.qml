pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.design
import qs.services.niri
import qs.stores.niri

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    property string formattedTime: Qt.formatDateTime(clock.date, "HH:mm")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

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
                implicitHeight: root.luminaDesign.size.barHeight
                exclusiveZone: root.luminaDesign.size.barHeight
                color: "transparent"
                focusable: false

                anchors {
                    top: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "lumina-bar"

                Rectangle {
                    id: background

                    anchors {
                        fill: parent
                        margins: 5
                    }

                    radius: root.luminaDesign.shape.large
                    color: root.luminaDesign.color.surfaceContainer
                    border.width: 1
                    border.color: root.luminaDesign.color.outline

                    Row {
                        id: leftArea

                        anchors {
                            left: parent.left
                            leftMargin: root.luminaDesign.spacing.medium
                            verticalCenter: parent.verticalCenter
                        }

                        spacing: root.luminaDesign.spacing.small

                        Rectangle {
                            id: overviewButton

                            width: overviewLabel.implicitWidth + 20
                            height: root.luminaDesign.size.chipHeight
                            radius: NiriService.overviewOpen
                                ? root.luminaDesign.shape.full
                                : root.luminaDesign.shape.medium
                            scale: overviewMouse.pressed
                                ? 0.94
                                : overviewMouse.containsMouse
                                    ? 1.03
                                    : 1.0
                            color: NiriService.overviewOpen || overviewMouse.containsMouse
                                ? root.luminaDesign.color.accentContainer
                                : root.luminaDesign.color.surfaceMuted

                            Behavior on color {
                                ColorAnimation {
                                    duration: root.luminaDesign.motion.fast
                                }
                            }

                            Behavior on radius {
                                NumberAnimation {
                                    duration: root.luminaDesign.motion.medium
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: root.luminaDesign.motion.fast
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Text {
                                id: overviewLabel
                                anchors.centerIn: parent
                                text: NiriService.overviewOpen ? "Close overview" : "Overview"
                                color: NiriService.overviewOpen
                                    ? root.luminaDesign.color.onAccentContainer
                                    : root.luminaDesign.color.onSurface
                                font.pixelSize: root.luminaDesign.typography.labelMedium
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                id: overviewMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: NiriService.toggleOverview()
                            }
                        }

                        Repeater {
                            model: panel.visibleWorkspaces

                            delegate: Rectangle {
                                id: workspaceChip

                                required property var modelData

                                width: workspaceLabel.implicitWidth + 18
                                height: root.luminaDesign.size.chipHeight
                                radius: modelData.is_focused
                                    ? root.luminaDesign.shape.full
                                    : modelData.is_active
                                        ? root.luminaDesign.shape.large
                                        : root.luminaDesign.shape.small
                                scale: workspaceMouse.pressed
                                    ? 0.92
                                    : workspaceMouse.containsMouse
                                        ? 1.04
                                        : 1.0
                                color: modelData.is_focused || workspaceMouse.containsMouse
                                    ? root.luminaDesign.color.accentContainer
                                    : modelData.is_active
                                        ? root.luminaDesign.color.surfaceMuted
                                        : "transparent"
                                border.width: modelData.is_urgent ? 1 : 0
                                border.color: root.luminaDesign.color.urgent

                                Behavior on color {
                                    ColorAnimation {
                                        duration: root.luminaDesign.motion.fast
                                    }
                                }

                                Behavior on radius {
                                    NumberAnimation {
                                        duration: root.luminaDesign.motion.medium
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: root.luminaDesign.motion.fast
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Text {
                                    id: workspaceLabel
                                    anchors.centerIn: parent
                                    text: WorkspaceStore.labelFor(workspaceChip.modelData)
                                    color: workspaceChip.modelData.is_focused
                                        ? root.luminaDesign.color.onAccentContainer
                                        : workspaceChip.modelData.is_urgent
                                            ? root.luminaDesign.color.urgent
                                            : root.luminaDesign.color.textMuted
                                    font.pixelSize: root.luminaDesign.typography.labelMedium
                                    font.weight: workspaceChip.modelData.is_active
                                        ? Font.DemiBold
                                        : Font.Medium
                                }

                                MouseArea {
                                    id: workspaceMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: NiriService.focusWorkspace(workspaceChip.modelData)
                                }
                            }
                        }
                    }

                    Column {
                        id: focusedWindow

                        anchors.centerIn: parent
                        width: Math.max(
                            120,
                            background.width - leftArea.width - rightArea.width - 64
                        )
                        spacing: 0

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: panel.activeWindowTitle
                            color: root.luminaDesign.color.onSurface
                            elide: Text.ElideRight
                            font.pixelSize: root.luminaDesign.typography.bodyMedium
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: panel.activeWindowAppId
                            visible: text.length > 0
                            color: root.luminaDesign.color.textMuted
                            elide: Text.ElideRight
                            font.pixelSize: root.luminaDesign.typography.labelSmall
                        }
                    }

                    Row {
                        id: rightArea

                        anchors {
                            right: parent.right
                            rightMargin: root.luminaDesign.spacing.large
                            verticalCenter: parent.verticalCenter
                        }

                        spacing: root.luminaDesign.spacing.medium

                        Rectangle {
                            id: columnChip

                            visible: panel.columnLabel.length > 0
                            width: visible ? columnLabelText.implicitWidth + 18 : 0
                            height: root.luminaDesign.size.chipHeight
                            radius: root.luminaDesign.shape.full
                            color: root.luminaDesign.color.surfaceMuted
                            border.width: 1
                            border.color: root.luminaDesign.color.outline

                            Behavior on width {
                                NumberAnimation {
                                    duration: root.luminaDesign.motion.medium
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Text {
                                id: columnLabelText
                                anchors.centerIn: parent
                                text: panel.columnLabel
                                color: root.luminaDesign.color.onSurface
                                font.pixelSize: root.luminaDesign.typography.labelSmall
                                font.weight: Font.DemiBold
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0

                            Row {
                                spacing: root.luminaDesign.spacing.small

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: root.luminaDesign.size.statusDot
                                    height: root.luminaDesign.size.statusDot
                                    radius: width / 2
                                    color: NiriService.connected
                                        ? root.luminaDesign.color.primary
                                        : NiriService.demoMode
                                            ? root.luminaDesign.color.outline
                                            : root.luminaDesign.color.urgent

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: root.luminaDesign.motion.medium
                                        }
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: NiriService.demoMode
                                        ? "Demo"
                                        : NiriService.connected
                                            ? "Niri"
                                            : "Connecting"
                                    color: root.luminaDesign.color.textMuted
                                    font.pixelSize: root.luminaDesign.typography.labelSmall
                                    font.weight: Font.Medium
                                }
                            }

                            Text {
                                text: panel.outputSummary
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize: root.luminaDesign.typography.labelSmall
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.formattedTime
                            color: root.luminaDesign.color.onSurface
                            font.pixelSize: root.luminaDesign.typography.titleMedium
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }
        }
    }
}

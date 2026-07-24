pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.design
import qs.services.niri
import qs.stores.niri

Scope {
    id: root

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
                readonly property var visibleWorkspaces: NiriService.demoMode
                    ? WorkspaceStore.workspaces
                    : WorkspaceStore.forOutput(outputName)

                screen: modelData
                implicitHeight: Theme.barHeight
                exclusiveZone: Theme.barHeight
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

                    radius: Theme.radiusLarge
                    color: Theme.surfaceContainerColor
                    border.width: 1
                    border.color: Theme.outlineColor

                    Row {
                        id: leftArea

                        anchors {
                            left: parent.left
                            leftMargin: Theme.spacingMedium
                            verticalCenter: parent.verticalCenter
                        }

                        spacing: Theme.spacingSmall

                        Rectangle {
                            id: overviewButton

                            width: overviewLabel.implicitWidth + 20
                            height: 30
                            radius: Theme.radiusMedium
                            color: NiriService.overviewOpen || overviewMouse.containsMouse
                                ? Theme.accentContainerColor
                                : Theme.surfaceMutedColor

                            Text {
                                id: overviewLabel
                                anchors.centerIn: parent
                                text: NiriService.overviewOpen ? "Close overview" : "Overview"
                                color: NiriService.overviewOpen
                                    ? Theme.onAccentContainerColor
                                    : Theme.onSurfaceColor
                                font.pixelSize: 12
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
                                height: 30
                                radius: Theme.radiusMedium
                                color: modelData.is_focused || workspaceMouse.containsMouse
                                    ? Theme.accentContainerColor
                                    : modelData.is_active
                                        ? Theme.surfaceMutedColor
                                        : "transparent"
                                border.width: modelData.is_urgent ? 1 : 0
                                border.color: Theme.urgentColor

                                Text {
                                    id: workspaceLabel
                                    anchors.centerIn: parent
                                    text: WorkspaceStore.labelFor(workspaceChip.modelData)
                                    color: workspaceChip.modelData.is_focused
                                        ? Theme.onAccentContainerColor
                                        : workspaceChip.modelData.is_urgent
                                            ? Theme.urgentColor
                                            : Theme.textMutedColor
                                    font.pixelSize: 12
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
                            text: WindowStore.focusedTitle
                            color: Theme.onSurfaceColor
                            elide: Text.ElideRight
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: WindowStore.focusedAppId
                            visible: text.length > 0
                            color: Theme.textMutedColor
                            elide: Text.ElideRight
                            font.pixelSize: 10
                        }
                    }

                    Row {
                        id: rightArea

                        anchors {
                            right: parent.right
                            rightMargin: Theme.spacingLarge
                            verticalCenter: parent.verticalCenter
                        }

                        spacing: Theme.spacingMedium

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingSmall

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 8
                                height: 8
                                radius: 4
                                color: NiriService.connected
                                    ? Theme.primaryColor
                                    : NiriService.demoMode
                                        ? Theme.outlineColor
                                        : Theme.urgentColor
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: NiriService.demoMode
                                    ? "Demo"
                                    : NiriService.connected
                                        ? "Niri"
                                        : "Connecting"
                                color: Theme.textMutedColor
                                font.pixelSize: 11
                                font.weight: Font.Medium
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.formattedTime
                            color: Theme.onSurfaceColor
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }
        }
    }
}

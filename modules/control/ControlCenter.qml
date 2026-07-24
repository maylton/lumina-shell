pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.design
import qs.services.notifications
import qs.stores.control

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    IpcHandler {
        target: "control"

        function open(outputName: string): void {
            ControlCenterStore.openFor(outputName)
        }

        function close(): void {
            ControlCenterStore.close()
        }

        function toggle(outputName: string): void {
            ControlCenterStore.toggle(outputName)
        }

        function tab(tabName: string): void {
            ControlCenterStore.setTab(tabName)

            if (tabName === "notifications")
                NotificationService.markAllRead()
        }

        function status(): string {
            return JSON.stringify({
                open: ControlCenterStore.open,
                output: ControlCenterStore.activeOutputName,
                tab: ControlCenterStore.activeTab
            })
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: controlWindow

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property bool centerVisible:
                    ControlCenterStore.activeOutputName === outputName
                readonly property real safeMargin:
                    root.luminaDesign.spacing.extraLarge
                readonly property real panelScale: Math.min(
                    1,
                    dashboardArea.width / 1180,
                    dashboardArea.height / 650
                )

                screen: modelData
                visible: centerVisible
                color: "transparent"
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

                onCenterVisibleChanged: {
                    if (centerVisible)
                        NotificationService.markAllRead()
                }

                FocusScope {
                    anchors.fill: parent
                    focus: controlWindow.centerVisible

                    Keys.onEscapePressed: event => {
                        ControlCenterStore.close()
                        event.accepted = true
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: root.luminaDesign.color.scrim

                    MouseArea {
                        anchors.fill: parent
                        onClicked: ControlCenterStore.close()
                    }
                }

                Rectangle {
                    id: dashboardSurface

                    anchors.centerIn: parent
                    width: Math.min(
                        root.luminaDesign.size.controlCenterWidth,
                        controlWindow.width - controlWindow.safeMargin * 2
                    )
                    height: Math.min(
                        root.luminaDesign.size.controlCenterHeight,
                        controlWindow.height
                            - root.luminaDesign.size.barHeight
                            - controlWindow.safeMargin * 2
                    )
                    radius: root.luminaDesign.shape.extraLarge
                    color: root.luminaDesign.color.surfaceContainer
                    border.width: 1
                    border.color: root.luminaDesign.color.outline
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                    }

                    Column {
                        anchors {
                            fill: parent
                            margins: root.luminaDesign.spacing.extraLarge
                        }

                        spacing: root.luminaDesign.spacing.small

                        DashboardHeader {
                            width: parent.width
                            height: 52
                            outputName: controlWindow.outputName
                        }

                        Row {
                            id: tabBar

                            width: parent.width
                            height: 44
                            spacing: root.luminaDesign.spacing.medium

                            Repeater {
                                model: [
                                    {
                                        id: "home",
                                        symbol: "✦",
                                        label: "Dashboard"
                                    },
                                    {
                                        id: "notifications",
                                        symbol: "☷",
                                        label: "Notifications"
                                    }
                                ]

                                delegate: Rectangle {
                                    id: tabButton

                                    required property var modelData
                                    readonly property bool selected:
                                        ControlCenterStore.activeTab
                                            === modelData.id

                                    width: (
                                        tabBar.width - tabBar.spacing
                                    ) / 2
                                    height: tabBar.height
                                    color: "transparent"
                                    activeFocusOnTab: true

                                    Accessible.role: Accessible.PageTab
                                    Accessible.name: modelData.label
                                    Accessible.selected: selected
                                    Accessible.focusable: true
                                    Accessible.focused: activeFocus
                                    Accessible.onPressAction: activate()

                                    function activate() {
                                        ControlCenterStore.setTab(
                                            modelData.id
                                        )

                                        if (modelData.id === "notifications")
                                            NotificationService.markAllRead()
                                    }

                                    Keys.onSpacePressed: event => {
                                        activate()
                                        event.accepted = true
                                    }

                                    Keys.onReturnPressed: event => {
                                        activate()
                                        event.accepted = true
                                    }

                                    Row {
                                        anchors.centerIn: parent
                                        spacing:
                                            root.luminaDesign.spacing.small

                                        Text {
                                            text: tabButton.modelData.symbol
                                            color: tabButton.selected
                                                ? root.luminaDesign.color.primary
                                                : root.luminaDesign.color.textMuted
                                            font.pixelSize: 16
                                            font.weight: Font.Bold
                                        }

                                        Text {
                                            text: tabButton.modelData.label
                                            color: tabButton.selected
                                                ? root.luminaDesign.color.onSurface
                                                : root.luminaDesign.color.textMuted
                                            font.pixelSize:
                                                root.luminaDesign.typography.bodyMedium
                                            font.weight: tabButton.selected
                                                ? Font.Bold
                                                : Font.Medium
                                        }
                                    }

                                    Rectangle {
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            bottom: parent.bottom
                                        }

                                        height: tabButton.selected ? 3 : 1
                                        radius: root.luminaDesign.shape.full
                                        color: tabButton.selected
                                            ? root.luminaDesign.color.primary
                                            : root.luminaDesign.color.outline
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            tabButton.forceActiveFocus(
                                                Qt.MouseFocusReason
                                            )
                                            tabButton.activate()
                                        }
                                    }
                                }
                            }
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
                                id: scaledDashboard

                                anchors.centerIn: parent
                                width: parent.width / controlWindow.panelScale
                                height: parent.height
                                    / controlWindow.panelScale
                                scale: controlWindow.panelScale

                                Item {
                                    anchors.fill: parent
                                    visible:
                                        ControlCenterStore.activeTab === "home"

                                    Item {
                                        id: leftColumn

                                        anchors {
                                            left: parent.left
                                            top: parent.top
                                            bottom: parent.bottom
                                        }

                                        width: (parent.width
                                            - root.luminaDesign.spacing.medium * 2)
                                            * 0.27

                                        DashboardOverview {
                                            id: overview

                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                top: parent.top
                                            }

                                            height: parent.height * 0.45
                                            outputName:
                                                controlWindow.outputName
                                        }

                                        DashboardControls {
                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                top: overview.bottom
                                                bottom: parent.bottom
                                                topMargin:
                                                    root.luminaDesign.spacing.medium
                                            }
                                        }
                                    }

                                    DashboardNotifications {
                                        id: homeNotifications

                                        anchors {
                                            left: leftColumn.right
                                            top: parent.top
                                            bottom: parent.bottom
                                            leftMargin:
                                                root.luminaDesign.spacing.medium
                                        }

                                        width: (parent.width
                                            - root.luminaDesign.spacing.medium * 2)
                                            * 0.41
                                        compact: true
                                    }

                                    Item {
                                        anchors {
                                            left: homeNotifications.right
                                            right: parent.right
                                            top: parent.top
                                            bottom: parent.bottom
                                            leftMargin:
                                                root.luminaDesign.spacing.medium
                                        }

                                        DashboardMedia {
                                            id: mediaCard

                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                top: parent.top
                                            }

                                            height: parent.height * 0.29
                                        }

                                        DashboardStatus {
                                            id: statusCard

                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                top: mediaCard.bottom
                                                topMargin:
                                                    root.luminaDesign.spacing.medium
                                            }

                                            height: parent.height * 0.29
                                        }

                                        DashboardCalendar {
                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                top: statusCard.bottom
                                                bottom: parent.bottom
                                                topMargin:
                                                    root.luminaDesign.spacing.medium
                                            }
                                        }
                                    }
                                }

                                Item {
                                    anchors.fill: parent
                                    visible:
                                        ControlCenterStore.activeTab
                                            === "notifications"

                                    DashboardNotifications {
                                        id: expandedNotifications

                                        anchors {
                                            left: parent.left
                                            top: parent.top
                                            bottom: parent.bottom
                                        }

                                        width: parent.width * 0.66
                                    }

                                    Item {
                                        anchors {
                                            left: expandedNotifications.right
                                            right: parent.right
                                            top: parent.top
                                            bottom: parent.bottom
                                            leftMargin:
                                                root.luminaDesign.spacing.medium
                                        }

                                        DashboardControls {
                                            id: notificationControls

                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                top: parent.top
                                            }

                                            height: parent.height * 0.54
                                        }

                                        DashboardStatus {
                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                top: notificationControls.bottom
                                                bottom: parent.bottom
                                                topMargin:
                                                    root.luminaDesign.spacing.medium
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
}

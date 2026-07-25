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
                readonly property real panelScale:
                    ControlCenterStore.activePage === "settings"
                    ? 1
                    : Math.min(
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

                Rectangle {
                    id: dashboardSurface

                    anchors.centerIn: availableArea
                    width: Math.min(
                        root.luminaDesign.size.controlCenterWidth,
                        availableArea.width
                    )
                    height: Math.min(
                        root.luminaDesign.size.controlCenterHeight,
                        availableArea.height
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
                                        : -Math.round(width * 0.06)
                                    opacity: pageActive ? 1 : 0
                                    visible: pageActive || opacity > 0.01
                                    enabled: pageActive
                                    active: pageActive
                                    outputName:
                                        controlWindow.outputName

                                    Behavior on x {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.medium
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.fast
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
                                        : Math.round(width * 0.06)
                                    opacity: pageActive ? 1 : 0
                                    visible: pageActive || opacity > 0.01
                                    enabled: pageActive
                                    active: pageActive
                                    outputName:
                                        controlWindow.outputName

                                    Behavior on x {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.medium
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.fast
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

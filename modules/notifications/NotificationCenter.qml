pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.design
import qs.services.notifications
import qs.stores.config

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    IpcHandler {
        target: "notifications"

        function toggle(outputName: string): void {
            NotificationService.toggleCenter(outputName)
        }

        function close(): void {
            NotificationService.closeCenter()
        }

        function dnd(enabled: bool): void {
            NotificationService.setDoNotDisturb(enabled)
        }

        function clear(): void {
            NotificationService.clearHistory()
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: centerWindow

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property bool centerVisible:
                    NotificationService.centerOutputName === outputName

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
                WlrLayershell.namespace: "lumina-notification-center"
                WlrLayershell.keyboardFocus: centerVisible
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                FocusScope {
                    anchors.fill: parent
                    focus: centerWindow.centerVisible

                    Keys.onEscapePressed: event => {
                        NotificationService.closeCenter()
                        event.accepted = true
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: root.luminaDesign.color.scrim

                    MouseArea {
                        anchors.fill: parent
                        onClicked: NotificationService.closeCenter()
                    }
                }

                Rectangle {
                    id: centerSurface

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                        topMargin:
                            ConfigStore.barPosition === "top"
                                ? root.luminaDesign.size.barWindowHeight
                                    + root.luminaDesign.spacing.barPanelGap
                                : root.luminaDesign.spacing.barPanelGap
                        rightMargin: root.luminaDesign.spacing.medium
                        bottomMargin:
                            ConfigStore.barPosition === "bottom"
                                ? root.luminaDesign.size.barWindowHeight
                                    + root.luminaDesign.spacing.barPanelGap
                                : root.luminaDesign.spacing.barPanelGap
                    }

                    width: Math.min(
                        root.luminaDesign.size.notificationCenterWidth,
                        centerWindow.width - root.luminaDesign.spacing.extraLarge * 2
                    )
                    radius: root.luminaDesign.shape.extraLarge
                    color: root.luminaDesign.color.surfaceContainer
                    border.width: 1
                    border.color: root.luminaDesign.color.outline

                    MouseArea {
                        anchors.fill: parent
                    }

                    Column {
                        anchors {
                            fill: parent
                            margins: root.luminaDesign.spacing.extraLarge
                        }

                        spacing: root.luminaDesign.spacing.medium

                        Row {
                            width: parent.width
                            height: 34
                            spacing: root.luminaDesign.spacing.small

                            Text {
                                width: parent.width
                                    - dndButton.width
                                    - clearButton.width
                                    - parent.spacing * 2
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Notifications"
                                color: root.luminaDesign.color.onSurface
                                font.pixelSize: root.luminaDesign.typography.titleLarge
                                font.weight: Font.DemiBold
                            }

                            Rectangle {
                                id: dndButton

                                width: dndLabel.implicitWidth + 18
                                height: 30
                                radius: root.luminaDesign.shape.full
                                color: NotificationService.doNotDisturb
                                    ? root.luminaDesign.color.accentContainer
                                    : root.luminaDesign.color.surfaceMuted

                                Text {
                                    id: dndLabel

                                    anchors.centerIn: parent
                                    text: NotificationService.doNotDisturb
                                        ? "DND on"
                                        : "DND off"
                                    color: NotificationService.doNotDisturb
                                        ? root.luminaDesign.color.onAccentContainer
                                        : root.luminaDesign.color.onSurface
                                    font.pixelSize: root.luminaDesign.typography.labelSmall
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked:
                                        NotificationService.toggleDoNotDisturb()
                                }
                            }

                            Rectangle {
                                id: clearButton

                                width: clearLabel.implicitWidth + 18
                                height: 30
                                radius: root.luminaDesign.shape.full
                                color: clearMouse.containsMouse
                                    ? root.luminaDesign.color.accentContainer
                                    : root.luminaDesign.color.surfaceMuted

                                Text {
                                    id: clearLabel

                                    anchors.centerIn: parent
                                    text: "Clear"
                                    color: clearMouse.containsMouse
                                        ? root.luminaDesign.color.onAccentContainer
                                        : root.luminaDesign.color.onSurface
                                    font.pixelSize:
                                        root.luminaDesign.typography.labelSmall
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    id: clearMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: NotificationService.history.length > 0
                                    onClicked: NotificationService.clearHistory()
                                }
                            }
                        }

                        ListView {
                            id: historyList

                            width: parent.width
                            height: parent.height - 34 - parent.spacing
                            spacing: root.luminaDesign.spacing.medium
                            clip: true
                            model: ScriptModel {
                                values: NotificationService.history
                            }

                            delegate: NotificationCard {
                                required property var modelData

                                width: historyList.width
                                entry: modelData
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: NotificationService.history.length === 0
                                text: NotificationService.doNotDisturb
                                    ? "Do Not Disturb is on\nNew alerts stay quiet"
                                    : "No notifications yet"
                                horizontalAlignment: Text.AlignHCenter
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize:
                                    root.luminaDesign.typography.bodyMedium
                            }
                        }
                    }
                }
            }
        }
    }
}

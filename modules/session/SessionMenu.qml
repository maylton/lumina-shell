pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.design
import qs.services.niri
import qs.services.session
import qs.stores.session

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var layoutActions: [
        {
            id: "focus-left",
            title: "Focus left",
            description: "Previous column",
            symbol: "←"
        },
        {
            id: "focus-right",
            title: "Focus right",
            description: "Next column",
            symbol: "→"
        },
        {
            id: "center",
            title: "Center",
            description: "Center current column",
            symbol: "◎"
        },
        {
            id: "move-left",
            title: "Move left",
            description: "Reorder current column",
            symbol: "⇤"
        },
        {
            id: "move-right",
            title: "Move right",
            description: "Reorder current column",
            symbol: "⇥"
        },
        {
            id: "width",
            title: "Column width",
            description: "Cycle preset width",
            symbol: "↔"
        },
        {
            id: "floating",
            title: "Floating",
            description: "Toggle focused window",
            symbol: "◇"
        },
        {
            id: "fullscreen",
            title: "Fullscreen",
            description: "Toggle focused window",
            symbol: "□"
        },
        {
            id: "tabbed",
            title: "Tabbed",
            description: "Toggle column display",
            symbol: "▤"
        }
    ]
    readonly property var sessionActions: [
        {
            id: "lock",
            title: "Lock",
            description: "Lock this session",
            symbol: "●",
            destructive: false
        },
        {
            id: "suspend",
            title: "Suspend",
            description: "Sleep this computer",
            symbol: "◐",
            destructive: false
        },
        {
            id: "logout",
            title: "Log out",
            description: "Exit Niri",
            symbol: "↪",
            destructive: true
        },
        {
            id: "reboot",
            title: "Restart",
            description: "Restart the system",
            symbol: "↻",
            destructive: true
        },
        {
            id: "poweroff",
            title: "Power off",
            description: "Shut down the system",
            symbol: "⏻",
            destructive: true
        }
    ]

    function invokeLayout(actionId) {
        switch (String(actionId)) {
        case "focus-left":
            NiriService.focusColumnLeft()
            break
        case "focus-right":
            NiriService.focusColumnRight()
            break
        case "center":
            NiriService.centerColumn()
            break
        case "move-left":
            NiriService.moveColumnLeft()
            break
        case "move-right":
            NiriService.moveColumnRight()
            break
        case "width":
            NiriService.switchPresetColumnWidth()
            break
        case "floating":
            NiriService.toggleFloating()
            break
        case "fullscreen":
            NiriService.toggleFullscreen()
            break
        case "tabbed":
            NiriService.toggleTabbedDisplay()
            break
        default:
            break
        }
    }

    IpcHandler {
        target: "session"

        function open(outputName: string): void {
            SessionMenuStore.openFor(outputName)
        }

        function close(): void {
            SessionService.cancel()
            SessionMenuStore.close()
        }

        function toggle(outputName: string): void {
            const targetOutput = SessionMenuStore.resolvedOutputName(outputName)

            if (SessionMenuStore.activeOutputName === targetOutput) {
                SessionService.cancel()
                SessionMenuStore.close()
            } else {
                SessionMenuStore.openFor(targetOutput)
            }
        }

        function request(actionName: string): void {
            SessionService.request(actionName)
        }

        function layout(actionName: string): void {
            root.invokeLayout(actionName)
        }

        function cancel(): void {
            SessionService.cancel()
        }

        function describe(actionName: string): string {
            return JSON.stringify({
                action: actionName,
                label: SessionService.actionLabel(actionName),
                description: SessionService.actionDescription(actionName),
                command: SessionService.commandDescription(actionName)
            })
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: sessionWindow

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property bool menuVisible:
                    SessionMenuStore.activeOutputName === outputName

                screen: modelData
                visible: menuVisible
                color: "transparent"
                focusable: menuVisible
                exclusiveZone: 0

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lumina-session-menu"
                WlrLayershell.keyboardFocus: menuVisible
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                FocusScope {
                    anchors.fill: parent
                    focus: sessionWindow.menuVisible

                    Keys.onEscapePressed: event => {
                        if (SessionService.pendingAction)
                            SessionService.cancel()
                        else
                            SessionMenuStore.close()

                        event.accepted = true
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: root.luminaDesign.color.scrim

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            SessionService.cancel()
                            SessionMenuStore.close()
                        }
                    }
                }

                Rectangle {
                    id: menuSurface

                    anchors.centerIn: parent
                    width: Math.min(
                        root.luminaDesign.size.sessionMenuWidth,
                        sessionWindow.width - root.luminaDesign.spacing.extraLarge * 2
                    )
                    height: Math.min(
                        root.luminaDesign.size.sessionMenuHeight,
                        sessionWindow.height - root.luminaDesign.spacing.extraLarge * 2
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

                        Text {
                            text: "Niri layout"
                            color: root.luminaDesign.color.onSurface
                            font.pixelSize: root.luminaDesign.typography.titleLarge
                            font.weight: Font.DemiBold
                        }

                        Grid {
                            width: parent.width
                            columns: 3
                            columnSpacing: root.luminaDesign.spacing.small
                            rowSpacing: root.luminaDesign.spacing.small

                            Repeater {
                                model: root.layoutActions

                                delegate: SessionAction {
                                    required property var modelData

                                    width: (
                                        parent.width
                                        - parent.columnSpacing * 2
                                    ) / 3
                                    title: String(modelData.title)
                                    description: String(modelData.description)
                                    symbol: String(modelData.symbol)
                                    onActivated:
                                        root.invokeLayout(modelData.id)
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: root.luminaDesign.color.outline
                            opacity: 0.45
                        }

                        Text {
                            text: "Session"
                            color: root.luminaDesign.color.onSurface
                            font.pixelSize: root.luminaDesign.typography.titleMedium
                            font.weight: Font.DemiBold
                        }

                        Grid {
                            width: parent.width
                            columns: 3
                            columnSpacing: root.luminaDesign.spacing.small
                            rowSpacing: root.luminaDesign.spacing.small

                            Repeater {
                                model: root.sessionActions

                                delegate: SessionAction {
                                    required property var modelData

                                    width: (
                                        parent.width
                                        - parent.columnSpacing * 2
                                    ) / 3
                                    title: String(modelData.title)
                                    description: String(modelData.description)
                                    symbol: String(modelData.symbol)
                                    destructive:
                                        Boolean(modelData.destructive)
                                    onActivated:
                                        SessionService.request(modelData.id)
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: SessionService.pendingAction.length > 0
                        z: 10
                        radius: parent.radius
                        color: root.luminaDesign.color.surfaceContainer

                        Column {
                            anchors {
                                centerIn: parent
                            }

                            width: Math.min(parent.width - 64, 420)
                            spacing: root.luminaDesign.spacing.large

                            Text {
                                width: parent.width
                                text: SessionService.actionLabel(
                                    SessionService.pendingAction
                                ) + "?"
                                horizontalAlignment: Text.AlignHCenter
                                color: root.luminaDesign.color.onSurface
                                font.pixelSize:
                                    root.luminaDesign.typography.titleLarge
                                font.weight: Font.DemiBold
                            }

                            Text {
                                width: parent.width
                                text: SessionService.actionDescription(
                                    SessionService.pendingAction
                                )
                                horizontalAlignment: Text.AlignHCenter
                                color: root.luminaDesign.color.textMuted
                                wrapMode: Text.Wrap
                                font.pixelSize:
                                    root.luminaDesign.typography.bodyMedium
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: root.luminaDesign.spacing.medium

                                Rectangle {
                                    width: cancelLabel.implicitWidth + 24
                                    height: 36
                                    radius: root.luminaDesign.shape.full
                                    color: root.luminaDesign.color.surfaceMuted

                                    Text {
                                        id: cancelLabel

                                        anchors.centerIn: parent
                                        text: "Cancel"
                                        color:
                                            root.luminaDesign.color.onSurface
                                        font.pixelSize:
                                            root.luminaDesign.typography.labelMedium
                                        font.weight: Font.DemiBold
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: SessionService.cancel()
                                    }
                                }

                                Rectangle {
                                    width: confirmLabel.implicitWidth + 24
                                    height: 36
                                    radius: root.luminaDesign.shape.full
                                    color: root.luminaDesign.color.urgent

                                    Text {
                                        id: confirmLabel

                                        anchors.centerIn: parent
                                        text: "Confirm"
                                        color:
                                            root.luminaDesign.color.surfaceBase
                                        font.pixelSize:
                                            root.luminaDesign.typography.labelMedium
                                        font.weight: Font.Bold
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            SessionService.confirm()
                                            SessionMenuStore.close()
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

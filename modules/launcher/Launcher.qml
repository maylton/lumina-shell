pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.design
import qs.stores.launcher

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    IpcHandler {
        target: "launcher"

        function open(outputName: string): void {
            LauncherStore.openFor(outputName)
        }

        function close(): void {
            LauncherStore.close()
        }

        function toggle(outputName: string): void {
            LauncherStore.toggle(outputName)
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: launcherWindow

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property bool launcherVisible: LauncherStore.open
                    && LauncherStore.activeOutputName === outputName

                screen: modelData
                visible: launcherVisible
                color: "transparent"
                focusable: launcherVisible
                exclusiveZone: 0

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lumina-launcher"
                WlrLayershell.keyboardFocus: launcherVisible
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                onVisibleChanged: {
                    if (visible) {
                        Qt.callLater(function() {
                            queryInput.forceActiveFocus()
                        })
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: root.luminaDesign.color.scrim

                    MouseArea {
                        anchors.fill: parent
                        onClicked: LauncherStore.close()
                    }
                }

                Rectangle {
                    id: launcherSurface

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: Math.max(
                            root.luminaDesign.spacing.extraLarge * 4,
                            parent.height * 0.12
                        )
                    }

                    width: Math.min(
                        root.luminaDesign.size.launcherWidth,
                        launcherWindow.width - root.luminaDesign.spacing.extraLarge * 2
                    )
                    height: Math.min(
                        root.luminaDesign.size.launcherHeight,
                        launcherWindow.height - anchors.topMargin
                            - root.luminaDesign.spacing.extraLarge * 2
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

                        Rectangle {
                            width: parent.width
                            height: 48
                            radius: root.luminaDesign.shape.full
                            color: root.luminaDesign.color.surfaceMuted
                            border.width: queryInput.activeFocus ? 2 : 1
                            border.color: queryInput.activeFocus
                                ? root.luminaDesign.color.primary
                                : root.luminaDesign.color.outline

                            Text {
                                anchors {
                                    left: parent.left
                                    leftMargin: root.luminaDesign.spacing.large
                                    verticalCenter: parent.verticalCenter
                                }

                                text: "⌕"
                                color: root.luminaDesign.color.primary
                                font.pixelSize: root.luminaDesign.typography.titleLarge
                            }

                            TextInput {
                                id: queryInput

                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    leftMargin: 44
                                    rightMargin: root.luminaDesign.spacing.large
                                    verticalCenter: parent.verticalCenter
                                }

                                text: LauncherStore.query
                                color: root.luminaDesign.color.onSurface
                                selectionColor: root.luminaDesign.color.accentContainer
                                selectedTextColor: root.luminaDesign.color.onAccentContainer
                                clip: true
                                font.pixelSize: root.luminaDesign.typography.titleMedium

                                onTextEdited: LauncherStore.setQuery(text)

                                Keys.onEscapePressed: event => {
                                    LauncherStore.close()
                                    event.accepted = true
                                }

                                Keys.onDownPressed: event => {
                                    LauncherStore.selectNext()
                                    resultList.positionViewAtIndex(
                                        LauncherStore.selectedIndex,
                                        ListView.Contain
                                    )
                                    event.accepted = true
                                }

                                Keys.onUpPressed: event => {
                                    LauncherStore.selectPrevious()
                                    resultList.positionViewAtIndex(
                                        LauncherStore.selectedIndex,
                                        ListView.Contain
                                    )
                                    event.accepted = true
                                }

                                Keys.onReturnPressed: event => {
                                    LauncherStore.executeSelected()
                                    event.accepted = true
                                }
                            }

                            Text {
                                anchors {
                                    left: queryInput.left
                                    verticalCenter: parent.verticalCenter
                                }

                                visible: queryInput.text.length === 0
                                text: "Search apps, windows, and shell actions"
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize: root.luminaDesign.typography.titleMedium
                            }
                        }

                        ListView {
                            id: resultList

                            width: parent.width
                            height: parent.height - 48 - parent.spacing - footer.height
                            spacing: root.luminaDesign.spacing.extraSmall
                            clip: true
                            model: ScriptModel {
                                values: LauncherStore.results
                            }

                            delegate: LauncherResult {
                                required property var modelData
                                required property int index

                                width: resultList.width
                                result: modelData
                                selected: index === LauncherStore.selectedIndex
                                onActivated: LauncherStore.execute(modelData)
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: LauncherStore.results.length === 0
                                text: "No matching apps, windows, or actions"
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize: root.luminaDesign.typography.bodyMedium
                            }
                        }

                        Row {
                            id: footer

                            width: parent.width
                            height: 22
                            spacing: root.luminaDesign.spacing.medium

                            Text {
                                text: "↑↓ Navigate"
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize: root.luminaDesign.typography.labelSmall
                            }

                            Text {
                                text: "Enter Open"
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize: root.luminaDesign.typography.labelSmall
                            }

                            Text {
                                text: "Esc Close"
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize: root.luminaDesign.typography.labelSmall
                            }
                        }
                    }
                }
            }
        }
    }
}

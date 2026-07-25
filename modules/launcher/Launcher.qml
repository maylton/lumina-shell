pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.design
import qs.modules.control
import qs.modules.dock
import qs.services.i18n
import qs.stores.config
import qs.stores.dock
import qs.stores.launcher
import "../control/ShellSurfacePolicy.js" as ShellSurfacePolicy

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

        function status(): string {
            return JSON.stringify({
                open: LauncherStore.open,
                outputName: LauncherStore.activeOutputName,
                query: LauncherStore.query,
                applicationCount: LauncherStore.applications.length,
                resultCount: LauncherStore.results.length
            })
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: launcherWindow

                required property var modelData

                readonly property string outputName:
                    modelData && modelData.name
                        ? String(modelData.name)
                        : ""
                readonly property bool launcherVisible: LauncherStore.open
                    && LauncherStore.activeOutputName === outputName

                property var contextResult: null
                property string contextIdentifier: ""
                property real contextMenuX: 0
                property real contextMenuY: 0

                function closePinMenu(restoreSearchFocus) {
                    pinMenu.close()
                    contextResult = null
                    contextIdentifier = ""

                    if (restoreSearchFocus && launcherVisible) {
                        Qt.callLater(function() {
                            queryInput.forceActiveFocus()
                        })
                    }
                }

                function openPinMenu(result, sourceItem) {
                    if (!result
                        || result.kind !== "application"
                        || !result.entry
                        || !sourceItem) {
                        return
                    }

                    const identifier = DockStore.entryIdentifier(
                        result.entry,
                        ""
                    )
                    if (!identifier)
                        return

                    const sourcePoint = sourceItem.mapToItem(
                        launcherSurface,
                        0,
                        0
                    )
                    const gap = root.luminaDesign.spacing.small
                    const edge = root.luminaDesign.spacing.small
                    const belowY = sourcePoint.y
                        + sourceItem.height
                        + gap
                    const aboveY = sourcePoint.y
                        - pinMenu.height
                        - gap

                    contextResult = result
                    contextIdentifier = identifier
                    contextMenuX = Math.max(
                        edge,
                        Math.min(
                            launcherSurface.width - pinMenu.width - edge,
                            sourcePoint.x + sourceItem.width
                                - pinMenu.width
                        )
                    )
                    contextMenuY = belowY + pinMenu.height
                        <= launcherSurface.height - edge
                            ? belowY
                            : Math.max(edge, aboveY)
                    pinMenu.open()
                }

                screen: modelData
                visible: launcherVisible
                color: "transparent"
                surfaceFormat.opaque: false
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

                BackgroundEffect.blurRegion:
                    ShellSurfacePolicy.requestsBackdropBlur(
                        ConfigStore.shellBackgroundMode
                    )
                        ? shellBlurRegion
                        : null

                Region {
                    id: shellBlurRegion

                    Region {
                        x: launcherSurface.x
                        y: launcherSurface.y
                        width: launcherSurface.width
                        height: launcherSurface.height
                        radius: launcherSurface.radius
                    }
                }

                onVisibleChanged: {
                    if (visible) {
                        Qt.callLater(function() {
                            queryInput.forceActiveFocus()
                        })
                    } else {
                        closePinMenu(false)
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

                ShellSurface {
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
                        launcherWindow.width
                            - root.luminaDesign.spacing.extraLarge * 2
                    )
                    height: Math.min(
                        root.luminaDesign.size.launcherHeight,
                        launcherWindow.height
                            - anchors.topMargin
                            - root.luminaDesign.spacing.extraLarge * 2
                    )
                    radius: root.luminaDesign.shape.extraLarge

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
                                    leftMargin:
                                        root.luminaDesign.spacing.large
                                    verticalCenter: parent.verticalCenter
                                }

                                text: "⌕"
                                color: root.luminaDesign.color.primary
                                font.pixelSize:
                                    root.luminaDesign.typography.titleLarge
                            }

                            TextInput {
                                id: queryInput

                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    leftMargin: 44
                                    rightMargin:
                                        root.luminaDesign.spacing.large
                                    verticalCenter: parent.verticalCenter
                                }

                                text: LauncherStore.query
                                color: root.luminaDesign.color.onSurface
                                selectionColor:
                                    root.luminaDesign.color.accentContainer
                                selectedTextColor:
                                    root.luminaDesign.color.onAccentContainer
                                clip: true
                                font.pixelSize:
                                    root.luminaDesign.typography.titleMedium

                                onTextEdited: {
                                    launcherWindow.closePinMenu(false)
                                    LauncherStore.setQuery(text)
                                }

                                Keys.onEscapePressed: event => {
                                    if (pinMenu.opened) {
                                        launcherWindow.closePinMenu(true)
                                    } else {
                                        LauncherStore.close()
                                    }
                                    event.accepted = true
                                }

                                Keys.onDownPressed: event => {
                                    launcherWindow.closePinMenu(false)
                                    LauncherStore.selectNext()
                                    resultList.positionViewAtIndex(
                                        LauncherStore.selectedIndex,
                                        ListView.Contain
                                    )
                                    event.accepted = true
                                }

                                Keys.onUpPressed: event => {
                                    launcherWindow.closePinMenu(false)
                                    LauncherStore.selectPrevious()
                                    resultList.positionViewAtIndex(
                                        LauncherStore.selectedIndex,
                                        ListView.Contain
                                    )
                                    event.accepted = true
                                }

                                Keys.onReturnPressed: event => {
                                    launcherWindow.closePinMenu(false)
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
                                text: I18n.tr(
                                    "launcher.search.placeholder",
                                    "Search apps, windows, and shell actions"
                                )
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize:
                                    root.luminaDesign.typography.titleMedium
                            }
                        }

                        ListView {
                            id: resultList

                            width: parent.width
                            height: parent.height
                                - 48
                                - parent.spacing
                                - footer.height
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
                                selected:
                                    index === LauncherStore.selectedIndex
                                onActivated: {
                                    launcherWindow.closePinMenu(false)
                                    LauncherStore.execute(modelData)
                                }
                                onContextMenuRequested: sourceItem => {
                                    LauncherStore.selectedIndex = index
                                    launcherWindow.openPinMenu(
                                        modelData,
                                        sourceItem
                                    )
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: LauncherStore.results.length === 0
                                text: I18n.tr(
                                    "launcher.empty",
                                    "No matching apps, windows, or actions"
                                )
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize:
                                    root.luminaDesign.typography.bodyMedium
                            }
                        }

                        Row {
                            id: footer

                            width: parent.width
                            height: 22
                            spacing: root.luminaDesign.spacing.medium

                            Text {
                                text: I18n.tr(
                                    "launcher.hint.navigate",
                                    "↑↓ Navigate"
                                )
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize:
                                    root.luminaDesign.typography.labelSmall
                            }

                            Text {
                                text: I18n.tr(
                                    "launcher.hint.open",
                                    "Enter Open"
                                )
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize:
                                    root.luminaDesign.typography.labelSmall
                            }

                            Text {
                                text: I18n.tr(
                                    "launcher.hint.close",
                                    "Esc Close"
                                )
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize:
                                    root.luminaDesign.typography.labelSmall
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        z: 10
                        visible: pinMenu.opened
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: launcherWindow.closePinMenu(true)
                    }

                    DockPinMenu {
                        id: pinMenu

                        z: 11
                        x: launcherWindow.contextMenuX
                        y: launcherWindow.contextMenuY
                        pinned: DockStore.isPinnedIdentifier(
                            launcherWindow.contextIdentifier
                        )
                        applicationTitle: launcherWindow.contextResult
                            ? String(
                                launcherWindow.contextResult.title || ""
                            )
                            : ""
                        onActionTriggered: {
                            DockStore.togglePinnedIdentifier(
                                launcherWindow.contextIdentifier
                            )
                            launcherWindow.closePinMenu(true)
                        }
                        onCloseRequested:
                            launcherWindow.closePinMenu(true)
                    }
                }
            }
        }
    }
}

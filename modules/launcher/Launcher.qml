pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.design
import qs.modules.bar.widgets
import qs.modules.control
import qs.modules.dock
import qs.services.i18n
import qs.stores.config
import qs.stores.dock
import qs.stores.launcher
import qs.stores.shell
import "../../services/i18n/LauncherStrings.js" as LauncherStrings
import "../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    Connections {
        target: BarPanelCoordinator

        function onOpenRequested(
            panelId,
            outputName,
            placement,
            anchorX,
            anchorTop,
            anchorBottom,
            anchorEdge
        ) {
            if (panelId !== "launcher")
                return

            OverlayStore.prepareFor(
                "launcher",
                outputName,
                placement,
                anchorX,
                anchorTop,
                anchorBottom,
                anchorEdge
            )
            LauncherStore.openFor(outputName)
        }

        function onCloseRequested(panelId, outputName) {
            if (panelId !== "launcher")
                return

            if (LauncherStore.open
                && LauncherStore.activeOutputName === outputName) {
                LauncherStore.close()
            } else {
                BarPanelCoordinator.reportClosed("launcher", outputName)
            }
        }
    }

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
                favoriteCount: LauncherStore.favoriteResults.length,
                resultCount: LauncherStore.results.length
            })
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            BarPanelWindow {
                id: launcherWindow

                required property var modelData

                readonly property string outputName:
                    modelData && modelData.name
                        ? String(modelData.name)
                        : ""
                readonly property bool launcherVisible: LauncherStore.open
                    && LauncherStore.activeOutputName === outputName
                readonly property bool browsingApplications:
                    LauncherStore.query.trim().length === 0
                property var contextResult: null
                property string contextIdentifier: ""
                property real contextMenuX: 0
                property real contextMenuY: 0
                property bool keyboardNavigationActive: false

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
                    keyboardNavigationActive = false
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

                function positionSelectedResult() {
                    if (browsingApplications) {
                        appGrid.positionViewAtIndex(
                            LauncherStore.selectedIndex,
                            GridView.Contain
                        )
                    } else {
                        resultList.positionViewAtIndex(
                            LauncherStore.selectedIndex,
                            ListView.Contain
                        )
                    }
                }

                function navigateBy(offset) {
                    closePinMenu(false)
                    keyboardNavigationActive = true
                    LauncherStore.selectOffset(offset)
                    positionSelectedResult()
                }
                readonly property real barWindowHeight:
                    SurfacePlacementPolicy.barWindowHeight(
                        ConfigStore.barHeight,
                        ConfigStore.barSurfaceMode,
                        ConfigStore.barMargin
                    )

                panelId: "launcher"
                panelOutputName: outputName
                panelVisible: launcherVisible
                layerNamespace: "lumina-launcher"
                screen: modelData
                surfaceItem: launcherSurface
                surfaceRadius: launcherSurface.radius
                surfaceAnchorEdge: OverlayStore.activeAnchorEdge
                surfaceAnchorTop: OverlayStore.activeAnchorTop
                onDismissRequested: LauncherStore.close()

                onVisibleChanged: {
                    if (visible) {
                        keyboardNavigationActive = false
                        Qt.callLater(function() {
                            queryInput.forceActiveFocus()
                        })
                    } else {
                        closePinMenu(false)
                    }
                }

                ShellSurface {
                    id: launcherSurface

                    x: SurfacePlacementPolicy.horizontalX(
                        OverlayStore.activePlacement,
                        OverlayStore.activeAnchorX,
                        width,
                        launcherWindow.width,
                        root.luminaDesign.spacing.extraLarge
                    )
                    width: Math.min(
                        720,
                        Math.max(360, launcherWindow.width - 32)
                    )
                    height: Math.min(
                        720,
                        Math.max(
                            360,
                            launcherWindow.height
                                - launcherWindow.barWindowHeight
                                - ConfigStore.barPanelGap
                                - root.luminaDesign.spacing.extraLarge
                        )
                    )
                    radius: root.luminaDesign.shape.extraLargeIncreased

                    MouseArea {
                        anchors.fill: parent
                    }

                    Column {
                        id: launcherColumn

                        anchors {
                            fill: parent
                            leftMargin: root.luminaDesign.spacing.extraLarge
                            rightMargin: root.luminaDesign.spacing.extraLarge
                            topMargin: root.luminaDesign.spacing.medium
                            bottomMargin: root.luminaDesign.spacing.extraLarge
                        }

                        spacing: root.luminaDesign.spacing.medium

                        Item {
                            width: parent.width
                            height: 10

                            Rectangle {
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    top: parent.top
                                }
                                width: 36
                                height: 4
                                radius: 2
                                color: root.luminaDesign.color.outline
                                opacity: 0.9
                            }
                        }

                        Rectangle {
                            id: searchBox

                            width: parent.width
                            height: 52
                            radius: root.luminaDesign.shape.full
                            color: root.luminaDesign.color.surfaceBase
                            border.width: queryInput.activeFocus ? 2 : 1
                            border.color: queryInput.activeFocus
                                ? root.luminaDesign.color.primary
                                : root.luminaDesign.color.outline

                            DashboardIcon {
                                anchors {
                                    left: parent.left
                                    leftMargin: root.luminaDesign.spacing.large
                                    verticalCenter: parent.verticalCenter
                                }
                                width: 22
                                height: 22
                                iconName: "system-search-symbolic"
                                fallbackSymbol: "⌕"
                                iconColor: root.luminaDesign.color.onSurface
                                iconSize: 19
                            }

                            TextInput {
                                id: queryInput

                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    leftMargin: 50
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
                                    launcherWindow.keyboardNavigationActive = false
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
                                    launcherWindow.navigateBy(
                                        launcherWindow.browsingApplications
                                            ? appGrid.columnCount
                                            : 1
                                    )
                                    event.accepted = true
                                }

                                Keys.onUpPressed: event => {
                                    launcherWindow.navigateBy(
                                        launcherWindow.browsingApplications
                                            ? -appGrid.columnCount
                                            : -1
                                    )
                                    event.accepted = true
                                }

                                Keys.onLeftPressed: event => {
                                    if (launcherWindow.browsingApplications) {
                                        launcherWindow.navigateBy(-1)
                                        event.accepted = true
                                    }
                                }

                                Keys.onRightPressed: event => {
                                    if (launcherWindow.browsingApplications) {
                                        launcherWindow.navigateBy(1)
                                        event.accepted = true
                                    }
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

                        Item {
                            id: contentArea

                            width: parent.width
                            height: parent.height
                                - 10
                                - searchBox.height
                                - launcherColumn.spacing * 2

                            Item {
                                id: browseView

                                anchors.fill: parent
                                visible:
                                    launcherWindow.browsingApplications

                                Flickable {
                                    id: pinnedFlick

                                    visible:
                                        LauncherStore.favoriteResults.length > 0
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: parent.top
                                    }
                                    height: visible ? 102 : 0
                                    contentWidth: Math.max(
                                        width,
                                        pinnedRow.implicitWidth
                                    )
                                    contentHeight: height
                                    clip: true
                                    boundsBehavior: Flickable.StopAtBounds
                                    flickableDirection:
                                        Flickable.HorizontalFlick
                                    Accessible.name:
                                        LauncherStrings.text(
                                            I18n.locale,
                                            "pinnedGridAccessibleName"
                                        )

                                    Row {
                                        id: pinnedRow

                                        x: Math.max(
                                            0,
                                            (pinnedFlick.width
                                                - implicitWidth) / 2
                                        )
                                        anchors.verticalCenter:
                                            parent.verticalCenter
                                        spacing:
                                            root.luminaDesign.spacing.small

                                        Repeater {
                                            model: ScriptModel {
                                                values:
                                                    LauncherStore.favoriteResults
                                            }

                                            delegate: LauncherAppTile {
                                                required property var modelData

                                                width: 92
                                                height: 96
                                                result: modelData
                                                selected: false
                                                iconSize: 48
                                                onActivated: {
                                                    launcherWindow.closePinMenu(false)
                                                    LauncherStore.execute(modelData)
                                                }
                                                onContextMenuRequested: sourceItem =>
                                                    launcherWindow.openPinMenu(
                                                        modelData,
                                                        sourceItem
                                                    )
                                            }
                                        }
                                    }
                                }

                                Text {
                                    id: allAppsLabel

                                    anchors {
                                        horizontalCenter:
                                            parent.horizontalCenter
                                        top: pinnedFlick.visible
                                            ? pinnedFlick.bottom
                                            : parent.top
                                        topMargin:
                                            root.luminaDesign.spacing.small
                                    }
                                    height: 28
                                    text: LauncherStrings.text(
                                        I18n.locale,
                                        "allApps"
                                    )
                                    color: root.luminaDesign.color.onSurface
                                    font.pixelSize:
                                        root.luminaDesign.typography.titleSmall
                                    font.weight: Font.DemiBold
                                }

                                GridView {
                                    id: appGrid

                                    readonly property int columnCount:
                                        Math.max(
                                            4,
                                            Math.min(
                                                7,
                                                Math.floor(width / 92)
                                            )
                                        )

                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: allAppsLabel.bottom
                                        bottom: parent.bottom
                                        topMargin:
                                            root.luminaDesign.spacing.small
                                    }
                                    cellWidth: width / columnCount
                                    cellHeight: 100
                                    clip: true
                                    boundsBehavior: Flickable.StopAtBounds
                                    currentIndex:
                                        LauncherStore.selectedIndex
                                    highlightFollowsCurrentItem: false
                                    model: ScriptModel {
                                        values: LauncherStore.results
                                    }
                                    Accessible.name:
                                        LauncherStrings.text(
                                            I18n.locale,
                                            "appGridAccessibleName"
                                        )

                                    delegate: LauncherAppTile {
                                        required property var modelData
                                        required property int index

                                        width: GridView.view.cellWidth
                                        height: GridView.view.cellHeight
                                        result: modelData
                                        selected:
                                            launcherWindow.keyboardNavigationActive
                                                && index
                                                    === LauncherStore.selectedIndex
                                        iconSize: 48
                                        onActivated: {
                                            launcherWindow.closePinMenu(false)
                                            LauncherStore.selectedIndex = index
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
                                }
                            }

                            Item {
                                id: searchView

                                anchors.fill: parent
                                visible:
                                    !launcherWindow.browsingApplications

                                Text {
                                    id: searchResultsLabel

                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                    }
                                    height: 28
                                    text: LauncherStrings.text(
                                        I18n.locale,
                                        "searchResults"
                                    )
                                    color: root.luminaDesign.color.onSurface
                                    font.pixelSize:
                                        root.luminaDesign.typography.titleSmall
                                    font.weight: Font.DemiBold
                                }

                                Row {
                                    id: footer

                                    anchors {
                                        left: parent.left
                                        bottom: parent.bottom
                                    }
                                    height: 22
                                    spacing:
                                        root.luminaDesign.spacing.medium

                                    Text {
                                        text: I18n.tr(
                                            "launcher.hint.navigate",
                                            "↑↓ Navigate"
                                        )
                                        color:
                                            root.luminaDesign.color.textMuted
                                        font.pixelSize:
                                            root.luminaDesign.typography.labelSmall
                                    }

                                    Text {
                                        text: I18n.tr(
                                            "launcher.hint.open",
                                            "Enter Open"
                                        )
                                        color:
                                            root.luminaDesign.color.textMuted
                                        font.pixelSize:
                                            root.luminaDesign.typography.labelSmall
                                    }

                                    Text {
                                        text: I18n.tr(
                                            "launcher.hint.close",
                                            "Esc Close"
                                        )
                                        color:
                                            root.luminaDesign.color.textMuted
                                        font.pixelSize:
                                            root.luminaDesign.typography.labelSmall
                                    }
                                }

                                ListView {
                                    id: resultList

                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: searchResultsLabel.bottom
                                        bottom: footer.top
                                        topMargin:
                                            root.luminaDesign.spacing.small
                                        bottomMargin:
                                            root.luminaDesign.spacing.small
                                    }
                                    spacing:
                                        root.luminaDesign.spacing.extraSmall
                                    clip: true
                                    boundsBehavior: Flickable.StopAtBounds
                                    currentIndex:
                                        LauncherStore.selectedIndex
                                    highlightFollowsCurrentItem: false
                                    model: ScriptModel {
                                        values: LauncherStore.results
                                    }

                                    delegate: LauncherResult {
                                        required property var modelData
                                        required property int index

                                        width: resultList.width
                                        result: modelData
                                        selected:
                                            launcherWindow.keyboardNavigationActive
                                                && index
                                                    === LauncherStore.selectedIndex
                                        onActivated: {
                                            launcherWindow.closePinMenu(false)
                                            LauncherStore.selectedIndex = index
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
                                        visible:
                                            LauncherStore.results.length === 0
                                        text: I18n.tr(
                                            "launcher.empty",
                                            "No matching apps, windows, or actions"
                                        )
                                        color:
                                            root.luminaDesign.color.textMuted
                                        font.pixelSize:
                                            root.luminaDesign.typography.bodyMedium
                                    }
                                }
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

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.design
import qs.modules.control
import qs.services.notifications
import qs.stores.config
import qs.stores.shell
import "../control/ShellSurfacePolicy.js" as ShellSurfacePolicy
import "../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

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
                readonly property real barWindowHeight:
                    SurfacePlacementPolicy.barWindowHeight(
                        ConfigStore.barHeight,
                        ConfigStore.barSurfaceMode,
                        ConfigStore.barMargin
                    )

                screen: modelData
                visible: centerVisible
                color: "transparent"
                surfaceFormat.opaque: false
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

      BackgroundEffect.blurRegion:
          ShellSurfacePolicy.requestsBackdropBlur(
              ConfigStore.shellBackgroundMode
          )
              ? shellBlurRegion
              : null

      Region {
          id: shellBlurRegion

          Region {
              x: centerSurface.x
              y: centerSurface.y
              width: centerSurface.width
              height: centerSurface.height
              radius: centerSurface.radius
          }
      }

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
                    color: Qt.rgba(
                        root.luminaDesign.color.scrim.r,
                        root.luminaDesign.color.scrim.g,
                        root.luminaDesign.color.scrim.b,
                        0.34
                    )

                    MouseArea {
                        anchors.fill: parent
                        onClicked: NotificationService.closeCenter()
                    }
                }

                ShellSurface {
          id: centerSurface

                    readonly property real availableHeight: Math.max(
                        0,
                        centerWindow.height
                            - centerWindow.barWindowHeight
                            - root.luminaDesign.spacing.barPanelGap * 2
                    )
                    readonly property real desiredContentHeight:
                        root.luminaDesign.spacing.extraLarge * 2
                        + centerHeader.height
                        + notificationColumn.spacing
                        + historyList.contentHeight

                    x: SurfacePlacementPolicy.horizontalX(
                        OverlayStore.activePlacement,
                        OverlayStore.activeAnchorX,
                        width,
                        centerWindow.width,
                        root.luminaDesign.spacing.medium
                    )
                    y: SurfacePlacementPolicy.verticalY(
                        OverlayStore.activePlacement,
                        ConfigStore.barPosition,
                        height,
                        centerWindow.height,
                        centerWindow.barWindowHeight,
                        root.luminaDesign.spacing.barPanelGap,
                        root.luminaDesign.spacing.medium
                    )

                    width: Math.min(
                        root.luminaDesign.size.notificationCenterWidth,
                        centerWindow.width - root.luminaDesign.spacing.extraLarge * 2
                    )
                    height: Math.min(
                        availableHeight,
                        NotificationService.history.length === 0
                            ? root.luminaDesign.size
                                .notificationCenterEmptyHeight
                            : Math.max(
                                root.luminaDesign.size
                                    .notificationCenterEmptyHeight,
                                Math.min(
                                    root.luminaDesign.size
                                        .notificationCenterMaxHeight,
                                    desiredContentHeight
                                )
                            )
                    )
                    radius: root.luminaDesign.shape.extraLargeIncreased
          opacity: centerWindow.centerVisible ? 1 : 0
                    scale: centerWindow.centerVisible ? 1 : 0.97

                    Behavior on height {
                        NumberAnimation {
                            duration: root.luminaDesign.motion.medium
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: root.luminaDesign.motion.medium
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: root.luminaDesign.motion.medium
                            easing.type: Easing.OutBack
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                    }

                    Column {
                        id: notificationColumn

                        anchors {
                            fill: parent
                            margins: root.luminaDesign.spacing.extraLarge
                        }

                        spacing: root.luminaDesign.spacing.medium

                        Item {
                            id: centerHeader

                            width: parent.width
                            height: 48

                            Column {
                                anchors {
                                    left: parent.left
                                    right: headerActions.left
                                    rightMargin:
                                        root.luminaDesign.spacing.medium
                                    verticalCenter: parent.verticalCenter
                                }

                                spacing: 2

                                Text {
                                    width: parent.width
                                    text: "Notifications"
                                    color: root.luminaDesign.color.onSurface
                                    elide: Text.ElideRight
                                    font.pixelSize:
                                        root.luminaDesign.typography.titleLarge
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    width: parent.width
                                    text: NotificationService.history.length
                                        === 0
                                        ? "All caught up"
                                        : NotificationService.history.length
                                            + (
                                                NotificationService.history.length
                                                    === 1
                                                    ? " recent notification"
                                                    : " recent notifications"
                                            )
                                    color: root.luminaDesign.color.textMuted
                                    elide: Text.ElideRight
                                    font.pixelSize:
                                        root.luminaDesign.typography.labelMedium
                                }
                            }

                            Row {
                                id: headerActions

                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }

                                spacing: root.luminaDesign.spacing.small

                                Rectangle {
                                    id: dndButton

                                    width: dndContent.implicitWidth + 18
                                    height: 36
                                    activeFocusOnTab: true
                                    radius: NotificationService.doNotDisturb
                                        ? root.luminaDesign.shape.full
                                        : root.luminaDesign.shape.large
                                    color: NotificationService.doNotDisturb
                                        || dndMouse.containsMouse
                                        ? root.luminaDesign.color.accentContainer
                                        : root.luminaDesign.color.surfaceMuted
                                    border.width: activeFocus ? 2 : 0
                                    border.color:
                                        root.luminaDesign.color.primary

                                    Accessible.role: Accessible.CheckBox
                                    Accessible.name: "Do Not Disturb"
                                    Accessible.checked:
                                        NotificationService.doNotDisturb
                                    Accessible.focusable: true
                                    Accessible.focused: activeFocus
                                    Accessible.onPressAction:
                                        NotificationService
                                            .toggleDoNotDisturb()

                                    Keys.onSpacePressed: event => {
                                        NotificationService
                                            .toggleDoNotDisturb()
                                        event.accepted = true
                                    }

                                    Keys.onReturnPressed: event => {
                                        NotificationService
                                            .toggleDoNotDisturb()
                                        event.accepted = true
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration:
                                                root.luminaDesign.motion.fast
                                        }
                                    }

                                    Behavior on radius {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.medium
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    Row {
                                        id: dndContent

                                        anchors.centerIn: parent
                                        spacing:
                                            root.luminaDesign.spacing.small

                                        DashboardIcon {
                                            anchors.verticalCenter:
                                                parent.verticalCenter
                                            customSource: Qt.resolvedUrl(
                                                "../../assets/icons/"
                                                    + "notification-symbolic.svg"
                                            )
                                            fallbackSymbol: "●"
                                            iconColor:
                                                NotificationService
                                                    .doNotDisturb
                                                || dndMouse.containsMouse
                                                    ? root.luminaDesign.color
                                                        .onAccentContainer
                                                    : root.luminaDesign.color
                                                        .onSurface
                                            iconSize: 16
                                        }

                                        Text {
                                            anchors.verticalCenter:
                                                parent.verticalCenter
                                            text: "DND"
                                            color:
                                                NotificationService
                                                    .doNotDisturb
                                                || dndMouse.containsMouse
                                                    ? root.luminaDesign.color
                                                        .onAccentContainer
                                                    : root.luminaDesign.color
                                                        .onSurface
                                            font.pixelSize:
                                                root.luminaDesign.typography
                                                    .labelMedium
                                            font.weight: Font.DemiBold
                                        }
                                    }

                                    MouseArea {
                                        id: dndMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            dndButton.focus = false
                                            NotificationService
                                                .toggleDoNotDisturb()
                                        }
                                    }
                                }

                                Rectangle {
                                    id: clearButton

                                    readonly property bool available:
                                        NotificationService.history.length > 0

                                    width: clearLabel.implicitWidth + 18
                                    height: 36
                                    activeFocusOnTab: available
                                    radius: clearMouse.containsMouse
                                        ? root.luminaDesign.shape.full
                                        : root.luminaDesign.shape.large
                                    color: clearMouse.containsMouse
                                        ? root.luminaDesign.color.accentContainer
                                        : root.luminaDesign.color.surfaceMuted
                                    opacity: available ? 1 : 0.42
                                    border.width: activeFocus ? 2 : 0
                                    border.color:
                                        root.luminaDesign.color.primary

                                    Accessible.role: Accessible.Button
                                    Accessible.name:
                                        "Clear notification history"
                                    Accessible.focusable: available
                                    Accessible.focused: activeFocus
                                    Accessible.onPressAction:
                                        NotificationService.clearHistory()

                                    Keys.onSpacePressed: event => {
                                        NotificationService.clearHistory()
                                        event.accepted = true
                                    }

                                    Keys.onReturnPressed: event => {
                                        NotificationService.clearHistory()
                                        event.accepted = true
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration:
                                                root.luminaDesign.motion.fast
                                        }
                                    }

                                    Behavior on radius {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.medium
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    Text {
                                        id: clearLabel

                                        anchors.centerIn: parent
                                        text: "Clear"
                                        color: clearMouse.containsMouse
                                            ? root.luminaDesign.color
                                                .onAccentContainer
                                            : root.luminaDesign.color.onSurface
                                        font.pixelSize:
                                            root.luminaDesign.typography
                                                .labelMedium
                                        font.weight: Font.DemiBold
                                    }

                                    MouseArea {
                                        id: clearMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: enabled
                                            ? Qt.PointingHandCursor
                                            : Qt.ArrowCursor
                                        enabled: clearButton.available
                                        onClicked: {
                                            clearButton.focus = false
                                            NotificationService.clearHistory()
                                        }
                                    }
                                }
                            }
                        }

                        ListView {
                            id: historyList

                            width: parent.width
                            height: parent.height
                                - centerHeader.height
                                - parent.spacing
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

                            Column {
                                anchors.centerIn: parent
                                visible: NotificationService.history.length === 0
                                width: Math.min(parent.width, 280)
                                spacing: root.luminaDesign.spacing.medium

                                Rectangle {
                                    anchors.horizontalCenter:
                                        parent.horizontalCenter
                                    width: 64
                                    height: 64
                                    radius: root.luminaDesign.shape.full
                                    color:
                                        root.luminaDesign.color.surfaceMuted

                                    DashboardIcon {
                                        anchors.centerIn: parent
                                        customSource: Qt.resolvedUrl(
                                            "../../assets/icons/"
                                                + "notification-symbolic.svg"
                                        )
                                        fallbackSymbol: "●"
                                        iconColor:
                                            NotificationService.doNotDisturb
                                                ? root.luminaDesign.color
                                                    .textMuted
                                                : root.luminaDesign.color.primary
                                        iconSize: 28
                                    }

                                    Rectangle {
                                        anchors.centerIn: parent
                                        visible:
                                            NotificationService.doNotDisturb
                                        width: 34
                                        height: 3
                                        radius: 2
                                        rotation: -45
                                        color:
                                            root.luminaDesign.color.textMuted
                                    }
                                }

                                Text {
                                    width: parent.width
                                    text: NotificationService.doNotDisturb
                                        ? "Quiet mode is on"
                                        : "All caught up"
                                    horizontalAlignment: Text.AlignHCenter
                                    color: root.luminaDesign.color.onSurface
                                    font.pixelSize:
                                        root.luminaDesign.typography.titleMedium
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    width: parent.width
                                    text: NotificationService.doNotDisturb
                                        ? "New notifications stay in history "
                                            + "without interrupting you"
                                        : "New notifications will appear here"
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.Wrap
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
}

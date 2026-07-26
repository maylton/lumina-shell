pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.design
import qs.modules.bar.widgets
import qs.modules.control
import qs.services.i18n
import qs.services.session
import qs.stores.session
import qs.stores.config
import qs.stores.shell
import "../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var sessionActions: [
        {
            id: "lock",
            title: I18n.tr("session.action.lock.title", "Lock"),
            description: I18n.tr(
                "session.action.lock.description",
                "Secure this session"
            ),
            confirmationTitle: I18n.tr(
                "session.confirmation.lock",
                "Lock this session?"
            ),
            iconName: "system-lock-screen-symbolic",
            fallbackSymbol: "●",
            destructive: false
        },
        {
            id: "suspend",
            title: I18n.tr(
                "session.action.suspend.title",
                "Suspend"
            ),
            description: I18n.tr(
                "session.action.suspend.description",
                "Pause and save power"
            ),
            confirmationTitle: I18n.tr(
                "session.confirmation.suspend",
                "Suspend this computer?"
            ),
            iconName: "media-playback-pause-symbolic",
            fallbackSymbol: "◐",
            destructive: false
        },
        {
            id: "logout",
            title: I18n.tr(
                "session.action.logout.title",
                "Log out"
            ),
            description: I18n.tr(
                "session.action.logout.description",
                "End the desktop session"
            ),
            confirmationTitle: I18n.tr(
                "session.confirmation.logout",
                "Log out of this session?"
            ),
            iconName: "system-log-out-symbolic",
            fallbackSymbol: "↪",
            destructive: true
        },
        {
            id: "reboot",
            title: I18n.tr(
                "session.action.reboot.title",
                "Restart"
            ),
            description: I18n.tr(
                "session.action.reboot.description",
                "Restart the computer"
            ),
            confirmationTitle: I18n.tr(
                "session.confirmation.reboot",
                "Restart this computer?"
            ),
            iconName: "system-reboot-symbolic",
            fallbackSymbol: "↻",
            destructive: true
        },
        {
            id: "poweroff",
            title: I18n.tr(
                "session.action.poweroff.title",
                "Power off"
            ),
            description: I18n.tr(
                "session.action.poweroff.description",
                "Shut down the computer"
            ),
            confirmationTitle: I18n.tr(
                "session.confirmation.poweroff",
                "Power off this computer?"
            ),
            iconName: "system-shutdown-symbolic",
            fallbackSymbol: "⏻",
            destructive: true
        }
    ]
    readonly property var visibleSessionActions:
        sessionActions.filter(action => {
            if (action.id === "lock")
                return ConfigStore.sessionShowLock

            if (action.id === "suspend")
                return ConfigStore.sessionShowSuspend

            return true
        })
    readonly property var safeSessionActions:
        visibleSessionActions.filter(action => !action.destructive)
    readonly property var destructiveSessionActions:
        visibleSessionActions.filter(action => action.destructive)
    readonly property var pendingActionDetails:
        actionFor(SessionService.pendingAction)

    function actionFor(actionId) {
        const requested = String(actionId)

        for (var index = 0; index < sessionActions.length; ++index) {
            if (sessionActions[index].id === requested)
                return sessionActions[index]
        }

        return null
    }

    Connections {
        target: OverlayStore

        function onActiveSurfaceChanged() {
            if (OverlayStore.activeSurface !== "session")
                SessionService.cancel()
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
            BarPanelWindow {
                id: sessionWindow

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property bool menuVisible:
                    SessionMenuStore.activeOutputName === outputName
                readonly property real barWindowHeight:
                    SurfacePlacementPolicy.barWindowHeight(
                        ConfigStore.barHeight,
                        ConfigStore.barSurfaceMode,
                        ConfigStore.barMargin
                    )

                panelId: "session"
                panelOutputName: outputName
                panelVisible: menuVisible
                layerNamespace: "lumina-session-menu"
                screen: modelData
                surfaceItem: menuSurface
                surfaceRadius: menuSurface.radius
                onDismissRequested: {
                    SessionService.cancel()
                    SessionMenuStore.close()
                }

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

                ShellSurface {
                    id: menuSurface

                    readonly property real contentInset:
                        root.luminaDesign.spacing.extraLarge
                    readonly property real maximumHeight:
                        sessionWindow.height
                            - sessionWindow.barWindowHeight
                            - ConfigStore.barPanelGap
                            - root.luminaDesign.spacing.extraLarge

                    x: SurfacePlacementPolicy.horizontalX(
                        OverlayStore.activePlacement,
                        OverlayStore.activeAnchorX,
                        width,
                        sessionWindow.width,
                        root.luminaDesign.spacing.extraLarge
                    )
                    width: Math.min(
                        root.luminaDesign.size.sessionMenuWidth,
                        sessionWindow.width - root.luminaDesign.spacing.extraLarge * 2
                    )
                    height: Math.min(
                        root.luminaDesign.size.sessionMenuHeight,
                        maximumHeight,
                        menuContent.implicitHeight + contentInset * 2
                    )
                    radius: root.luminaDesign.shape.extraLarge

                    MouseArea {
                        anchors.fill: parent
                    }

                    Column {
                        id: menuContent

                        x: menuSurface.contentInset
                        y: menuSurface.contentInset
                        width: parent.width - menuSurface.contentInset * 2
                        spacing: root.luminaDesign.spacing.large

                        Row {
                            width: parent.width
                            height: 52
                            spacing: root.luminaDesign.spacing.medium

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 44
                                height: 44
                                radius: root.luminaDesign.shape.full
                                color:
                                    root.luminaDesign.color.accentContainer

                                DashboardIcon {
                                    anchors.centerIn: parent
                                    iconName: "system-shutdown-symbolic"
                                    fallbackSymbol: "⏻"
                                    iconColor:
                                        root.luminaDesign.color
                                            .onAccentContainer
                                    iconSize: 22
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                    - 44
                                    - parent.spacing
                                spacing: 3

                                Text {
                                    width: parent.width
                                    text: I18n.tr(
                                        "session.menu.title",
                                        "Session"
                                    )
                                    color:
                                        root.luminaDesign.color.onSurface
                                    font.pixelSize:
                                        root.luminaDesign.typography
                                            .titleLarge
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    width: parent.width
                                    text: I18n.tr(
                                        "session.menu.description",
                                        "Lock, pause, or finish your work"
                                    )
                                    color:
                                        root.luminaDesign.color.textMuted
                                    elide: Text.ElideRight
                                    font.pixelSize:
                                        root.luminaDesign.typography
                                            .bodyMedium
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            visible: root.safeSessionActions.length > 0
                            spacing: root.luminaDesign.spacing.small

                            Text {
                                text: I18n.tr(
                                    "session.menu.quickActions",
                                    "Quick actions"
                                )
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize:
                                    root.luminaDesign.typography.labelMedium
                                font.weight: Font.DemiBold
                            }

                            Grid {
                                width: parent.width
                                columns: Math.max(
                                    1,
                                    root.safeSessionActions.length
                                )
                                columnSpacing:
                                    root.luminaDesign.spacing.small
                                rowSpacing:
                                    root.luminaDesign.spacing.small

                                Repeater {
                                    model: root.safeSessionActions

                                    delegate: SessionAction {
                                        required property var modelData

                                        width: (
                                            parent.width
                                            - parent.columnSpacing
                                                * (parent.columns - 1)
                                        ) / parent.columns
                                        title: String(modelData.title)
                                        description:
                                            String(modelData.description)
                                        iconName:
                                            String(modelData.iconName)
                                        fallbackSymbol:
                                            String(modelData.fallbackSymbol)
                                        onActivated:
                                            SessionService.request(
                                                modelData.id
                                            )
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            visible: root.safeSessionActions.length > 0
                            color: root.luminaDesign.color.outline
                            opacity: 0.45
                        }

                        Column {
                            width: parent.width
                            spacing: root.luminaDesign.spacing.small

                            Text {
                                text: I18n.tr(
                                    "session.menu.powerActions",
                                    "Power and access"
                                )
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize:
                                    root.luminaDesign.typography.labelMedium
                                font.weight: Font.DemiBold
                            }

                            Grid {
                                width: parent.width
                                columns: 3
                                columnSpacing:
                                    root.luminaDesign.spacing.small
                                rowSpacing:
                                    root.luminaDesign.spacing.small

                                Repeater {
                                    model: root.destructiveSessionActions

                                    delegate: SessionAction {
                                        required property var modelData

                                        width: (
                                            parent.width
                                            - parent.columnSpacing * 2
                                        ) / 3
                                        title: String(modelData.title)
                                        description:
                                            String(modelData.description)
                                        iconName:
                                            String(modelData.iconName)
                                        fallbackSymbol:
                                            String(modelData.fallbackSymbol)
                                        destructive: true
                                        onActivated:
                                            SessionService.request(
                                                modelData.id
                                            )
                                    }
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

                            Rectangle {
                                anchors.horizontalCenter:
                                    parent.horizontalCenter
                                width: 52
                                height: 52
                                radius: root.luminaDesign.shape.full
                                color:
                                    root.luminaDesign.color.errorContainer

                                DashboardIcon {
                                    anchors.centerIn: parent
                                    iconName:
                                        root.pendingActionDetails
                                            ? String(
                                                root.pendingActionDetails
                                                    .iconName
                                            )
                                            : ""
                                    fallbackSymbol:
                                        root.pendingActionDetails
                                            ? String(
                                                root.pendingActionDetails
                                                    .fallbackSymbol
                                            )
                                            : "!"
                                    iconColor:
                                        root.luminaDesign.color
                                            .onErrorContainer
                                    iconSize: 24
                                }
                            }

                            Text {
                                width: parent.width
                                text: root.pendingActionDetails
                                    ? String(
                                        root.pendingActionDetails
                                            .confirmationTitle
                                    )
                                    : ""
                                horizontalAlignment: Text.AlignHCenter
                                color: root.luminaDesign.color.onSurface
                                font.pixelSize:
                                    root.luminaDesign.typography.titleLarge
                                font.weight: Font.DemiBold
                            }

                            Text {
                                width: parent.width
                                text: root.pendingActionDetails
                                    ? String(
                                        root.pendingActionDetails.description
                                    )
                                    : ""
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
                                        text: I18n.tr(
                                            "common.cancel",
                                            "Cancel"
                                        )
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
                                        text: I18n.tr(
                                            "common.confirm",
                                            "Confirm"
                                        )
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

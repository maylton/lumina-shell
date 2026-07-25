import QtQuick
import qs.design
import qs.modules.bar.widgets
import qs.modules.launcher
import qs.modules.notifications
import qs.modules.session
import qs.modules.wallpaper
import qs.services.niri
import qs.stores.config

Item {
    id: root

    required property string outputName
    required property var visibleWorkspaces
    required property string activeWindowTitle
    required property string activeWindowAppId
    required property string columnLabel
    required property string workspaceLabel
    required property bool showActionError

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool compactLayout: width < 1400
    readonly property bool narrowLayout: width < 1080
    readonly property var leftRegistry: ({
        launcher: launcherComponent,
        overview: overviewComponent,
        workspaces: workspacesComponent,
        datetime: dateTimeComponent
    })
    readonly property var rightRegistry: ({
        privacy: privacyComponent,
        keyboard: keyboardComponent,
        tray: trayComponent,
        notifications: notificationsComponent,
        "system-status": systemStatusComponent,
        dashboard: dashboardComponent,
        wallpaper: wallpaperComponent,
        session: sessionComponent
    })
    readonly property var widgetVisibility: ({
        launcher: ConfigStore.barShowLauncher && !narrowLayout,
        overview: ConfigStore.barShowOverview && !narrowLayout,
        workspaces: ConfigStore.barShowWorkspaces,
        datetime: ConfigStore.barShowClock,
        privacy: ConfigStore.barShowPrivacyIndicators,
        keyboard: ConfigStore.barShowKeyboardLayout,
        tray: ConfigStore.barShowTray && width >= 900,
        notifications: ConfigStore.barShowNotifications
            && width >= 820,
        "system-status": ConfigStore.barShowAudioStatus
            || ConfigStore.barShowNetworkStatus
            || ConfigStore.barShowBatteryStatus,
        dashboard: ConfigStore.barShowDashboardButton,
        wallpaper: ConfigStore.barShowWallpaperButton
            && width >= 1180,
        session: ConfigStore.barShowSessionButton
            && width >= 1180
    })

    function widgetEnabled(widgetId) {
        return Boolean(widgetVisibility[String(widgetId || "")])
    }

    BarCluster {
        id: leftArea

        anchors {
            left: parent.left
            leftMargin: root.luminaDesign.spacing.large
            verticalCenter: parent.verticalCenter
        }

        Repeater {
            model: ConfigStore.barLeftWidgetOrder

            delegate: Loader {
                required property var modelData

                active: root.widgetEnabled(String(modelData))
                visible: active
                sourceComponent:
                    root.leftRegistry[String(modelData)] || null
            }
        }
    }

    ContextCapsule {
        id: contextCapsule

        anchors.centerIn: parent
        availableWidth: Math.max(
            0,
            root.width - leftArea.width - rightArea.width - 64
        )
        activeWindowTitle: root.activeWindowTitle
        activeWindowAppId: root.activeWindowAppId
        columnLabel: root.columnLabel
        workspaceLabel: root.workspaceLabel
        showActionError: root.showActionError
        actionError: NiriService.lastActionError
    }

    BarCluster {
        id: rightArea

        anchors {
            right: parent.right
            rightMargin: root.luminaDesign.spacing.large
            verticalCenter: parent.verticalCenter
        }

        Repeater {
            model: ConfigStore.barRightWidgetOrder

            delegate: Loader {
                required property var modelData

                active: root.widgetEnabled(String(modelData))
                visible: active
                sourceComponent:
                    root.rightRegistry[String(modelData)] || null
            }
        }
    }

    Component {
        id: launcherComponent

        LauncherButton {
            outputName: root.outputName
        }
    }

    Component {
        id: overviewComponent

        OverviewButton {}
    }

    Component {
        id: workspacesComponent

        WorkspaceStrip {
            workspaces: root.visibleWorkspaces
            itemSpacing: ConfigStore.barWidgetSpacing
        }
    }

    Component {
        id: dateTimeComponent

        DateTimeCluster {
            compact: root.compactLayout
            barPosition: ConfigStore.barPosition
            outputName: root.outputName.length > 0
                ? root.outputName
                : "screen"
        }
    }

    Component {
        id: privacyComponent

        PrivacyIndicator {}
    }

    Component {
        id: keyboardComponent

        KeyboardLayoutIndicator {}
    }

    Component {
        id: trayComponent

        TrayWidget {}
    }

    Component {
        id: notificationsComponent

        NotificationButton {
            outputName: root.outputName
        }
    }

    Component {
        id: systemStatusComponent

        SystemStatusCluster {
            compact: root.width < 1320
            outputName: root.outputName
        }
    }

    Component {
        id: dashboardComponent

        DashboardButton {
            outputName: root.outputName
        }
    }

    Component {
        id: wallpaperComponent

        WallpaperButton {
            outputName: root.outputName
        }
    }

    Component {
        id: sessionComponent

        SessionButton {
            outputName: root.outputName
        }
    }
}

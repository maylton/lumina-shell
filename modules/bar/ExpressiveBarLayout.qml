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

    BarCluster {
        id: leftArea

        anchors {
            left: parent.left
            leftMargin: root.luminaDesign.spacing.large
            verticalCenter: parent.verticalCenter
        }

        LauncherButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: ConfigStore.barShowLauncher
            outputName: root.outputName
        }

        OverviewButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: ConfigStore.barShowOverview
        }

        WorkspaceStrip {
            anchors.verticalCenter: parent.verticalCenter
            workspaces: ConfigStore.barShowWorkspaces
                ? root.visibleWorkspaces
                : []
            itemSpacing: ConfigStore.barWidgetSpacing
            visualStyle: "expressive"
        }

        DateTimeCluster {
            anchors.verticalCenter: parent.verticalCenter
            visible: ConfigStore.barShowClock
            compact: root.width < 1400
            visualStyle: "expressive"
            barPosition: ConfigStore.barPosition
            outputName: root.outputName.length > 0
                ? root.outputName
                : "screen"
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

        PrivacyIndicator {
            visible: ConfigStore.barShowPrivacyIndicators
                && sourceAvailable
        }

        KeyboardLayoutIndicator {
            visible: ConfigStore.barShowKeyboardLayout
                && sourceAvailable
        }

        TrayWidget {
            anchors.verticalCenter: parent.verticalCenter
            visible: ConfigStore.barShowTray
        }

        NotificationButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: ConfigStore.barShowNotifications
            outputName: root.outputName
        }

        SystemStatusCluster {
            anchors.verticalCenter: parent.verticalCenter
            compact: root.width < 1320
            outputName: root.outputName
        }

        DashboardButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: ConfigStore.barShowDashboardButton
            outputName: root.outputName
        }

        WallpaperButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: ConfigStore.barShowWallpaperButton
            outputName: root.outputName
        }

        SessionButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: ConfigStore.barShowSessionButton
            outputName: root.outputName
        }
    }
}

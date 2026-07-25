import QtQuick
import qs.design
import qs.modules.bar.widgets
import qs.modules.control
import qs.modules.launcher
import qs.modules.notifications
import qs.modules.session
import qs.modules.wallpaper
import qs.stores.config

Item {
    id: root

    required property string outputName
    required property var visibleWorkspaces
    required property string activeWindowTitle
    required property string activeWindowAppId
    required property string columnLabel
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

    Rectangle {
        id: contextPreview

        readonly property string contextText: root.showActionError
            ? "Niri action failed"
            : root.activeWindowTitle

        anchors.centerIn: parent
        visible: ConfigStore.barContextMode !== "hidden"
            && contextText.length > 0
            && width >= 80
        width: Math.max(
            0,
            Math.min(
                contextLabel.implicitWidth + 24,
                root.width - leftArea.width - rightArea.width - 64
            )
        )
        height: root.luminaDesign.size.chipHeight
        radius: root.luminaDesign.shape.full
        color: root.luminaDesign.color.surfaceMuted

        Text {
            id: contextLabel

            anchors {
                fill: parent
                leftMargin: 12
                rightMargin: 12
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: contextPreview.contextText
            color: root.showActionError
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.bodyMedium
            font.weight: Font.DemiBold
        }
    }

    BarCluster {
        id: rightArea

        anchors {
            right: parent.right
            rightMargin: root.luminaDesign.spacing.large
            verticalCenter: parent.verticalCenter
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

        ControlButton {
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

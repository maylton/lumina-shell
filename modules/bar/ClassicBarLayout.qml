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
    required property string outputSummary
    required property bool showActionError

    readonly property var luminaDesign: Theme.luminaTokens

    BarCluster {
        id: leftArea

        anchors {
            left: parent.left
            leftMargin: root.luminaDesign.spacing.medium
            verticalCenter: parent.verticalCenter
        }

        LauncherButton {
            anchors.verticalCenter: parent.verticalCenter
            outputName: root.outputName
        }

        OverviewButton {
            anchors.verticalCenter: parent.verticalCenter
        }

        WorkspaceStrip {
            anchors.verticalCenter: parent.verticalCenter
            workspaces: ConfigStore.barShowWorkspaces
                ? root.visibleWorkspaces
                : []
            itemSpacing: ConfigStore.barWidgetSpacing
        }
    }

    Column {
        id: focusedWindow

        anchors.centerIn: parent
        visible: ConfigStore.barShowWindowTitle
        width: Math.max(
            120,
            root.width - leftArea.width - rightArea.width - 64
        )
        spacing: 0

        Text {
            width: parent.width
            horizontalAlignment: ConfigStore.barCenterWindowTitle
                ? Text.AlignHCenter
                : Text.AlignLeft
            text: root.activeWindowTitle
            color: root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.bodyMedium
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            horizontalAlignment: ConfigStore.barCenterWindowTitle
                ? Text.AlignHCenter
                : Text.AlignLeft
            text: root.activeWindowAppId
            visible: ConfigStore.barShowAppId && text.length > 0
            color: root.luminaDesign.color.textMuted
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.labelSmall
        }
    }

    BarCluster {
        id: rightArea

        anchors {
            right: parent.right
            rightMargin: root.luminaDesign.spacing.large
            verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: columnChip

            visible: ConfigStore.barShowColumnIndicator
                && root.columnLabel.length > 0
            width: visible ? columnLabelText.implicitWidth + 18 : 0
            height: root.luminaDesign.size.chipHeight
            radius: root.luminaDesign.shape.full
            color: root.luminaDesign.color.surfaceMuted
            border.width: 1
            border.color: root.luminaDesign.color.outline

            Behavior on width {
                NumberAnimation {
                    duration: root.luminaDesign.motion.medium
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                id: columnLabelText

                anchors.centerIn: parent
                text: root.columnLabel
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.labelSmall
                font.weight: Font.DemiBold
            }
        }

        ClassicNiriStatus {
            anchors.verticalCenter: parent.verticalCenter
            visible: ConfigStore.showStatusDetails
            showActionError: root.showActionError
            outputSummary: root.outputSummary
        }

        TrayWidget {
            anchors.verticalCenter: parent.verticalCenter
            visible: ConfigStore.barShowTray
        }

        ControlButton {
            anchors.verticalCenter: parent.verticalCenter
            outputName: root.outputName
        }

        NotificationButton {
            anchors.verticalCenter: parent.verticalCenter
            outputName: root.outputName
        }

        WallpaperButton {
            anchors.verticalCenter: parent.verticalCenter
            outputName: root.outputName
        }

        SessionButton {
            anchors.verticalCenter: parent.verticalCenter
            outputName: root.outputName
        }

        ClockWidget {
            anchors.verticalCenter: parent.verticalCenter
            visible: ConfigStore.barShowClock
            outputName: root.outputName.length > 0
                ? root.outputName
                : "screen"
        }
    }
}

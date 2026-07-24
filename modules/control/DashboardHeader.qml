pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.connectivity
import qs.services.niri
import qs.services.notifications
import qs.services.wallpaper
import qs.stores.control
import qs.stores.session
import qs.stores.settings

Item {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens

    implicitHeight: 52

    Row {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        spacing: root.luminaDesign.spacing.medium

        Rectangle {
            width: 38
            height: 38
            radius: root.luminaDesign.shape.large
            color: root.luminaDesign.color.accentContainer

            Text {
                anchors.centerIn: parent
                text: "L"
                color: root.luminaDesign.color.onAccentContainer
                font.pixelSize: 20
                font.weight: Font.Bold
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                text: "Lumina"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleMedium
                font.weight: Font.Bold
            }

            Text {
                text: "Desktop dashboard"
                color: root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.labelSmall
            }
        }
    }

    Row {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        spacing: root.luminaDesign.spacing.small

        DashboardAction {
            symbol: "↻"
            label: "Refresh Niri outputs"
            onActivated: NiriService.requestOutputRefresh()
        }

        DashboardAction {
            symbol: "⚙"
            label: "Open Lumina settings"
            onActivated: SettingsStore.openFor(root.outputName)
        }

        DashboardAction {
            symbol: "⏻"
            label: "Open session controls"
            onActivated: SessionMenuStore.openFor(root.outputName)
        }

        DashboardAction {
            symbol: "◉"
            label: "Wi-Fi"
            checked: ConnectivityService.wifiEnabled
            available: ConnectivityService.wifiAvailable
            onActivated: ConnectivityService.toggleWifi()
        }

        DashboardAction {
            symbol: "ᛒ"
            label: "Bluetooth"
            checked: ConnectivityService.bluetoothEnabled
            available: ConnectivityService.bluetoothAvailable
            onActivated: ConnectivityService.toggleBluetooth()
        }

        DashboardAction {
            symbol: "◐"
            label: "Do Not Disturb"
            checked: NotificationService.doNotDisturb
            onActivated: NotificationService.toggleDoNotDisturb()
        }

        DashboardAction {
            symbol: "✦"
            label: "Dynamic color"
            checked: WallpaperService.dynamicThemeEnabled
            onActivated: WallpaperService.setDynamicTheme(
                !WallpaperService.dynamicThemeEnabled
            )
        }

        DashboardAction {
            symbol: "×"
            label: "Close control center"
            onActivated: ControlCenterStore.close()
        }
    }
}

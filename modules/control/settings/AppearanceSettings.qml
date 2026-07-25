pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.wallpaper
import qs.stores.config

Flickable {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    clip: true
    contentWidth: width
    contentHeight: contentColumn.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: contentColumn

        width: root.width
        spacing: root.luminaDesign.spacing.large

        Column {
            width: parent.width
            spacing: 3

            Text {
                text: "Appearance"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleLarge
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                text: "Color behavior shared by every Lumina surface"
                color: root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.labelMedium
                wrapMode: Text.WordWrap
            }
        }

        DashboardCard {
            width: parent.width
            height: 116
            accessibleName: "Appearance settings"

            QuickToggle {
                anchors {
                    fill: parent
                    margins: root.luminaDesign.spacing.extraLarge
                }

                title: "Dynamic color"
                detail: ConfigStore.dynamicTheme
                    ? "Palette generated from the active wallpaper"
                    : "Lumina default palette"
                iconName: "applications-graphics-symbolic"
                symbol: "✦"
                checked: ConfigStore.dynamicTheme
                onToggled: WallpaperService.setDynamicTheme(
                    !ConfigStore.dynamicTheme
                )
            }
        }

        Text {
            width: parent.width
            text: "Theme mode, opacity, shapes, and animation controls will "
                + "appear here only when their persistent configuration "
                + "is implemented."
            color: root.luminaDesign.color.textMuted
            font.pixelSize: root.luminaDesign.typography.labelSmall
            wrapMode: Text.WordWrap
        }
    }
}

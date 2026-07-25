pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.wallpaper
import qs.stores.config

Flickable {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    property string directoryDraft: ConfigStore.wallpaperDirectory

    clip: true
    contentWidth: width
    contentHeight: contentColumn.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    onVisibleChanged: {
        if (visible)
            directoryDraft = ConfigStore.wallpaperDirectory
    }

    Column {
        id: contentColumn

        width: root.width
        spacing: root.luminaDesign.spacing.large

        Column {
            width: parent.width
            spacing: 3

            Text {
                text: "Wallpaper"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleLarge
                font.weight: Font.Bold
            }

            Text {
                text: "Default source used by the wallpaper picker"
                color: root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.labelMedium
            }
        }

        DashboardCard {
            width: parent.width
            height: 150
            accessibleName: "Wallpaper directory"

            Column {
                anchors {
                    fill: parent
                    margins: root.luminaDesign.spacing.extraLarge
                }

                spacing: root.luminaDesign.spacing.medium

                Text {
                    text: "Wallpaper directory"
                    color: root.luminaDesign.color.onSurface
                    font.pixelSize: root.luminaDesign.typography.bodyMedium
                    font.weight: Font.DemiBold
                }

                Row {
                    width: parent.width
                    height: 44
                    spacing: root.luminaDesign.spacing.small

                    Rectangle {
                        width: parent.width - saveButton.width
                            - parent.spacing
                        height: parent.height
                        radius: root.luminaDesign.shape.medium
                        color: root.luminaDesign.color.surfaceMuted
                        border.width: directoryInput.activeFocus ? 2 : 1
                        border.color: directoryInput.activeFocus
                            ? root.luminaDesign.color.primary
                            : root.luminaDesign.color.outline

                        TextInput {
                            id: directoryInput

                            anchors {
                                fill: parent
                                margins: root.luminaDesign.spacing.medium
                            }

                            text: root.directoryDraft
                            color: root.luminaDesign.color.onSurface
                            selectionColor:
                                root.luminaDesign.color.accentContainer
                            selectedTextColor:
                                root.luminaDesign.color.onAccentContainer
                            clip: true
                            activeFocusOnTab: true
                            font.pixelSize:
                                root.luminaDesign.typography.bodyMedium
                            onTextEdited: root.directoryDraft = text

                            Accessible.role: Accessible.EditableText
                            Accessible.name: "Wallpaper directory"
                        }
                    }

                    DashboardAction {
                        id: saveButton

                        width: 92
                        height: parent.height
                        wide: true
                        iconName: "document-save-symbolic"
                        symbol: "✓"
                        label: "Save"
                        onActivated:
                            WallpaperService.setWallpaperDirectory(
                                root.directoryDraft
                            )
                    }
                }

                Text {
                    width: parent.width
                    text: ConfigStore.wallpaperDirectory
                    color: root.luminaDesign.color.textMuted
                    elide: Text.ElideMiddle
                    font.pixelSize:
                        root.luminaDesign.typography.labelSmall
                }
            }
        }

        Text {
            width: parent.width
            text: "Per-output wallpaper assignment remains available "
                + "through the wallpaper picker."
            color: root.luminaDesign.color.textMuted
            font.pixelSize: root.luminaDesign.typography.labelSmall
            wrapMode: Text.WordWrap
        }
    }
}

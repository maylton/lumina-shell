pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Qt.labs.folderlistmodel
import qs.design
import qs.modules.control
import qs.stores.config
import "../control/ShellSurfacePolicy.js" as ShellSurfacePolicy
import qs.services.wallpaper

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: pickerWindow

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property bool pickerVisible:
                    WallpaperService.pickerOutputName === outputName

                screen: modelData
                visible: pickerVisible
                color: "transparent"
                surfaceFormat.opaque: false
                focusable: pickerVisible
                exclusiveZone: 0

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lumina-wallpaper-picker"
                WlrLayershell.keyboardFocus: pickerVisible
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
              x: pickerSurface.x
              y: pickerSurface.y
              width: pickerSurface.width
              height: pickerSurface.height
              radius: pickerSurface.radius
          }
      }

                FocusScope {
                    anchors.fill: parent
                    focus: pickerWindow.pickerVisible

                    Keys.onEscapePressed: event => {
                        WallpaperService.closePicker()
                        event.accepted = true
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: root.luminaDesign.color.scrim

                    MouseArea {
                        anchors.fill: parent
                        onClicked: WallpaperService.closePicker()
                    }
                }

                ShellSurface {
          id: pickerSurface

                    anchors.centerIn: parent
                    width: Math.min(
                        root.luminaDesign.size.wallpaperPickerWidth,
                        pickerWindow.width - root.luminaDesign.spacing.extraLarge * 2
                    )
                    height: Math.min(
                        root.luminaDesign.size.wallpaperPickerHeight,
                        pickerWindow.height - root.luminaDesign.spacing.extraLarge * 2
                    )
                    radius: root.luminaDesign.shape.extraLarge

                    MouseArea {
                        anchors.fill: parent
                    }

                    FolderListModel {
                        id: wallpaperFiles

                        folder: WallpaperService.urlForPath(
                            WallpaperService.wallpaperDirectory
                        )
                        nameFilters: [
                            "*.png",
                            "*.jpg",
                            "*.jpeg",
                            "*.webp"
                        ]
                        showFiles: true
                        showDirs: false
                        showHidden: false
                        showOnlyReadable: true
                        sortField: FolderListModel.Name
                        sortCaseSensitive: false
                    }

                    Column {
                        anchors {
                            fill: parent
                            margins: root.luminaDesign.spacing.extraLarge
                        }

                        spacing: root.luminaDesign.spacing.medium

                        Row {
                            width: parent.width
                            height: 34
                            spacing: root.luminaDesign.spacing.medium

                            Column {
                                width: parent.width
                                    - dynamicButton.width
                                    - parent.spacing
                                spacing: 1

                                Text {
                                    text: "Wallpaper · " + pickerWindow.outputName
                                    color: root.luminaDesign.color.onSurface
                                    font.pixelSize:
                                        root.luminaDesign.typography.titleLarge
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: wallpaperFiles.count
                                        + " images in this folder"
                                    color: root.luminaDesign.color.textMuted
                                    font.pixelSize:
                                        root.luminaDesign.typography.labelSmall
                                }
                            }

                            Rectangle {
                                id: dynamicButton

                                width: dynamicLabel.implicitWidth + 18
                                height: 30
                                radius: root.luminaDesign.shape.full
                                color: WallpaperService.dynamicThemeEnabled
                                    ? root.luminaDesign.color.accentContainer
                                    : root.luminaDesign.color.surfaceMuted

                                Text {
                                    id: dynamicLabel

                                    anchors.centerIn: parent
                                    text: WallpaperService.dynamicThemeEnabled
                                        ? "Dynamic color on"
                                        : "Dynamic color off"
                                    color: WallpaperService.dynamicThemeEnabled
                                        ? root.luminaDesign.color.onAccentContainer
                                        : root.luminaDesign.color.onSurface
                                    font.pixelSize:
                                        root.luminaDesign.typography.labelSmall
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: WallpaperService.setDynamicTheme(
                                        !WallpaperService.dynamicThemeEnabled
                                    )
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 38
                            radius: root.luminaDesign.shape.medium
                            color: root.luminaDesign.color.surfaceMuted
                            border.width: directoryInput.activeFocus ? 2 : 1
                            border.color: directoryInput.activeFocus
                                ? root.luminaDesign.color.primary
                                : root.luminaDesign.color.outline

                            TextInput {
                                id: directoryInput

                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    margins: root.luminaDesign.spacing.medium
                                    verticalCenter: parent.verticalCenter
                                }

                                text: WallpaperService.wallpaperDirectory
                                color: root.luminaDesign.color.onSurface
                                selectionColor:
                                    root.luminaDesign.color.accentContainer
                                selectedTextColor:
                                    root.luminaDesign.color.onAccentContainer
                                clip: true
                                font.pixelSize:
                                    root.luminaDesign.typography.labelMedium

                                Keys.onReturnPressed: event => {
                                    WallpaperService.setWallpaperDirectory(text)
                                    event.accepted = true
                                }
                            }
                        }

                        GridView {
                            id: wallpaperGrid

                            width: parent.width
                            height: parent.height
                                - 34
                                - 38
                                - parent.spacing * 2
                            cellWidth: Math.floor(width / 3)
                            cellHeight: 150
                            clip: true
                            model: wallpaperFiles

                            delegate: Item {
                                id: wallpaperTile

                                required property string fileName
                                required property url fileUrl

                                width: wallpaperGrid.cellWidth
                                height: wallpaperGrid.cellHeight

                                Rectangle {
                                    anchors {
                                        fill: parent
                                        margins:
                                            root.luminaDesign.spacing.extraSmall
                                    }

                                    radius: root.luminaDesign.shape.large
                                    color: tileMouse.containsMouse
                                        ? root.luminaDesign.color.accentContainer
                                        : root.luminaDesign.color.surfaceMuted
                                    border.width: String(
                                        WallpaperService.wallpaperFor(
                                            pickerWindow.outputName
                                        )
                                    ) === String(wallpaperTile.fileUrl) ? 2 : 0
                                    border.color:
                                        root.luminaDesign.color.primary
                                    clip: true

                                    Image {
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            top: parent.top
                                        }

                                        height: parent.height - 32
                                        source: wallpaperTile.fileUrl
                                        sourceSize.width: 320
                                        sourceSize.height: 220
                                        asynchronous: true
                                        fillMode: Image.PreserveAspectCrop
                                    }

                                    Rectangle {
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            bottom: parent.bottom
                                        }

                                        height: 34
                                        color: root.luminaDesign.color.surfaceMuted

                                        Text {
                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                margins:
                                                    root.luminaDesign.spacing.small
                                                verticalCenter:
                                                    parent.verticalCenter
                                            }

                                            text: wallpaperTile.fileName
                                            color:
                                                root.luminaDesign.color.onSurface
                                            elide: Text.ElideMiddle
                                            font.pixelSize:
                                                root.luminaDesign.typography.labelSmall
                                        }
                                    }

                                    MouseArea {
                                        id: tileMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: WallpaperService.setWallpaper(
                                            pickerWindow.outputName,
                                            wallpaperTile.fileUrl
                                        )
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: wallpaperFiles.count === 0
                                text: "No images found in this folder"
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

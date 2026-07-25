pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.design
import qs.services.wallpaper

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    IpcHandler {
        target: "wallpaper"

        function set(outputName: string, path: string): void {
            WallpaperService.setWallpaper(outputName, path)
        }

        function dynamic(enabled: bool): void {
            WallpaperService.setDynamicTheme(enabled)
        }

        function palette(style: string): void {
            WallpaperService.setPaletteStyle(style)
        }

        function picker(outputName: string): void {
            WallpaperService.togglePicker(outputName)
        }

        function status(outputName: string): string {
            return JSON.stringify({
                output: WallpaperService.resolvedOutputName(outputName),
                wallpaper: WallpaperService.wallpaperFor(outputName),
                dynamicTheme: WallpaperService.dynamicThemeEnabled,
                paletteActive: Theme.dynamicPaletteActive,
                paletteStyle: WallpaperService.paletteStyle,
                primary: String(Theme.primaryColor)
            })
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: wallpaperWindow

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property string wallpaperPath:
                    WallpaperService.wallpaperFor(outputName)

                screen: modelData
                color: root.luminaDesign.color.surfaceBase
                focusable: false
                exclusiveZone: 0

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Background
                WlrLayershell.namespace: "lumina-wallpaper"
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                Rectangle {
                    anchors.fill: parent

                    gradient: Gradient {
                        GradientStop {
                            position: 0
                            color: Qt.darker(
                                root.luminaDesign.color.accentContainer,
                                1.5
                            )
                        }

                        GradientStop {
                            position: 1
                            color: root.luminaDesign.color.surfaceBase
                        }
                    }
                }

                Image {
                    id: wallpaperImage

                    anchors.fill: parent
                    source: WallpaperService.urlForPath(
                        wallpaperWindow.wallpaperPath
                    )
                    asynchronous: true
                    cache: true
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                    opacity: status === Image.Ready ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: root.luminaDesign.motion.slow
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}

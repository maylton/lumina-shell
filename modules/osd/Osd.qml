pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.design
import qs.modules.control
import "../control/ShellSurfacePolicy.js" as ShellSurfacePolicy
import qs.stores.osd
import qs.stores.config

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: osdWindow

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property bool osdVisible: OsdStore.visible
                    && OsdStore.outputName === outputName

                screen: modelData
                visible: osdVisible
                implicitWidth: Math.round(360 * ConfigStore.osdSize)
                implicitHeight: Math.round(104 * ConfigStore.osdSize)
                color: "transparent"
                surfaceFormat.opaque: false
                focusable: false
                exclusiveZone: 0

                anchors {
                    top: ConfigStore.osdPosition === "top"
                    bottom: ConfigStore.osdPosition === "bottom"
                }

                margins {
                    bottom: 64
                    top: 64
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lumina-osd"
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      BackgroundEffect.blurRegion:
          ShellSurfacePolicy.requestsBackdropBlur(
              ConfigStore.shellBackgroundMode
          )
              ? shellBlurRegion
              : null

      Region {
          id: shellBlurRegion

          Region {
              x: osdSurface.x
              y: osdSurface.y
              width: osdSurface.width
              height: osdSurface.height
              radius: osdSurface.radius
          }
      }

                ShellSurface {
          id: osdSurface

          anchors.fill: parent
          radius: root.luminaDesign.shape.extraLarge

                    Row {
                        anchors {
                            fill: parent
                            margins: root.luminaDesign.spacing.extraLarge
                        }

                        spacing: root.luminaDesign.spacing.large

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 54
                            height: 54
                            radius: root.luminaDesign.shape.large
                            color: root.luminaDesign.color.accentContainer

                            Text {
                                anchors.centerIn: parent
                                text: OsdStore.symbol
                                color: root.luminaDesign.color.onAccentContainer
                                font.pixelSize: 27
                                font.weight: Font.DemiBold
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 54
                                - parent.spacing
                            spacing: root.luminaDesign.spacing.small

                            Row {
                                width: parent.width

                                Text {
                                    width: parent.width - osdDetail.implicitWidth
                                    text: OsdStore.title
                                    color: root.luminaDesign.color.onSurface
                                    elide: Text.ElideRight
                                    font.pixelSize:
                                        root.luminaDesign.typography.titleMedium
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    id: osdDetail

                                    text: OsdStore.detail
                                    color: root.luminaDesign.color.primary
                                    font.pixelSize:
                                        root.luminaDesign.typography.labelMedium
                                    font.weight: Font.Bold
                                }
                            }

                            Rectangle {
                                visible: OsdStore.showProgress
                                width: parent.width
                                height: 8
                                radius: 4
                                color: root.luminaDesign.color.surfaceMuted
                                clip: true

                                Rectangle {
                                    width: parent.width * OsdStore.value
                                    height: parent.height
                                    radius: parent.radius
                                    color: root.luminaDesign.color.primary

                                    Behavior on width {
                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.fast
                                            easing.type: Easing.OutCubic
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

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.design

Scope {
    id: root

    property string formattedTime: Qt.formatDateTime(clock.date, "HH:mm")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData

                screen: modelData
                implicitHeight: Theme.barHeight
                exclusiveZone: Theme.barHeight
                color: "transparent"
                focusable: false

                anchors {
                    top: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "lumina-bar"

                Rectangle {
                    anchors {
                        fill: parent
                        margins: 6
                    }

                    radius: Theme.radiusLarge
                    color: Theme.surfaceContainer
                    border.width: 1
                    border.color: Theme.outline

                    Text {
                        anchors.centerIn: parent
                        text: root.formattedTime
                        color: Theme.onSurface
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                }
            }
        }
    }
}

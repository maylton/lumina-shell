pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.design
import qs.services.notifications

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: popupWindow

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property bool popupVisible:
                    NotificationService.popupEntries.length > 0
                    && NotificationService.popupOutputName === outputName

                screen: modelData
                visible: popupVisible
                color: "transparent"
                focusable: false
                exclusiveZone: 0
                implicitWidth: root.luminaDesign.size.notificationWidth
                implicitHeight: popupStack.implicitHeight

                anchors {
                    top: true
                    right: true
                }

                margins {
                    top: root.luminaDesign.size.barHeight
                        + root.luminaDesign.spacing.medium
                    right: root.luminaDesign.spacing.large
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lumina-notification-popups"
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                Column {
                    id: popupStack

                    width: parent.width
                    spacing: root.luminaDesign.spacing.medium

                    Repeater {
                        model: ScriptModel {
                            values: NotificationService.popupEntries
                        }

                        delegate: NotificationCard {
                            required property var modelData

                            width: popupStack.width
                            entry: modelData
                            popupMode: true
                        }
                    }
                }
            }
        }
    }
}

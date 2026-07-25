pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.design
import qs.services.notifications
import qs.stores.config

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
                    top:
                        ConfigStore.notificationPopupPosition
                            .indexOf("top") === 0
                    bottom:
                        ConfigStore.notificationPopupPosition
                            .indexOf("bottom") === 0
                    left:
                        ConfigStore.notificationPopupPosition
                            .indexOf("left") > 0
                    right:
                        ConfigStore.notificationPopupPosition
                            .indexOf("right") > 0
                }

                margins {
                    top:
                        ConfigStore.barPosition === "top"
                            ? root.luminaDesign.size.barWindowHeight
                                + root.luminaDesign.spacing.barPanelGap
                            : root.luminaDesign.spacing.barPanelGap
                    right: root.luminaDesign.spacing.large
                    bottom:
                        ConfigStore.barPosition === "bottom"
                            ? root.luminaDesign.size.barWindowHeight
                                + root.luminaDesign.spacing.barPanelGap
                            : root.luminaDesign.spacing.barPanelGap
                    left: root.luminaDesign.spacing.large
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

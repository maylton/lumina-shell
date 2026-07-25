pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.i18n
import qs.stores.control

Item {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real tabSpacing:
        luminaDesign.spacing.controlItemGap
    readonly property int selectedIndex:
        ControlCenterStore.activePage === "settings" ? 1 : 0
    readonly property real tabWidth:
        (width - tabSpacing) / 2
    readonly property string rocketIconSource: Qt.resolvedUrl(
        "../../assets/icons/rocket-symbolic.svg"
    )

    height: 44

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: root.luminaDesign.color.outline
        opacity: 0.48
    }

    Row {
        anchors.fill: parent
        spacing: root.tabSpacing

        Repeater {
            model: [
                {
                    id: "dashboard",
                    iconName: "",
                    symbol: "🚀",
                    label: I18n.tr(
                        "control.tab.dashboard",
                        "Dashboard"
                    )
                },
                {
                    id: "settings",
                    iconName: "",
                    symbol: "⚙",
                    label: I18n.tr(
                        "control.tab.settings",
                        "Settings"
                    )
                }
            ]

            delegate: Rectangle {
                id: tabButton

                required property var modelData
                readonly property bool selected:
                    ControlCenterStore.activePage === modelData.id

                width: root.tabWidth
                height: root.height
                color: "transparent"
                activeFocusOnTab: true

                Accessible.role: Accessible.PageTab
                Accessible.name: modelData.label
                Accessible.selected: selected
                Accessible.focusable: true
                Accessible.focused: activeFocus
                Accessible.onPressAction: activate()

                function activate() {
                    ControlCenterStore.setPage(modelData.id)
                }

                Keys.onSpacePressed: event => {
                    activate()
                    event.accepted = true
                }

                Keys.onReturnPressed: event => {
                    activate()
                    event.accepted = true
                }

                Row {
                    id: tabContent

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                        verticalCenterOffset: -2
                    }
                    spacing: root.luminaDesign.spacing.small

                    DashboardIcon {
                        width: 16
                        height: 16
                        iconName: tabButton.modelData.iconName
                        customSource:
                            tabButton.modelData.id === "dashboard"
                                ? root.rocketIconSource
                                : ""
                        fallbackSymbol: tabButton.modelData.symbol
                        fallbackScale:
                            tabButton.modelData.id === "settings"
                                ? 1.2
                                : 1
                        iconColor: tabButton.selected
                            ? root.luminaDesign.color.primary
                            : tabMouse.containsMouse
                                || tabButton.activeFocus
                                ? root.luminaDesign.color.onSurface
                                : root.luminaDesign.color.textMuted
                        iconSize: 16
                    }

                    Text {
                        text: tabButton.modelData.label
                        color: tabButton.selected
                            ? root.luminaDesign.color.primary
                            : tabMouse.containsMouse
                                || tabButton.activeFocus
                                ? root.luminaDesign.color.onSurface
                                : root.luminaDesign.color.textMuted
                        font.pixelSize:
                            root.luminaDesign.typography.bodyMedium
                        font.weight: tabButton.selected
                            ? Font.Bold
                            : Font.Medium

                        Behavior on color {
                            ColorAnimation {
                                duration:
                                    root.luminaDesign.motion.effectsFast
                                easing.type:
                                    root.luminaDesign.motion.effectsEasing
                            }
                        }
                    }
                }

                MouseArea {
                    id: tabMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        tabButton.forceActiveFocus(Qt.MouseFocusReason)
                        tabButton.activate()
                    }
                }
            }
        }
    }

    Rectangle {
        id: selectionIndicator

        x: root.selectedIndex * (root.tabWidth + root.tabSpacing)
        y: root.height - height
        width: root.tabWidth
        height: 4
        radius: root.luminaDesign.shape.full
        color: root.luminaDesign.color.primary

        Behavior on x {
            NumberAnimation {
                duration: root.luminaDesign.motion.pageTransition
                easing.type: root.luminaDesign.motion.spatialEasing
                easing.overshoot:
                    root.luminaDesign.motion.spatialOvershoot
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: root.luminaDesign.motion.spatialDefault
                easing.type: root.luminaDesign.motion.spatialEasing
                easing.overshoot:
                    root.luminaDesign.motion.spatialOvershoot
            }
        }
    }
}

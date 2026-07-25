pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.stores.control

Item {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real tabSpacing: luminaDesign.spacing.medium

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
                    iconName: "view-grid-symbolic",
                    symbol: "✦",
                    label: "Dashboard"
                },
                {
                    id: "settings",
                    iconName: "preferences-system-symbolic",
                    symbol: "⚙",
                    label: "Settings"
                }
            ]

            delegate: Rectangle {
                id: tabButton

                required property var modelData
                readonly property bool selected:
                    ControlCenterStore.activePage === modelData.id

                width: (root.width - root.tabSpacing) / 2
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
                        fallbackSymbol: tabButton.modelData.symbol
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
                    }
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: tabButton.selected
                        ? 4
                        : tabButton.activeFocus
                            ? 2
                            : 0
                    radius: root.luminaDesign.shape.full
                    color: root.luminaDesign.color.primary

                    Behavior on height {
                        NumberAnimation {
                            duration: root.luminaDesign.motion.fast
                            easing.type: Easing.OutCubic
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
}

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.SystemTray
import qs.design
import qs.modules.control
import qs.stores.config

Item {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var activeItems: {
        const items = []
        const values = SystemTray.items.values

        for (var index = 0; index < values.length; ++index) {
            const item = values[index]

            if (item && item.status !== Status.Passive)
                items.push(item)
        }

        return items
    }
    readonly property int itemCount: activeItems.length
    readonly property bool grouped: ConfigStore.barTrayMode === "grouped"

    property bool tooltipVisible: false

    visible: itemCount > 0
    implicitWidth: visible ? trayRow.implicitWidth : 0
    implicitHeight: luminaDesign.size.barTouchTarget

    Row {
        id: trayRow

        anchors.verticalCenter: parent.verticalCenter
        spacing: root.luminaDesign.spacing.extraSmall

        Rectangle {
            id: groupButton

            visible: root.grouped
            width: visible ? root.luminaDesign.size.barTouchTarget : 0
            height: root.luminaDesign.size.barTouchTarget
            radius: trayPopup.visible
                ? root.luminaDesign.shape.full
                : root.luminaDesign.shape.medium
            color: trayPopup.visible || groupMouse.containsMouse
                ? root.luminaDesign.color.accentContainer
                : ConfigStore.barBackgroundMode === "transparent"
                    ? root.luminaDesign.color.surfaceMuted
                    : "transparent"
            border.width: activeFocus ? 2 : 0
            border.color: root.luminaDesign.color.primary
            activeFocusOnTab: visible

            Accessible.role: Accessible.Button
            Accessible.name: trayPopup.visible
                ? qsTr("Hide system tray")
                : qsTr("Show system tray")
            Accessible.description: qsTr("%1 active items").arg(
                root.itemCount
            )
            Accessible.focusable: visible
            Accessible.focused: activeFocus
            Accessible.onPressAction: trayPopup.toggle()

            Keys.onSpacePressed: event => {
                trayPopup.toggle()
                event.accepted = true
            }

            Keys.onReturnPressed: event => {
                trayPopup.toggle()
                event.accepted = true
            }

            Behavior on color {
                ColorAnimation {
                    duration:
                        root.luminaDesign.motion.effectsFast
                    easing.type:
                        root.luminaDesign.motion.effectsEasing
                }
            }

            Behavior on radius {
                NumberAnimation {
                    duration:
                        root.luminaDesign.motion.spatialFast
                    easing.type:
                        root.luminaDesign.motion.spatialEasing
                    easing.overshoot:
                        root.luminaDesign.motion.spatialOvershoot
                }
            }

            DashboardIcon {
                anchors.centerIn: parent
                iconName: "view-more-horizontal-symbolic"
                fallbackSymbol: "•••"
                fallbackScale: 0.62
                iconColor: trayPopup.visible
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.onSurface
                iconSize: root.luminaDesign.size.barTrayIcon
            }

            Rectangle {
                anchors {
                    right: parent.right
                    top: parent.top
                }
                visible: root.itemCount > 1
                width: Math.max(
                    root.luminaDesign.size.barBadgeHeight,
                    trayCount.implicitWidth
                        + root.luminaDesign.size.barBadgePadding
                )
                height: root.luminaDesign.size.barBadgeHeight
                radius: root.luminaDesign.shape.full
                color: root.luminaDesign.color.primary

                Text {
                    id: trayCount

                    anchors.centerIn: parent
                    text: root.itemCount > 9
                        ? "9+"
                        : String(root.itemCount)
                    color: root.luminaDesign.color.surfaceBase
                    font.pixelSize:
                        root.luminaDesign.typography.barBadge
                    font.weight: Font.Bold
                }
            }

            MouseArea {
                id: groupMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: tooltipTimer.restart()
                onExited: {
                    tooltipTimer.stop()
                    root.tooltipVisible = false
                }
                onPressed: {
                    tooltipTimer.stop()
                    root.tooltipVisible = false
                }
                onClicked: {
                    groupButton.focus = false
                    trayPopup.toggle()
                }
            }
        }

        Repeater {
            model: root.grouped ? [] : root.activeItems

            delegate: TrayItem {
                required property var modelData

                trayItem: modelData
            }
        }
    }

    Timer {
        id: tooltipTimer

        interval: 450
        repeat: false
        onTriggered: root.tooltipVisible = groupMouse.containsMouse
    }

    TrayTooltip {
        anchorItem: groupButton
        title: qsTr("System tray")
        description: qsTr("%1 active items").arg(root.itemCount)
        shown: root.tooltipVisible && !trayPopup.visible
    }

    TrayPopup {
        id: trayPopup

        anchorItem: groupButton
        items: root.activeItems
    }

    Connections {
        target: ConfigStore

        function onBarTrayModeChanged() {
            trayPopup.dismiss()
        }
    }
}

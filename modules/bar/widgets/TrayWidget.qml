pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.SystemTray
import qs.design
import qs.modules.control
import qs.stores.config
import qs.stores.shell

Item {
    id: root

    required property string outputName
    property var panelWindow: null

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
    readonly property bool grouped: ConfigStore.widgetSetting(
        "tray",
        "mode",
        "grouped"
    ) === "grouped"
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "tray",
            "showBackground",
            false
        )
    )
    readonly property bool showCount: Boolean(
        ConfigStore.widgetSetting("tray", "showCount", false)
    )
    readonly property string surfacePlacement: String(
        ConfigStore.widgetSetting(
            "tray",
            "surfacePlacement",
            "near-widget"
        )
    )

    property bool tooltipVisible: false

    function mappedAnchorGeometry(localX) {
        const top = groupButton.mapToItem(
            null,
            Number(localX),
            0
        )
        const bottom = groupButton.mapToItem(
            null,
            Number(localX),
            groupButton.height
        )

        return {
            x: Number(top.x),
            top: Number(top.y),
            bottom: Number(bottom.y)
        }
    }

    function togglePopup(localX) {
        const anchor = mappedAnchorGeometry(localX)

        BarPanelCoordinator.requestToggle(
            "tray",
            root.outputName,
            root.surfacePlacement,
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

    visible: itemCount > 0
    implicitWidth: visible ? trayRow.implicitWidth : 0
    implicitHeight: luminaDesign.size.barTouchTarget

    Row {
        id: trayRow

        anchors.verticalCenter: parent.verticalCenter
        spacing: root.luminaDesign.spacing.barItemGap

        Rectangle {
            id: groupButton

            visible: root.grouped
            width: visible ? root.luminaDesign.size.barTouchTarget : 0
            height: root.luminaDesign.size.barTouchTarget
            radius: trayPanel.visible || groupMouse.pressed
                ? root.luminaDesign.shape.barIconActivated
                : height / 2
            color: trayPanel.visible || groupMouse.containsMouse
                ? root.luminaDesign.color.accentContainer
                : root.showBackground
                    ? root.luminaDesign.color.surfaceMuted
                    : "transparent"
            border.width: activeFocus ? 2 : 0
            border.color: root.luminaDesign.color.primary
            activeFocusOnTab: visible

            Accessible.role: Accessible.Button
            Accessible.name: trayPanel.visible
                ? qsTr("Hide system tray")
                : qsTr("Show system tray")
            Accessible.description: qsTr("%1 active items").arg(
                root.itemCount
            )
            Accessible.focusable: visible
            Accessible.focused: activeFocus
            Accessible.onPressAction: root.togglePopup(groupButton.width / 2)

            Keys.onSpacePressed: event => {
                root.togglePopup(groupButton.width / 2)
                event.accepted = true
            }

            Keys.onReturnPressed: event => {
                root.togglePopup(groupButton.width / 2)
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
                iconColor: trayPanel.visible
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.onSurface
                iconSize: root.luminaDesign.size.barTrayIcon
            }

            Rectangle {
                anchors {
                    right: parent.right
                    top: parent.top
                }
                visible: root.showCount && root.itemCount > 0
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
                onClicked: mouse => {
                    groupButton.focus = false
                    root.togglePopup(mouse.x)
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
        shown: root.tooltipVisible && !trayPanel.visible
    }

    TrayPanel {
        id: trayPanel

        outputName: root.outputName
        panelWindow: root.panelWindow
        items: root.activeItems
    }

    Connections {
        target: BarPanelCoordinator

        function onOpenRequested(
            panelId,
            outputName,
            placement,
            anchorX,
            anchorTop,
            anchorBottom
        ) {
            if (panelId !== "tray" || outputName !== root.outputName)
                return

            OverlayStore.prepareFor(
                "tray",
                root.outputName,
                placement,
                anchorX,
                anchorTop,
                anchorBottom
            )
            OverlayStore.openFor("tray", root.outputName)
        }

        function onCloseRequested(panelId, outputName) {
            if (panelId !== "tray" || outputName !== root.outputName)
                return

            trayPanel.dismiss()
        }
    }

    Connections {
        target: ConfigStore

        function onBarWidgetSettingsChanged() {
            trayPanel.dismiss()
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.design
import qs.stores.config

Rectangle {
    id: root

    required property var trayItem

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property string itemTitle: {
        if (!trayItem)
            return qsTr("System tray item")

        return String(trayItem.tooltipTitle || trayItem.title || trayItem.id
            || qsTr("System tray item"))
    }
    readonly property string itemDescription: trayItem
        ? String(trayItem.tooltipDescription || "")
        : ""
    readonly property bool needsAttention: trayItem
        && trayItem.status === Status.NeedsAttention

    property bool tooltipVisible: false

    function showMenu() {
        if (!trayItem || !trayItem.hasMenu)
            return

        tooltipTimer.stop()
        tooltipVisible = false
        trayMenu.show()
    }

    implicitWidth: luminaDesign.size.barTouchTarget
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: needsAttention
        ? luminaDesign.shape.full
        : luminaDesign.shape.medium
    scale: itemMouse.pressed
        ? 0.96
        : 1.0
    color: needsAttention
        ? luminaDesign.color.accentContainer
        : itemMouse.pressed
            ? Qt.darker(luminaDesign.color.surfaceMuted, 1.12)
            : itemMouse.containsMouse
                ? luminaDesign.color.surfaceMuted
                : ConfigStore.barBackgroundMode === "transparent"
                    ? luminaDesign.color.surfaceMuted
                    : "transparent"
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: itemTitle
    Accessible.description: itemDescription
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate()

    function activate() {
        if (!trayItem)
            return

        if (trayItem.onlyMenu && trayItem.hasMenu)
            showMenu()
        else
            trayItem.activate()
    }

    Keys.onSpacePressed: event => {
        activate()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activate()
        event.accepted = true
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialFast
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: root.luminaDesign.size.barTrayIcon
        height: root.luminaDesign.size.barTrayIcon
        radius: root.luminaDesign.shape.small
        color: root.luminaDesign.color.surfaceMuted
        visible: String(trayIcon.source).length === 0
            || trayIcon.status === Image.Error

        Text {
            anchors.centerIn: parent
            text: root.itemTitle.length > 0
                ? root.itemTitle.charAt(0).toLocaleUpperCase()
                : "•"
            color: root.luminaDesign.color.onSurface
            font.pixelSize: root.luminaDesign.typography.barBadge
            font.weight: Font.DemiBold
        }
    }

    IconImage {
        id: trayIcon

        anchors.centerIn: parent
        width: root.luminaDesign.size.barTrayIcon
        height: root.luminaDesign.size.barTrayIcon
        source: root.trayItem ? String(root.trayItem.icon || "") : ""
        asynchronous: true
        mipmap: true
    }

    Rectangle {
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 3
        }

        width: root.luminaDesign.size.barStatusDot
        height: root.luminaDesign.size.barStatusDot
        radius: width / 2
        visible: root.needsAttention
        color: root.luminaDesign.color.urgent
        border.width: 1
        border.color: root.luminaDesign.color.surfaceContainer
    }

    MouseArea {
        id: itemMouse

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
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
            if (!root.trayItem)
                return

            if (mouse.button === Qt.RightButton) {
                root.showMenu()
            } else if (mouse.button === Qt.MiddleButton) {
                root.trayItem.secondaryActivate()
            } else if (root.trayItem.onlyMenu && root.trayItem.hasMenu) {
                root.showMenu()
            } else {
                root.trayItem.activate()
            }
        }

        onWheel: wheel => {
            if (!root.trayItem)
                return

            if (wheel.angleDelta.y !== 0)
                root.trayItem.scroll(wheel.angleDelta.y, false)
            else if (wheel.angleDelta.x !== 0)
                root.trayItem.scroll(wheel.angleDelta.x, true)
        }
    }

    Timer {
        id: tooltipTimer

        interval: 450
        repeat: false
        onTriggered: root.tooltipVisible = itemMouse.containsMouse
    }

    TrayTooltip {
        anchorItem: root
        title: root.itemTitle
        description: root.itemDescription
        shown: root.tooltipVisible && !trayMenu.visible
    }

    TrayMenu {
        id: trayMenu

        anchorItem: root
        trayItem: root.trayItem
    }
}

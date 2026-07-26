pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.connectivity
import qs.services.i18n
import qs.stores.shell

Item {
    id: root

    required property string outputName
    property var panelWindow: null
    property bool tooltipVisible: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var connectedDevices:
        BluetoothManagerService.devices.filter(function(device) {
            return Boolean(device.connected)
        })
    readonly property int connectedCount: connectedDevices.length
    readonly property bool bluetoothEnabled:
        ConnectivityService.bluetoothEnabled
    readonly property bool available:
        ConnectivityService.bluetoothAvailable

    implicitWidth: luminaDesign.size.barTouchTarget
    implicitHeight: luminaDesign.size.barTouchTarget
    width: implicitWidth
    height: implicitHeight

    Component.onCompleted: {
        BluetoothManagerService.setActive(true)
        BluetoothManagerService.refresh()
    }

    function mappedAnchorGeometry(localX) {
        const top = bluetoothButton.mapToItem(
            null,
            Number(localX),
            0
        )
        const bottom = bluetoothButton.mapToItem(
            null,
            Number(localX),
            bluetoothButton.height
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
            "bluetooth",
            root.outputName,
            "near-widget",
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

    Rectangle {
        id: bluetoothButton

        anchors.fill: parent
        radius: bluetoothPopup.visible || buttonMouse.pressed
            ? root.luminaDesign.shape.barIconActivated
            : height / 2
        color: bluetoothPopup.visible || buttonMouse.containsMouse
            ? root.luminaDesign.color.accentContainer
            : root.connectedCount > 0
                ? root.luminaDesign.color.surfaceMuted
                : "transparent"
        opacity: root.available ? 1 : 0.45
        scale: buttonMouse.pressed ? 0.96 : 1
        activeFocusOnTab: root.available
        border.width: activeFocus ? 2 : 0
        border.color: root.luminaDesign.color.primary

        Accessible.role: Accessible.Button
        Accessible.name: bluetoothPopup.visible
            ? I18n.tr(
                "bar.bluetooth.accessible.close",
                "Close Bluetooth panel"
            )
            : I18n.tr(
                "bar.bluetooth.accessible.open",
                "Open Bluetooth panel"
            )
        Accessible.description: root.connectedCount > 0
            ? I18n.tr(
                "bar.bluetooth.connectedCount",
                "%1 connected",
                [root.connectedCount]
            )
            : root.bluetoothEnabled
                ? I18n.tr(
                    "settings.connectivity.bluetooth.status.on",
                    "On"
                )
                : I18n.tr(
                    "dashboard.status.disabled",
                    "Disabled"
                )
        Accessible.focusable: root.available
        Accessible.focused: activeFocus
        Accessible.onPressAction:
            root.togglePopup(bluetoothButton.width / 2)

        Keys.onSpacePressed: event => {
            root.togglePopup(bluetoothButton.width / 2)
            event.accepted = true
        }

        Keys.onReturnPressed: event => {
            root.togglePopup(bluetoothButton.width / 2)
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

        DashboardIcon {
            anchors.centerIn: parent
            iconName: root.bluetoothEnabled
                ? root.connectedCount > 0
                    ? "bluetooth-active-symbolic"
                    : "bluetooth-symbolic"
                : "bluetooth-disabled-symbolic"
            fallbackSymbol: "ᛒ"
            iconColor: bluetoothPopup.visible
                ? root.luminaDesign.color.onAccentContainer
                : root.bluetoothEnabled
                    ? root.luminaDesign.color.onSurface
                    : root.luminaDesign.color.textMuted
            iconSize: root.luminaDesign.size.barIcon
        }

        Rectangle {
            anchors {
                right: parent.right
                top: parent.top
            }
            visible: root.connectedCount > 0
            width: Math.max(
                root.luminaDesign.size.barBadgeHeight,
                countLabel.implicitWidth
                    + root.luminaDesign.size.barBadgePadding
            )
            height: root.luminaDesign.size.barBadgeHeight
            radius: root.luminaDesign.shape.full
            color: root.luminaDesign.color.primary

            Text {
                id: countLabel

                anchors.centerIn: parent
                text: root.connectedCount > 9
                    ? "9+"
                    : String(root.connectedCount)
                color: root.luminaDesign.color.surfaceBase
                font.pixelSize: root.luminaDesign.typography.barBadge
                font.weight: Font.Bold
            }
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true
            enabled: root.available
            cursorShape: enabled
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor
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
                bluetoothButton.focus = false
                root.togglePopup(mouse.x)
            }
        }
    }

    Timer {
        id: tooltipTimer

        interval: 450
        repeat: false
        onTriggered: root.tooltipVisible = buttonMouse.containsMouse
    }

    TrayTooltip {
        anchorItem: bluetoothButton
        title: I18n.tr(
            "bar.bluetooth.tooltip.title",
            "Bluetooth"
        )
        description: root.connectedCount > 0
            ? I18n.tr(
                "bar.bluetooth.connectedCount",
                "%1 connected",
                [root.connectedCount]
            )
            : root.bluetoothEnabled
                ? I18n.tr(
                    "settings.connectivity.bluetooth.status.on",
                    "On"
                )
                : I18n.tr(
                    "dashboard.status.disabled",
                    "Disabled"
                )
        shown: root.tooltipVisible && !bluetoothPopup.visible
    }

    BluetoothPopup {
        id: bluetoothPopup

        anchorItem: bluetoothButton
        panelWindow: root.panelWindow
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
            if (panelId !== "bluetooth" || outputName !== root.outputName)
                return

            bluetoothPopup.placement = placement
            bluetoothPopup.anchorX = anchorX
            if (!bluetoothPopup.requestedVisible)
                bluetoothPopup.toggle()
        }

        function onCloseRequested(panelId, outputName) {
            if (panelId !== "bluetooth" || outputName !== root.outputName)
                return

            if (bluetoothPopup.requestedVisible)
                bluetoothPopup.dismiss()
            else
                BarPanelCoordinator.reportClosed(
                    "bluetooth",
                    root.outputName
                )
        }
    }

    Connections {
        target: bluetoothPopup

        function onRequestedVisibleChanged() {
            BarPanelCoordinator.synchronizeIndependentPanel(
                "bluetooth",
                root.outputName,
                bluetoothPopup.requestedVisible
            )
        }
    }
}

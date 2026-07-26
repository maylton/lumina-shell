pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.connectivity
import qs.services.i18n
import qs.stores.config
import qs.stores.shell
import "../../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

BarPanelWindow {
    id: root

    required property string outputName
    property var panelWindow: null

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real panelWidth: Math.min(
        420,
        width - 32
    )
    readonly property real panelHeight: Math.max(
        360,
        Math.min(
            560,
            availableScreenHeight
                - SurfacePlacementPolicy.barWindowHeight(
                    ConfigStore.barHeight,
                    ConfigStore.barSurfaceMode,
                    ConfigStore.barMargin
                )
                - 32
        )
    )
    readonly property var connectedDevices:
        BluetoothManagerService.devices.filter(function(device) {
            return Boolean(device.connected)
        })
    readonly property var pairedDevices:
        BluetoothManagerService.devices.filter(function(device) {
            return Boolean(device.paired) && !device.connected
        })
    readonly property var foundDevices:
        BluetoothManagerService.devices.filter(function(device) {
            return !device.paired && !device.connected
        })
    readonly property int deviceCount:
        connectedDevices.length + pairedDevices.length + foundDevices.length
    readonly property real availableScreenHeight:
        panelWindow && panelWindow.screen
            ? panelWindow.screen.height
            : 720

    function prepareContent() {
        BluetoothManagerService.setActive(true)
        BluetoothManagerService.refresh()
    }

    function dismiss() {
        OverlayStore.close("bluetooth")
    }

    function statusDescription() {
        const code = BluetoothManagerService.statusCode
        const name = BluetoothManagerService.targetName
            || BluetoothManagerService.targetAddress
        const replacements = [name]

        switch (code) {
        case "scanning":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.scanning",
                "Searching for Bluetooth devices"
            )
        case "scan-complete":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.scanComplete",
                "Bluetooth device search completed"
            )
        case "scan-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.scanFailed",
                "Bluetooth device search failed"
            )
        case "pairing":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.pairing",
                "Pairing with %1",
                replacements
            )
        case "connecting":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.connecting",
                "Connecting to %1",
                replacements
            )
        case "disconnecting":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.disconnecting",
                "Disconnecting %1",
                replacements
            )
        case "forgetting":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.forgetting",
                "Forgetting %1",
                replacements
            )
        case "connected":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.connected",
                "%1 is connected",
                replacements
            )
        case "disconnected":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.disconnected",
                "%1 is disconnected",
                replacements
            )
        case "forgotten":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.forgotten",
                "%1 was forgotten",
                replacements
            )
        case "paired-not-connected":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.pairedNotConnected",
                "%1 was paired, but the connection could not be confirmed",
                replacements
            )
        case "authentication-required":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.authenticationRequired",
                "%1 requires a PIN or confirmation that Lumina does not support yet",
                replacements
            )
        case "pair-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.pairFailed",
                "Could not pair with %1",
                replacements
            )
        case "connect-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.connectFailed",
                "Could not confirm a connection to %1",
                replacements
            )
        case "disconnect-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.disconnectFailed",
                "Could not confirm that %1 disconnected",
                replacements
            )
        case "forget-failed":
            return I18n.tr(
                "settings.connectivity.bluetooth.status.forgetFailed",
                "Could not forget %1",
                replacements
            )
        default:
            if (!ConnectivityService.bluetoothAvailable) {
                return I18n.tr(
                    "dashboard.status.unavailable",
                    "Unavailable"
                )
            }
            if (!ConnectivityService.bluetoothEnabled) {
                return I18n.tr(
                    "dashboard.status.disabled",
                    "Disabled"
                )
            }
            if (connectedDevices.length > 0) {
                return I18n.tr(
                    "bar.bluetooth.connectedCount",
                    "%1 connected",
                    [connectedDevices.length]
                )
            }
            return I18n.tr(
                "settings.connectivity.bluetooth.status.on",
                "On"
            )
        }
    }

    panelId: "bluetooth"
    panelOutputName: outputName
    panelVisible: panelWindow !== null
        && OverlayStore.isOpenFor("bluetooth", outputName)
    layerNamespace: "lumina-bluetooth-panel"
    screen: panelWindow ? panelWindow.screen : null
    surfaceItem: bluetoothSurface
    surfaceRadius: bluetoothSurface.radius
    onDismissRequested: dismiss()

    onClosed: dismiss()

    Rectangle {
        id: bluetoothSurface

        x: SurfacePlacementPolicy.horizontalX(
            OverlayStore.activePlacement,
            OverlayStore.activeAnchorX,
            width,
            root.width,
            root.luminaDesign.spacing.medium
        )
        y: SurfacePlacementPolicy.verticalY(
            OverlayStore.activePlacement,
            ConfigStore.barPosition,
            height,
            root.height,
            SurfacePlacementPolicy.barWindowHeight(
                ConfigStore.barHeight,
                ConfigStore.barSurfaceMode,
                ConfigStore.barMargin
            ),
            root.luminaDesign.spacing.barPanelGap,
            root.luminaDesign.spacing.medium,
            OverlayStore.activeAnchorTop,
            OverlayStore.activeAnchorBottom
        )
        width: root.panelWidth
        height: root.panelHeight
        radius: root.luminaDesign.shape.extraLarge
        color: root.luminaDesign.color.surfaceContainer
        border.width: 1
        border.color: root.luminaDesign.color.outline
        opacity: root.visible ? 1 : 0
        scale: root.visible ? 1 : 0.97

        Behavior on opacity {
            NumberAnimation {
                duration: root.luminaDesign.motion.effectsDefault
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.luminaDesign.motion.spatialDefault
                easing.type: root.luminaDesign.motion.spatialEasing
                easing.overshoot:
                    root.luminaDesign.motion.spatialOvershoot
            }
        }

        Column {
            anchors {
                fill: parent
                margins: root.luminaDesign.spacing.large
            }
            spacing: root.luminaDesign.spacing.medium

            Item {
                width: parent.width
                height: 56

                Column {
                    anchors {
                        left: parent.left
                        right: headerActions.left
                        rightMargin: root.luminaDesign.spacing.medium
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 2

                    Text {
                        width: parent.width
                        text: I18n.tr(
                            "bar.bluetooth.panel.title",
                            "Bluetooth"
                        )
                        color: root.luminaDesign.color.onSurface
                        elide: Text.ElideRight
                        font.pixelSize:
                            root.luminaDesign.typography.titleLarge
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        text: root.statusDescription()
                        color: root.luminaDesign.color.textMuted
                        elide: Text.ElideRight
                        font.pixelSize:
                            root.luminaDesign.typography.labelMedium
                    }
                }

                Row {
                    id: headerActions

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: root.luminaDesign.spacing.small

                    Rectangle {
                        id: powerButton

                        width: 74
                        height: 38
                        radius: root.luminaDesign.shape.full
                        color: ConnectivityService.bluetoothEnabled
                            ? root.luminaDesign.color.accentContainer
                            : root.luminaDesign.color.surfaceMuted
                        opacity: ConnectivityService.bluetoothAvailable ? 1 : 0.45
                        activeFocusOnTab:
                            ConnectivityService.bluetoothAvailable
                        border.width: activeFocus ? 2 : 0
                        border.color: root.luminaDesign.color.primary

                        Accessible.role: Accessible.CheckBox
                        Accessible.name: I18n.tr(
                            "bar.bluetooth.panel.toggle",
                            "Toggle Bluetooth"
                        )
                        Accessible.checked:
                            ConnectivityService.bluetoothEnabled
                        Accessible.focusable:
                            ConnectivityService.bluetoothAvailable
                        Accessible.focused: activeFocus
                        Accessible.onPressAction:
                            BluetoothManagerService.setEnabled(
                                !ConnectivityService.bluetoothEnabled
                            )

                        Keys.onSpacePressed: event => {
                            BluetoothManagerService.setEnabled(
                                !ConnectivityService.bluetoothEnabled
                            )
                            event.accepted = true
                        }
                        Keys.onReturnPressed: event => {
                            BluetoothManagerService.setEnabled(
                                !ConnectivityService.bluetoothEnabled
                            )
                            event.accepted = true
                        }

                        Text {
                            anchors.centerIn: parent
                            text: ConnectivityService.bluetoothEnabled
                                ? I18n.tr(
                                    "bar.bluetooth.panel.on",
                                    "On"
                                )
                                : I18n.tr(
                                    "bar.bluetooth.panel.off",
                                    "Off"
                                )
                            color: ConnectivityService.bluetoothEnabled
                                ? root.luminaDesign.color.onAccentContainer
                                : root.luminaDesign.color.onSurface
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: ConnectivityService.bluetoothAvailable
                            cursorShape: enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor
                            onClicked: BluetoothManagerService.setEnabled(
                                !ConnectivityService.bluetoothEnabled
                            )
                        }
                    }

                    Rectangle {
                        id: scanButton

                        width: 38
                        height: 38
                        radius: root.luminaDesign.shape.full
                        color: scanMouse.containsMouse
                            ? root.luminaDesign.color.accentContainer
                            : root.luminaDesign.color.surfaceMuted
                        opacity: ConnectivityService.bluetoothEnabled
                            && !BluetoothManagerService.busy
                            ? 1
                            : 0.45
                        activeFocusOnTab:
                            ConnectivityService.bluetoothEnabled
                            && !BluetoothManagerService.busy
                        border.width: activeFocus ? 2 : 0
                        border.color: root.luminaDesign.color.primary

                        Accessible.role: Accessible.Button
                        Accessible.name: I18n.tr(
                            "settings.connectivity.bluetooth.scan",
                            "Find Bluetooth devices"
                        )
                        Accessible.focusable:
                            ConnectivityService.bluetoothEnabled
                            && !BluetoothManagerService.busy
                        Accessible.focused: activeFocus
                        Accessible.onPressAction:
                            BluetoothManagerService.scan()

                        Keys.onSpacePressed: event => {
                            BluetoothManagerService.scan()
                            event.accepted = true
                        }
                        Keys.onReturnPressed: event => {
                            BluetoothManagerService.scan()
                            event.accepted = true
                        }

                        DashboardIcon {
                            anchors.centerIn: parent
                            iconName: "view-refresh-symbolic"
                            fallbackSymbol: "↻"
                            iconColor: scanMouse.containsMouse
                                ? root.luminaDesign.color.onAccentContainer
                                : root.luminaDesign.color.onSurface
                            iconSize: 18
                            rotation: BluetoothManagerService.busyAction === "scan"
                                ? 360
                                : 0

                            Behavior on rotation {
                                NumberAnimation {
                                    duration: 800
                                    loops: Animation.Infinite
                                }
                            }
                        }

                        MouseArea {
                            id: scanMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: ConnectivityService.bluetoothEnabled
                                && !BluetoothManagerService.busy
                            cursorShape: enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor
                            onClicked: BluetoothManagerService.scan()
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: root.luminaDesign.color.divider
            }

            Flickable {
                width: parent.width
                height: parent.height - 56 - parent.spacing * 2 - 1
                contentWidth: width
                contentHeight: devicesColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 2600

                Column {
                    id: devicesColumn

                    width: parent.width
                    spacing: root.luminaDesign.spacing.large

                    Column {
                        width: parent.width
                        visible: root.connectedDevices.length > 0
                        spacing: root.luminaDesign.spacing.small

                        Text {
                            text: I18n.tr(
                                "bar.bluetooth.section.connected",
                                "Connected"
                            )
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        Repeater {
                            model: root.connectedDevices

                            delegate: BluetoothDeviceRow {
                                required property var modelData

                                width: devicesColumn.width
                                deviceName: modelData.name
                                address: modelData.address
                                connected: true
                                paired: true
                                busy: BluetoothManagerService.busy
                                showForget: true
                                primaryLabel: BluetoothManagerService.busyAction
                                    === "disconnect"
                                    && BluetoothManagerService.targetAddress
                                        === modelData.address
                                    ? I18n.tr(
                                        "settings.connectivity.bluetooth.action.disconnecting",
                                        "Disconnecting"
                                    )
                                    : I18n.tr(
                                        "settings.connectivity.disconnect",
                                        "Disconnect"
                                    )
                                onPrimaryActivated:
                                    BluetoothManagerService.disconnectDevice(
                                        modelData.address
                                    )
                                onForgetActivated:
                                    BluetoothManagerService.forgetDevice(
                                        modelData.address
                                    )
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        visible: root.pairedDevices.length > 0
                        spacing: root.luminaDesign.spacing.small

                        Text {
                            text: I18n.tr(
                                "bar.bluetooth.section.paired",
                                "Paired"
                            )
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        Repeater {
                            model: root.pairedDevices

                            delegate: BluetoothDeviceRow {
                                required property var modelData

                                width: devicesColumn.width
                                deviceName: modelData.name
                                address: modelData.address
                                paired: true
                                busy: BluetoothManagerService.busy
                                showForget: true
                                primaryLabel: BluetoothManagerService.busyAction
                                    === "connect"
                                    && BluetoothManagerService.targetAddress
                                        === modelData.address
                                    ? I18n.tr(
                                        "settings.connectivity.bluetooth.action.connecting",
                                        "Connecting"
                                    )
                                    : I18n.tr(
                                        "settings.connectivity.connect",
                                        "Connect"
                                    )
                                onPrimaryActivated:
                                    BluetoothManagerService.connectDevice(
                                        modelData.address
                                    )
                                onForgetActivated:
                                    BluetoothManagerService.forgetDevice(
                                        modelData.address
                                    )
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        visible: root.foundDevices.length > 0
                        spacing: root.luminaDesign.spacing.small

                        Text {
                            text: I18n.tr(
                                "bar.bluetooth.section.available",
                                "Available devices"
                            )
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        Repeater {
                            model: root.foundDevices

                            delegate: BluetoothDeviceRow {
                                required property var modelData

                                width: devicesColumn.width
                                deviceName: modelData.name
                                address: modelData.address
                                busy: BluetoothManagerService.busy
                                primaryLabel: BluetoothManagerService.busyAction
                                    === "pair"
                                    && BluetoothManagerService.targetAddress
                                        === modelData.address
                                    ? I18n.tr(
                                        "settings.connectivity.bluetooth.action.pairing",
                                        "Pairing"
                                    )
                                    : I18n.tr(
                                        "settings.connectivity.bluetooth.pair",
                                        "Pair"
                                    )
                                onPrimaryActivated:
                                    BluetoothManagerService.pair(
                                        modelData.address
                                    )
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        visible: root.deviceCount === 0
                        spacing: root.luminaDesign.spacing.medium

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 64
                            height: 64
                            radius: root.luminaDesign.shape.full
                            color: root.luminaDesign.color.surfaceMuted

                            DashboardIcon {
                                anchors.centerIn: parent
                                iconName: ConnectivityService.bluetoothEnabled
                                    ? "bluetooth-symbolic"
                                    : "bluetooth-disabled-symbolic"
                                fallbackSymbol: "ᛒ"
                                iconColor: root.luminaDesign.color.primary
                                iconSize: 28
                            }
                        }

                        Text {
                            width: parent.width
                            text: ConnectivityService.bluetoothEnabled
                                ? I18n.tr(
                                    "bar.bluetooth.empty.title",
                                    "No Bluetooth devices found"
                                )
                                : I18n.tr(
                                    "bar.bluetooth.empty.disabledTitle",
                                    "Bluetooth is turned off"
                                )
                            horizontalAlignment: Text.AlignHCenter
                            color: root.luminaDesign.color.onSurface
                            font.pixelSize:
                                root.luminaDesign.typography.titleMedium
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width
                            text: ConnectivityService.bluetoothEnabled
                                ? I18n.tr(
                                    "bar.bluetooth.empty.description",
                                    "Run a search to find nearby devices"
                                )
                                : I18n.tr(
                                    "bar.bluetooth.empty.disabledDescription",
                                    "Turn Bluetooth on to manage devices"
                                )
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize:
                                root.luminaDesign.typography.bodyMedium
                        }
                    }
                }
            }
        }
    }
}

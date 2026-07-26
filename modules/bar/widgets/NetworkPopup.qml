pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.modules.control
import qs.modules.control.settings.pages.connectivity as ConnectivityViews
import qs.services.connectivity
import qs.services.i18n
import qs.stores.config
import "../../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

PopupWindow {
    id: root

    property var anchorItem: null
    property var panelWindow: null
    property string placement: "near-widget"
    property real anchorX: -1
    property bool requestedVisible: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var wiredProfiles:
        ConnectivityManagerService.wiredProfiles()
    readonly property var wiredDevices:
        ConnectivityManagerService.wiredDevices()
    readonly property var wifiNetworks: {
        const values = ConnectivityManagerService.wifiNetworks.slice()
        values.sort(function(first, second) {
            const activeDifference = Number(Boolean(second.active))
                - Number(Boolean(first.active))
            return activeDifference !== 0
                ? activeDifference
                : Number(second.signal || 0) - Number(first.signal || 0)
        })
        return values
    }
    readonly property real availableScreenHeight:
        panelWindow && panelWindow.screen
            ? panelWindow.screen.height
            : 720

    function toggle() {
        requestedVisible = !requestedVisible
        if (requestedVisible) {
            ConnectivityManagerService.setActiveSection("wifi")
            ConnectivityManagerService.refreshAll()
        } else {
            releaseManager()
        }
    }

    function dismiss() {
        requestedVisible = false
        passwordDialog.close()
        releaseManager()
    }

    function releaseManager() {
        if (ConnectivityManagerService.activeSection === "wifi")
            ConnectivityManagerService.setActiveSection("")
    }

    function needsPassword(network) {
        const security = String(network && network.security || "").trim()
        return security.length > 0 && security !== "--"
    }

    function requestWifiConnection(network) {
        if (!network || ConnectivityManagerService.busy)
            return

        if (network.active) {
            ConnectivityManagerService.disconnectWifi()
            return
        }

        const saved = ConnectivityManagerService.savedWifiProfile(network.ssid)
        if (saved) {
            ConnectivityManagerService.activateConnection(saved.uuid)
        } else if (needsPassword(network)) {
            passwordDialog.openFor(network)
        } else {
            ConnectivityManagerService.connectWifi(
                network.ssid,
                network.security,
                ""
            )
        }
    }

    function localizedWiredState(state) {
        const normalized = String(state || "unknown")
            .toLowerCase()
            .replace(/\s+/g, "-")
        const supported = [
            "connected", "connecting", "disconnected",
            "disconnecting", "unavailable", "unmanaged"
        ]
        const key = supported.indexOf(normalized) >= 0
            ? normalized
            : "unknown"
        return I18n.tr(
            "settings.connectivity.wired.state." + key,
            String(state || "Unknown")
        )
    }

    visible: requestedVisible
        && anchorItem !== null
        && panelWindow !== null
    implicitWidth: Math.min(
        520,
        panelWindow && panelWindow.screen
            ? panelWindow.screen.width - 32
            : 520
    )
    implicitHeight: Math.max(
        420,
        Math.min(
            620,
            availableScreenHeight
                - (panelWindow ? panelWindow.height : 0)
                - 32
        )
    )
    color: "transparent"
    grabFocus: true

    anchor.window: root.panelWindow
    anchor.rect.x: SurfacePlacementPolicy.horizontalX(
        root.placement,
        root.anchorX,
        root.implicitWidth,
        root.panelWindow && root.panelWindow.screen
            ? root.panelWindow.screen.width
            : 0,
        root.luminaDesign.spacing.medium
    )
    anchor.rect.y: SurfacePlacementPolicy.popupY(
        root.placement,
        ConfigStore.barPosition,
        root.implicitHeight,
        root.availableScreenHeight,
        root.panelWindow ? root.panelWindow.height : 0,
        root.luminaDesign.spacing.barPanelGap,
        root.luminaDesign.spacing.medium
    )
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.All

    onClosed: dismiss()

    Rectangle {
        anchors.fill: parent
        radius: root.luminaDesign.shape.extraLarge
        color: root.luminaDesign.color.surfaceContainer
        border.width: 1
        border.color: root.luminaDesign.color.outline

        Column {
            anchors {
                fill: parent
                margins: root.luminaDesign.spacing.large
            }
            spacing: root.luminaDesign.spacing.medium

            Item {
                width: parent.width
                height: 58

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
                        text: I18n.tr("bar.network.panel.title", "Network")
                        color: root.luminaDesign.color.onSurface
                        elide: Text.ElideRight
                        font.pixelSize: root.luminaDesign.typography.titleLarge
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        text: ConnectivityManagerService.lastError
                            || ConnectivityManagerService.statusMessage
                            || ConnectivityService.networkSummary
                        color: ConnectivityManagerService.lastError
                            ? root.luminaDesign.color.urgent
                            : root.luminaDesign.color.textMuted
                        elide: Text.ElideRight
                        font.pixelSize: root.luminaDesign.typography.labelMedium
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
                        width: 84
                        height: 38
                        radius: root.luminaDesign.shape.full
                        color: ConnectivityService.wifiEnabled
                            ? root.luminaDesign.color.accentContainer
                            : root.luminaDesign.color.surfaceMuted
                        opacity: ConnectivityService.wifiAvailable ? 1 : 0.45

                        Text {
                            anchors.centerIn: parent
                            text: ConnectivityService.wifiEnabled
                                ? I18n.tr("bar.network.panel.wifiOn", "Wi-Fi on")
                                : I18n.tr("bar.network.panel.wifiOff", "Wi-Fi off")
                            color: ConnectivityService.wifiEnabled
                                ? root.luminaDesign.color.onAccentContainer
                                : root.luminaDesign.color.onSurface
                            font.pixelSize: root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: ConnectivityService.wifiAvailable
                            cursorShape: enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor
                            onClicked: ConnectivityManagerService.setWifiEnabled(
                                !ConnectivityService.wifiEnabled
                            )
                        }
                    }

                    Rectangle {
                        width: 38
                        height: 38
                        radius: root.luminaDesign.shape.full
                        color: scanMouse.containsMouse
                            ? root.luminaDesign.color.accentContainer
                            : root.luminaDesign.color.surfaceMuted
                        opacity: ConnectivityService.wifiEnabled
                            && !ConnectivityManagerService.busy
                            ? 1
                            : 0.45

                        DashboardIcon {
                            anchors.centerIn: parent
                            iconName: "view-refresh-symbolic"
                            fallbackSymbol: "↻"
                            iconColor: scanMouse.containsMouse
                                ? root.luminaDesign.color.onAccentContainer
                                : root.luminaDesign.color.onSurface
                            iconSize: 18
                            rotation: ConnectivityManagerService.busyAction
                                === "wifi-scan"
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
                            enabled: ConnectivityService.wifiEnabled
                                && !ConnectivityManagerService.busy
                            cursorShape: enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor
                            onClicked: ConnectivityManagerService.scanWifi()
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
                height: parent.height - 58 - parent.spacing * 2 - 1
                contentWidth: width
                contentHeight: networkColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 2600

                Column {
                    id: networkColumn
                    width: parent.width
                    spacing: root.luminaDesign.spacing.large

                    Column {
                        width: parent.width
                        visible: root.wiredDevices.length > 0
                            || root.wiredProfiles.length > 0
                        spacing: root.luminaDesign.spacing.small

                        Text {
                            text: I18n.tr(
                                "bar.network.section.wired",
                                "Wired network"
                            )
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize: root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        Repeater {
                            model: root.wiredProfiles

                            delegate: NetworkConnectionRow {
                                required property var modelData
                                width: networkColumn.width
                                title: modelData.name
                                description: modelData.active
                                    ? I18n.tr(
                                        "settings.connectivity.connected",
                                        "Connected"
                                    )
                                    : I18n.tr(
                                        "settings.connectivity.wired.profile",
                                        "Ethernet connection profile"
                                    )
                                iconName: "network-wired-symbolic"
                                fallbackSymbol: "↔"
                                connected: Boolean(modelData.active)
                                busy: ConnectivityManagerService.busy
                                actionLabel: modelData.active
                                    ? I18n.tr(
                                        "settings.connectivity.disconnect",
                                        "Disconnect"
                                    )
                                    : I18n.tr(
                                        "settings.connectivity.connect",
                                        "Connect"
                                    )
                                onActivated: {
                                    if (modelData.active) {
                                        ConnectivityManagerService.deactivateConnection(
                                            modelData.uuid
                                        )
                                    } else {
                                        ConnectivityManagerService.activateConnection(
                                            modelData.uuid
                                        )
                                    }
                                }
                            }
                        }

                        Repeater {
                            model: root.wiredProfiles.length === 0
                                ? root.wiredDevices
                                : []

                            delegate: NetworkConnectionRow {
                                required property var modelData
                                width: networkColumn.width
                                title: modelData.connection
                                    && modelData.connection !== "--"
                                    ? modelData.connection
                                    : modelData.device
                                description: root.localizedWiredState(modelData.state)
                                iconName: "network-wired-symbolic"
                                fallbackSymbol: "↔"
                                connected: String(modelData.state).toLowerCase()
                                    === "connected"
                                available: false
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: root.luminaDesign.spacing.small

                        Text {
                            text: I18n.tr(
                                "bar.network.section.wifi",
                                "Wi-Fi networks"
                            )
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize: root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        Repeater {
                            model: root.wifiNetworks

                            delegate: NetworkConnectionRow {
                                required property var modelData
                                width: networkColumn.width
                                title: modelData.ssid
                                description: modelData.active
                                    ? I18n.tr(
                                        "settings.connectivity.connected",
                                        "Connected"
                                    ) + " · " + modelData.signal + "%"
                                    : modelData.signal + "%"
                                        + (modelData.security
                                            && modelData.security !== "--"
                                            ? " · " + modelData.security
                                            : " · " + I18n.tr(
                                                "settings.connectivity.openNetwork",
                                                "Open network"
                                            ))
                                iconName: modelData.active
                                    ? "network-wireless-signal-excellent-symbolic"
                                    : "network-wireless-symbolic"
                                fallbackSymbol: modelData.active ? "●" : "◉"
                                connected: Boolean(modelData.active)
                                busy: ConnectivityManagerService.busy
                                actionLabel: modelData.active
                                    ? I18n.tr(
                                        "settings.connectivity.disconnect",
                                        "Disconnect"
                                    )
                                    : I18n.tr(
                                        "settings.connectivity.connect",
                                        "Connect"
                                    )
                                onActivated: root.requestWifiConnection(modelData)
                            }
                        }

                        Column {
                            width: parent.width
                            visible: root.wifiNetworks.length === 0
                            spacing: root.luminaDesign.spacing.medium

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 64
                                height: 64
                                radius: root.luminaDesign.shape.full
                                color: root.luminaDesign.color.surfaceMuted

                                DashboardIcon {
                                    anchors.centerIn: parent
                                    iconName: ConnectivityService.wifiEnabled
                                        ? "network-wireless-symbolic"
                                        : "network-wireless-disabled-symbolic"
                                    fallbackSymbol: "◉"
                                    iconColor: root.luminaDesign.color.primary
                                    iconSize: 28
                                }
                            }

                            Text {
                                width: parent.width
                                text: ConnectivityService.wifiEnabled
                                    ? I18n.tr(
                                        "bar.network.empty.noWifi",
                                        "No Wi-Fi networks found"
                                    )
                                    : I18n.tr(
                                        "bar.network.empty.wifiDisabled",
                                        "Wi-Fi is turned off"
                                    )
                                horizontalAlignment: Text.AlignHCenter
                                color: root.luminaDesign.color.onSurface
                                font.pixelSize: root.luminaDesign.typography.titleMedium
                                font.weight: Font.DemiBold
                            }

                            Text {
                                width: parent.width
                                text: ConnectivityService.wifiEnabled
                                    ? I18n.tr(
                                        "bar.network.empty.scanDescription",
                                        "Run a scan to find nearby networks"
                                    )
                                    : I18n.tr(
                                        "bar.network.empty.enableDescription",
                                        "Turn Wi-Fi on to manage wireless networks"
                                    )
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.Wrap
                                color: root.luminaDesign.color.textMuted
                                font.pixelSize: root.luminaDesign.typography.bodyMedium
                            }
                        }
                    }
                }
            }
        }

        ConnectivityViews.WifiPasswordDialog {
            id: passwordDialog
            parent: root.contentItem
            availableWidth: root.width
            availableHeight: root.height
            onSubmitted: password => {
                if (!network)
                    return
                ConnectivityManagerService.connectWifi(
                    network.ssid,
                    network.security,
                    password
                )
            }
        }
    }
}

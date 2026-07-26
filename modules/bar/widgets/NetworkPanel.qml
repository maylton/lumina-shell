pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.design
import qs.modules.control
import qs.modules.control.settings.pages.connectivity as ConnectivityViews
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
    readonly property real panelWidth: Math.min(520, width - 32)
    readonly property real panelHeight: Math.max(
        420,
        Math.min(
            620,
            availableScreenHeight
                - SurfacePlacementPolicy.barWindowHeight(
                    ConfigStore.barHeight,
                    ConfigStore.barSurfaceMode,
                    ConfigStore.barMargin
                )
                - 32
        )
    )
    readonly property var wiredProfiles:
        ConnectivityManagerService.wiredProfiles()
    readonly property var wiredDevices:
        ConnectivityManagerService.wiredDevices()
    readonly property bool showSyntheticWired:
        ConnectivityService.wiredConnected
        && wiredProfiles.length === 0
        && wiredDevices.length === 0
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

    function prepareContent() {
        ConnectivityManagerService.setActiveSection("wifi")
        ConnectivityManagerService.refreshAll()
    }

    function dismiss() {
        OverlayStore.close("network")
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

    function statusDescription() {
        if (ConnectivityManagerService.lastError)
            return ConnectivityManagerService.lastError
        if (ConnectivityManagerService.statusMessage)
            return ConnectivityManagerService.statusMessage
        if (ConnectivityService.wifiConnected)
            return ConnectivityService.wifiName
        if (ConnectivityService.wiredConnected) {
            return I18n.tr(
                "bar.network.section.wired",
                "Wired network"
            )
        }
        return I18n.tr(
            "settings.connectivity.wired.state.disconnected",
            "Disconnected"
        )
    }

    panelId: "network"
    panelOutputName: outputName
    panelVisible: panelWindow !== null
        && OverlayStore.isOpenFor("network", outputName)
    layerNamespace: "lumina-network-panel"
    screen: panelWindow ? panelWindow.screen : null
    surfaceItem: networkSurface
    surfaceRadius: networkSurface.radius
    onDismissRequested: dismiss()

    onClosed: dismiss()

    Rectangle {
        id: networkSurface

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
        clip: true

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
                        text: root.statusDescription()
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
                        width: 96
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
                id: networkFlickable

                width: parent.width
                height: parent.height - 58 - parent.spacing * 2 - 1
                contentWidth: width
                contentHeight: networkColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 2600

                Controls.ScrollBar.vertical: Controls.ScrollBar {
                    policy: networkFlickable.contentHeight > networkFlickable.height
                        ? Controls.ScrollBar.AsNeeded
                        : Controls.ScrollBar.AlwaysOff
                }

                Column {
                    id: networkColumn

                    width: networkFlickable.width
                        - (networkFlickable.contentHeight > networkFlickable.height ? 12 : 0)
                    spacing: root.luminaDesign.spacing.large

                    Column {
                        width: parent.width
                        visible: ConnectivityService.wiredConnected
                            || root.wiredDevices.length > 0
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

                        NetworkConnectionRow {
                            width: parent.width
                            visible: root.showSyntheticWired
                            title: I18n.tr(
                                "bar.network.section.wired",
                                "Wired network"
                            )
                            description: I18n.tr(
                                "settings.connectivity.connected",
                                "Connected"
                            )
                            iconName: "network-wired-symbolic"
                            fallbackSymbol: "↔"
                            connected: true
                            available: false
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

                    Item {
                        width: parent.width
                        height: root.luminaDesign.spacing.large
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

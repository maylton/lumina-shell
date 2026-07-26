pragma ComponentBehavior: Bound

import QtQuick
import qs.services.connectivity
import qs.services.i18n
import qs.stores.config
import qs.stores.shell

SystemStatusItem {
    id: root

    required property string outputName
    property var panelWindow: null
    property bool compact: false

    readonly property string textMode: String(
        ConfigStore.widgetSetting("network", "textMode", "summary")
    )
    readonly property string surfacePlacement: String(
        ConfigStore.widgetSetting(
            "network",
            "surfacePlacement",
            "near-widget"
        )
    )
    readonly property string statusLabel: {
        if (textMode === "icon")
            return ""

        if (textMode === "name") {
            return ConnectivityService.wifiConnected
                ? ConnectivityService.wifiName
                : ConnectivityService.networkSummary
        }

        if (textMode === "type") {
            return ConnectivityService.wifiConnected
                ? "Wi-Fi"
                : ConnectivityService.wiredConnected
                    ? I18n.tr("dashboard.status.wired", "Wired")
                    : I18n.tr("dashboard.status.offline", "Offline")
        }

        return ConnectivityService.networkSummary
    }
    readonly property string statusIcon:
        ConnectivityService.wifiConnected
            ? "network-wireless-signal-excellent-symbolic"
            : ConnectivityService.wiredConnected
                ? "network-wired-symbolic"
                : "network-offline-symbolic"

    individual: true
    interactive: true
    selected: networkPanel.visible
    showBackground: Boolean(
        ConfigStore.widgetSetting("network", "showBackground", true)
    )
    showLabel: !compact && textMode !== "icon"
    iconName: statusIcon
    fallbackSymbol:
        ConnectivityService.networkSummary === "Offline" ? "×" : "◉"
    label: statusLabel
    description: I18n.tr(
        "bar.network.accessible",
        "Network %1",
        [ConnectivityService.networkSummary]
    )
    alert: ConnectivityService.networkSummary === "Offline"
    onActivated: localX => togglePopup(localX)

    function mappedAnchorGeometry(localX) {
        const top = root.mapToItem(null, Number(localX), 0)
        const bottom = root.mapToItem(
            null,
            Number(localX),
            root.height
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
            "network",
            root.outputName,
            surfacePlacement,
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

    NetworkPanel {
        id: networkPanel

        outputName: root.outputName
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
            if (panelId !== "network" || outputName !== root.outputName)
                return

            OverlayStore.prepareFor(
                "network",
                root.outputName,
                placement,
                anchorX,
                anchorTop,
                anchorBottom
            )
            OverlayStore.openFor("network", root.outputName)
            Qt.callLater(function() {
                if (OverlayStore.isOpenFor("network", root.outputName))
                    networkPanel.prepareContent()
            })
        }

        function onCloseRequested(panelId, outputName) {
            if (panelId === "network" && outputName === root.outputName)
                networkPanel.dismiss()
        }
    }
}

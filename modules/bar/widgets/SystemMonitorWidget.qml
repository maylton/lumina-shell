pragma ComponentBehavior: Bound

import QtQuick
import qs.services.i18n
import qs.services.system
import qs.stores.config
import qs.stores.shell

SystemStatusItem {
    id: root

    required property string outputName
    property var panelWindow: null
    property bool compact: false

    readonly property string textMode: String(
        ConfigStore.widgetSetting(
            "system-monitor",
            "textMode",
            "percentage"
        )
    )
    readonly property string surfacePlacement: String(
        ConfigStore.widgetSetting(
            "system-monitor",
            "surfacePlacement",
            "near-widget"
        )
    )

    individual: true
    interactive: true
    selected: systemMonitorPanel.visible
    showBackground: Boolean(
        ConfigStore.widgetSetting(
            "system-monitor",
            "showBackground",
            true
        )
    )
    showLabel: !compact && textMode !== "icon"
    iconName: "utilities-system-monitor-symbolic"
    customIconSource: Qt.resolvedUrl(
        "../../../assets/icons/system-monitor-symbolic.svg"
    )
    fallbackSymbol: "▥"
    label: Math.round(SystemMonitorService.cpuUsage) + "%"
    description: I18n.tr(
        "bar.systemMonitor.accessible",
        "System monitor, processor usage %1 percent",
        [Math.round(SystemMonitorService.cpuUsage)]
    )
    onActivated: localX => togglePopup(localX)

    Component.onCompleted: SystemMonitorService.acquire()
    Component.onDestruction: SystemMonitorService.release()

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
            "system-monitor",
            root.outputName,
            surfacePlacement,
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

    SystemMonitorPanel {
        id: systemMonitorPanel

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
            if (panelId !== "system-monitor"
                || outputName !== root.outputName) {
                return
            }

            OverlayStore.prepareFor(
                "system-monitor",
                root.outputName,
                placement,
                anchorX,
                anchorTop,
                anchorBottom
            )
            OverlayStore.openFor(
                "system-monitor",
                root.outputName
            )
        }

        function onCloseRequested(panelId, outputName) {
            if (panelId === "system-monitor"
                && outputName === root.outputName) {
                systemMonitorPanel.dismiss()
            }
        }
    }
}

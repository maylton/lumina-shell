pragma ComponentBehavior: Bound

import QtQuick
import qs.services.i18n
import qs.services.power
import qs.stores.config
import qs.stores.control
import qs.stores.shell
import "ExpressiveBatteryGeometry.js" as BatteryGeometry

SystemStatusItem {
    id: root

    required property string outputName
    property bool compact: false

    readonly property bool layoutAvailable: PowerService.batteryAvailable
    readonly property string textMode: String(
        ConfigStore.widgetSetting("battery", "textMode", "percentage")
    )
    readonly property string surfacePlacement: String(
        ConfigStore.widgetSetting(
            "battery",
            "surfacePlacement",
            "near-widget"
        )
    )
    readonly property bool charging:
        BatteryGeometry.isChargingState(PowerService.batteryState)
    readonly property string statusLabel:
        textMode === "icon"
            ? ""
            : textMode === "state"
                ? PowerService.batteryState
                : PowerService.batteryPercentage + "%"

    visible: layoutAvailable
    individual: true
    interactive: true
    selected:
        ControlCenterStore.activeOutputName === outputName
        && ControlCenterStore.activePage === "dashboard"
    showBackground: Boolean(
        ConfigStore.widgetSetting("battery", "showBackground", true)
    )
    showLabel: !compact && textMode !== "icon"
    expressiveBattery: true
    batteryPercentage: PowerService.batteryPercentage
    batteryCharging: charging
    label: statusLabel
    description: I18n.tr(
        "bar.battery.accessible",
        "Battery %1 percent, %2",
        [PowerService.batteryPercentage, PowerService.batteryState]
    )
    alert: BatteryGeometry.isLowBattery(
        PowerService.batteryPercentage,
        charging
    )
    onActivated: localX => openDashboard(localX)

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

    function openDashboard(localX) {
        const anchor = mappedAnchorGeometry(localX)

        BarPanelCoordinator.requestToggle(
            "dashboard",
            root.outputName,
            surfacePlacement,
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

}

import QtQuick
import QtTest
import "../modules/bar/widgets/ExpressiveBatteryGeometry.js" as BatteryGeometry

TestCase {
    name: "ExpressiveBatteryGeometry"

    function test_percentageIsClamped() {
        compare(BatteryGeometry.clampPercentage(-8), 0)
        compare(BatteryGeometry.clampPercentage(42), 42)
        compare(BatteryGeometry.clampPercentage(125), 100)
        compare(BatteryGeometry.clampPercentage("invalid"), 0)
    }

    function test_fillTracksTheAvailableBody() {
        compare(BatteryGeometry.fillWidth(20, 0, 4), 0)
        compare(BatteryGeometry.fillWidth(20, 50, 4), 10)
        compare(BatteryGeometry.fillWidth(20, 100, 4), 20)
        compare(BatteryGeometry.fillWidth(20, 5, 4), 4)
    }

    function test_lowBatteryExcludesChargingState() {
        verify(BatteryGeometry.isLowBattery(20, false))
        verify(!BatteryGeometry.isLowBattery(21, false))
        verify(!BatteryGeometry.isLowBattery(10, true))
    }

    function test_dischargingIsNotCharging() {
        verify(BatteryGeometry.isChargingState("Charging"))
        verify(BatteryGeometry.isChargingState("pending-charge"))
        verify(BatteryGeometry.isChargingState("PendingCharge"))
        verify(!BatteryGeometry.isChargingState("Discharging"))
        verify(!BatteryGeometry.isChargingState("Fully charged"))
    }
}

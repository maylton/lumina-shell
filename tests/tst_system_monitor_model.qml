import QtQuick
import QtTest
import "../services/system/SystemMonitorModel.js"
    as SystemMonitorModel

TestCase {
    name: "SystemMonitorModel"

    function test_cpuUsageUsesCounterDeltas() {
        compare(
            SystemMonitorModel.cpuUsage(1000, 700, 1200, 780),
            60
        )
        compare(
            SystemMonitorModel.cpuUsage(1200, 780, 1200, 780),
            0
        )
    }

    function test_transferRateUsesElapsedTimeAndRejectsResets() {
        compare(
            SystemMonitorModel.transferRate(1000, 3000, 500),
            4000
        )
        compare(
            SystemMonitorModel.transferRate(3000, 1000, 500),
            0
        )
    }

    function test_historyIsBoundedAndClamped() {
        const history = SystemMonitorModel.appendHistory(
            [10, 20, 30],
            140,
            3
        )

        compare(
            JSON.stringify(history),
            JSON.stringify([20, 30, 100])
        )
    }

    function test_percentageHandlesUnavailableTotals() {
        compare(SystemMonitorModel.percentage(4, 16), 25)
        compare(SystemMonitorModel.percentage(4, 0), 0)
        compare(SystemMonitorModel.percentage(20, 16), 100)
    }
}

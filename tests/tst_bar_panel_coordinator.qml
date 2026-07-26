import QtQuick
import QtTest
import "../stores/shell"

TestCase {
    id: testCase

    name: "BarPanelCoordinator"

    SignalSpy {
        id: openSpy
        target: BarPanelCoordinator
        signalName: "openRequested"
    }

    SignalSpy {
        id: closeSpy
        target: BarPanelCoordinator
        signalName: "closeRequested"
    }

    function init() {
        BarPanelCoordinator.reset()
        openSpy.clear()
        closeSpy.clear()
    }

    function cleanup() {
        BarPanelCoordinator.reset()
    }

    function test_idleRequestOpensImmediately() {
        BarPanelCoordinator.requestToggle(
            "network",
            "DP-1",
            "near-widget",
            420,
            4,
            52
        )

        tryCompare(openSpy, "count", 1)
        compare(closeSpy.count, 0)
        compare(openSpy.signalArguments[0][0], "network")
        compare(openSpy.signalArguments[0][1], "DP-1")
        compare(openSpy.signalArguments[0][2], "near-widget")

        BarPanelCoordinator.reportOpened("network", "DP-1")
        compare(BarPanelCoordinator.activePanelId, "network")
        compare(BarPanelCoordinator.transitionPhase, "idle")
    }

    function test_samePanelRequestOnlyCloses() {
        BarPanelCoordinator.reportOpened("network", "DP-1")
        openSpy.clear()
        closeSpy.clear()

        BarPanelCoordinator.requestToggle(
            "network",
            "DP-1",
            "near-widget",
            420,
            4,
            52
        )

        compare(closeSpy.count, 1)
        compare(closeSpy.signalArguments[0][0], "network")
        compare(openSpy.count, 0)

        BarPanelCoordinator.reportClosed("network", "DP-1")
        tryCompare(BarPanelCoordinator, "transitionPhase", "idle")
        compare(openSpy.count, 0)
    }

    function test_switchWaitsForCloseConfirmation() {
        BarPanelCoordinator.reportOpened("network", "DP-1")
        openSpy.clear()
        closeSpy.clear()

        BarPanelCoordinator.requestToggle(
            "bluetooth",
            "DP-1",
            "near-widget",
            500,
            4,
            52
        )

        compare(closeSpy.count, 1)
        compare(closeSpy.signalArguments[0][0], "network")
        compare(openSpy.count, 0)

        BarPanelCoordinator.reportClosed("network", "DP-1")
        tryCompare(openSpy, "count", 1)
        compare(openSpy.signalArguments[0][0], "bluetooth")
    }

    function test_latestRapidRequestWins() {
        BarPanelCoordinator.reportOpened("network", "DP-1")
        openSpy.clear()
        closeSpy.clear()

        BarPanelCoordinator.requestToggle(
            "bluetooth",
            "DP-1",
            "near-widget",
            500,
            4,
            52
        )
        BarPanelCoordinator.requestToggle(
            "notifications",
            "DP-1",
            "near-widget",
            620,
            4,
            52
        )

        compare(closeSpy.count, 1)
        compare(openSpy.count, 0)

        BarPanelCoordinator.reportClosed("network", "DP-1")
        tryCompare(openSpy, "count", 1)
        compare(openSpy.signalArguments[0][0], "notifications")
        compare(openSpy.signalArguments[0][1], "DP-1")
    }
}

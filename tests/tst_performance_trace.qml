import QtQuick
import QtTest
import qs.stores.shell

TestCase {
    name: "PerformanceTrace"

    function init() {
        PerformanceTrace.activeProcesses = ({})
        PerformanceTrace.capacity = 96
        PerformanceTrace.slowThresholdMs = 120
        PerformanceTrace.reset()
    }

    function test_recordsBoundedEventsAndSlowDurations() {
        PerformanceTrace.capacity = 2
        PerformanceTrace.slowThresholdMs = 100

        PerformanceTrace.recordInstant("panel", "launcher", "requested")
        PerformanceTrace.record("panel", "launcher", "visible", 12)
        PerformanceTrace.record("event-loop", "qml", "delayed", 180)

        const snapshot = PerformanceTrace.snapshot()

        compare(snapshot.events.length, 2)
        compare(snapshot.events[0].phase, "visible")
        compare(snapshot.events[1].phase, "delayed")
        compare(snapshot.slowEventCount, 1)
    }

    function test_tracksConcurrentProcessPeak() {
        PerformanceTrace.processStarted("network.devices")
        PerformanceTrace.processStarted("network.profiles")

        compare(PerformanceTrace.concurrentProcessCount, 2)
        compare(PerformanceTrace.peakConcurrentProcesses, 2)

        PerformanceTrace.processFinished("network.devices")
        PerformanceTrace.processFinished("network.profiles")

        const snapshot = PerformanceTrace.snapshot()

        compare(snapshot.concurrentProcesses, 0)
        compare(snapshot.peakConcurrentProcesses, 2)
        compare(snapshot.events.length, 4)
    }
}

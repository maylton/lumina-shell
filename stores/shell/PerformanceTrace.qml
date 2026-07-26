pragma Singleton

import QtQuick

QtObject {
    id: root

    property int capacity: 96
    property int slowThresholdMs: 120
    property int sequence: 0
    property int slowEventCount: 0
    property int peakConcurrentProcesses: 0
    property var recentEvents: []
    property var activeProcesses: ({})

    readonly property int concurrentProcessCount:
        Object.keys(activeProcesses).length

    function record(category, name, phase, durationMs, details) {
        const duration = Number(durationMs)
        const event = {
            sequence: ++sequence,
            timestamp: Date.now(),
            category: String(category || "shell"),
            name: String(name || "unknown"),
            phase: String(phase || "event"),
            durationMs: isFinite(duration) && duration >= 0
                ? duration
                : -1,
            details: details || ({})
        }

        recentEvents = recentEvents
            .concat([event])
            .slice(-Math.max(1, capacity))

        if (event.durationMs >= slowThresholdMs) {
            slowEventCount += 1
            console.warn("Lumina performance:", JSON.stringify(event))
        }

        return event
    }

    function recordInstant(category, name, phase, details) {
        return record(category, name, phase, -1, details)
    }

    function processStarted(name) {
        const processName = String(name || "unknown")
        const processes = Object.assign({}, activeProcesses)

        processes[processName] = Date.now()
        activeProcesses = processes
        peakConcurrentProcesses = Math.max(
            peakConcurrentProcesses,
            concurrentProcessCount
        )

        recordInstant("process", processName, "started", {
            concurrent: concurrentProcessCount
        })
    }

    function processFinished(name) {
        const processName = String(name || "unknown")
        const startedAt = Number(activeProcesses[processName])

        if (!isFinite(startedAt))
            return

        const processes = Object.assign({}, activeProcesses)
        delete processes[processName]
        activeProcesses = processes

        record(
            "process",
            processName,
            "finished",
            Date.now() - startedAt,
            { concurrent: concurrentProcessCount }
        )
    }

    function reset() {
        sequence = 0
        slowEventCount = 0
        peakConcurrentProcesses = concurrentProcessCount
        recentEvents = []
    }

    function snapshot() {
        return {
            slowThresholdMs: slowThresholdMs,
            slowEventCount: slowEventCount,
            activeProcesses: Object.keys(activeProcesses),
            concurrentProcesses: concurrentProcessCount,
            peakConcurrentProcesses: peakConcurrentProcesses,
            events: recentEvents
        }
    }

}

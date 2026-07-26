import QtQuick
import Quickshell
import Quickshell.Io
import qs.stores.shell

Scope {
    id: root

    property double expectedTickAt: 0

    Timer {
        interval: 50
        running: true
        repeat: true
        onTriggered: {
            const now = Date.now()

            if (root.expectedTickAt > 0) {
                const lag = now - root.expectedTickAt
                if (lag >= 80) {
                    PerformanceTrace.record(
                        "event-loop",
                        "qml-main-thread",
                        "delayed",
                        lag,
                        {
                            concurrentProcesses:
                                PerformanceTrace.concurrentProcessCount
                        }
                    )
                }
            }

            root.expectedTickAt = now + interval
        }
    }

    IpcHandler {
        target: "performance"

        function reset(): void {
            PerformanceTrace.reset()
            root.expectedTickAt = 0
        }

        function status(): string {
            return JSON.stringify(PerformanceTrace.snapshot())
        }
    }
}

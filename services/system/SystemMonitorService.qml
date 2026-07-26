pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.stores.config
import "SystemMonitorModel.js" as SystemMonitorModel

Singleton {
    id: root

    readonly property string probePath:
        Quickshell.shellPath(
            "services/system/SystemMonitorProbe.py"
        )
    readonly property bool active: consumerCount > 0
    readonly property bool refreshing: probeProcess.running
    readonly property int refreshInterval: Math.max(
        1000,
        Number(ConfigStore.widgetSetting(
            "system-monitor",
            "refreshInterval",
            2000
        ))
    )
    readonly property real memoryUsage:
        SystemMonitorModel.percentage(memoryUsedBytes, memoryTotalBytes)
    readonly property real gpuMemoryUsage:
        SystemMonitorModel.percentage(
            gpuMemoryUsedBytes,
            gpuMemoryTotalBytes
        )

    property int consumerCount: 0
    property bool ready: false
    property string lastError: ""
    property bool refreshPending: false

    property string cpuModel: "Processador"
    property int cpuCores: 0
    property real cpuUsage: 0
    property var cpuHistory:
        SystemMonitorModel.initialHistory(40)
    property int sampleCount: 0
    property double previousCpuTotal: -1
    property double previousCpuIdle: -1

    property double memoryUsedBytes: 0
    property double memoryTotalBytes: 0
    property string memoryType: ""
    property int memorySpeedMhz: 0

    property bool gpuAvailable: false
    property string gpuName: "Indisponível"
    property real gpuUsage: 0
    property real gpuTemperatureC: -1
    property double gpuMemoryUsedBytes: 0
    property double gpuMemoryTotalBytes: 0
    property string gpuMemoryLabel: "VRAM"

    property var storage: []

    property string networkInterface: ""
    property real networkDownloadBytesPerSecond: 0
    property real networkUploadBytesPerSecond: 0
    property double previousNetworkRxBytes: -1
    property double previousNetworkTxBytes: -1
    property double previousTimestampMs: -1

    function acquire() {
        ++consumerCount

        if (consumerCount === 1)
            refresh()
    }

    function release() {
        consumerCount = Math.max(0, consumerCount - 1)
    }

    function refresh() {
        if (probeProcess.running) {
            refreshPending = true
            return
        }

        lastError = ""
        probeProcess.exec(["python3", probePath])
    }

    function applySnapshot(snapshot) {
        if (!snapshot || typeof snapshot !== "object")
            throw new Error("invalid system monitor snapshot")

        const cpu = snapshot.cpu || {}
        const total = Number(cpu.total || 0)
        const idle = Number(cpu.idle || 0)
        const hadCpuBaseline = previousCpuTotal >= 0

        cpuModel = String(cpu.model || "Processador")
        cpuCores = Math.max(0, Number(cpu.cores || 0))

        if (hadCpuBaseline) {
            cpuUsage = SystemMonitorModel.cpuUsage(
                previousCpuTotal,
                previousCpuIdle,
                total,
                idle
            )
            cpuHistory = SystemMonitorModel.appendHistory(
                cpuHistory,
                cpuUsage,
                40
            )
        }

        previousCpuTotal = total
        previousCpuIdle = idle
        ++sampleCount

        const memory = snapshot.memory || {}
        memoryUsedBytes = Number(memory.usedBytes || 0)
        memoryTotalBytes = Number(memory.totalBytes || 0)
        memoryType = String(memory.type || "")
        memorySpeedMhz = Math.max(
            0,
            Number(memory.speedMhz || 0)
        )

        const gpu = snapshot.gpu || {}
        gpuAvailable = Boolean(gpu.available)
        gpuName = String(gpu.name || "Indisponível")
        gpuUsage = SystemMonitorModel.clamp(
            gpu.usage,
            0,
            100
        )
        gpuTemperatureC = Number(
            gpu.temperatureC === undefined
                ? -1
                : gpu.temperatureC
        )
        gpuMemoryUsedBytes = Number(gpu.memoryUsedBytes || 0)
        gpuMemoryTotalBytes = Number(gpu.memoryTotalBytes || 0)
        gpuMemoryLabel = String(gpu.memoryLabel || "VRAM")

        const storageValues = snapshot.storage
        const normalizedStorage = []

        if (storageValues
            && typeof storageValues.length === "number") {
            for (var storageIndex = 0;
                storageIndex < storageValues.length;
                ++storageIndex) {
                normalizedStorage.push(storageValues[storageIndex])
            }
        }

        storage = normalizedStorage

        const network = snapshot.network || {}
        const timestamp = Number(snapshot.timestampMs || Date.now())
        const rxBytes = Number(network.rxBytes || 0)
        const txBytes = Number(network.txBytes || 0)

        networkInterface = String(network.interface || "")

        if (previousTimestampMs >= 0) {
            const elapsed = timestamp - previousTimestampMs
            networkDownloadBytesPerSecond =
                SystemMonitorModel.transferRate(
                    previousNetworkRxBytes,
                    rxBytes,
                    elapsed
                )
            networkUploadBytesPerSecond =
                SystemMonitorModel.transferRate(
                    previousNetworkTxBytes,
                    txBytes,
                    elapsed
                )
        }

        previousTimestampMs = timestamp
        previousNetworkRxBytes = rxBytes
        previousNetworkTxBytes = txBytes
        ready = true

        if (!hadCpuBaseline)
            warmupTimer.restart()
    }

    function statusObject() {
        return {
            active: active,
            refreshing: refreshing,
            ready: ready,
            error: lastError,
            cpu: {
                model: cpuModel,
                cores: cpuCores,
                usage: cpuUsage
            },
            memory: {
                usedBytes: memoryUsedBytes,
                totalBytes: memoryTotalBytes,
                usage: memoryUsage
            },
            gpu: {
                available: gpuAvailable,
                name: gpuName,
                usage: gpuUsage,
                temperatureC: gpuTemperatureC,
                memoryUsedBytes: gpuMemoryUsedBytes,
                memoryTotalBytes: gpuMemoryTotalBytes
            },
            network: {
                interface: networkInterface,
                downloadBytesPerSecond:
                    networkDownloadBytesPerSecond,
                uploadBytesPerSecond:
                    networkUploadBytesPerSecond
            },
            storage: storage
        }
    }

    Timer {
        interval: root.refreshInterval
        repeat: true
        running: root.active
        onTriggered: root.refresh()
    }

    Timer {
        id: warmupTimer

        interval: 220
        repeat: false
        onTriggered: {
            if (root.active)
                root.refresh()
        }
    }

    Process {
        id: probeProcess

        stdout: StdioCollector {
            id: probeOutput
        }

        stderr: StdioCollector {
            id: probeError
        }

        onExited: (exitCode, exitStatus) => {
            try {
                if (exitCode !== 0) {
                    throw new Error(
                        String(probeError.text || "").trim()
                        || "probe exited with " + exitCode
                    )
                }

                root.applySnapshot(JSON.parse(
                    String(probeOutput.text || "{}")
                ))
                root.lastError = ""
            } catch (error) {
                root.lastError = String(error)
                console.warn(
                    "Lumina system monitor:",
                    root.lastError
                )
            }

            if (root.refreshPending) {
                root.refreshPending = false
                Qt.callLater(root.refresh)
            }
        }
    }

    IpcHandler {
        target: "systemMonitor"

        function refresh(): void {
            root.refresh()
        }

        function status(): string {
            return JSON.stringify(root.statusObject())
        }
    }
}

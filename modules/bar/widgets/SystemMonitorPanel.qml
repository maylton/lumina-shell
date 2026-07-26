pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.i18n
import qs.services.system
import qs.stores.config
import qs.stores.shell
import "../../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

BarPanelWindow {
    id: root

    required property string outputName
    property var panelWindow: null

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real availableScreenHeight:
        panelWindow && panelWindow.screen
            ? panelWindow.screen.height
            : 1080
    readonly property real contentScale: 0.70
    readonly property real panelWidth: Math.min(680, width - 32)
    readonly property real panelHeight: Math.max(
        520,
        Math.min(
            680,
            availableScreenHeight
                - SurfacePlacementPolicy.barWindowHeight(
                    ConfigStore.barHeight,
                    ConfigStore.barSurfaceMode,
                    ConfigStore.barMargin
                )
                - ConfigStore.barPanelGap
                - luminaDesign.spacing.medium
        )
    )
    readonly property color secondaryMetricColor: Theme.lightMode
        ? Qt.darker(luminaDesign.color.primary, 1.12)
        : Qt.lighter(luminaDesign.color.primary, 1.18)
    readonly property string cpuSubtitle: {
        let model = String(SystemMonitorService.cpuModel || "")
            .replace(/\s+\d+-Core Processor$/i, "")
            .replace(/\s+Processor$/i, "")
        const cores = Number(SystemMonitorService.cpuCores || 0)

        if (cores <= 0)
            return model

        return model + " (" + I18n.tr(
            "bar.systemMonitor.cpu.cores",
            "%1 cores",
            [cores]
        ) + ")"
    }
    readonly property string networkTitle:
        I18n.tr("bar.systemMonitor.network", "Network")
        + (
            SystemMonitorService.networkInterface.length > 0
                ? " (" + SystemMonitorService.networkInterface + ")"
                : ""
        )

    function dismiss() {
        OverlayStore.close("system-monitor")
    }

    function formatNumber(value, decimals) {
        return Qt.locale(I18n.locale).toString(
            Number(value || 0),
            "f",
            Number(decimals || 0)
        )
    }

    function formatBytes(value, forceDecimal) {
        const bytes = Math.max(0, Number(value || 0))
        const units = ["B", "KB", "MB", "GB", "TB"]
        var unitIndex = 0
        var amount = bytes

        while (amount >= 1024 && unitIndex < units.length - 1) {
            amount /= 1024
            ++unitIndex
        }

        const decimals = forceDecimal || amount < 10 ? 1 : 0
        return formatNumber(amount, decimals) + " " + units[unitIndex]
    }

    function formatRate(value) {
        return formatNumber(
            Math.max(0, Number(value || 0)) / 1024 / 1024,
            1
        )
    }

    function usageColor(value) {
        return Number(value || 0) > 85
            ? luminaDesign.color.urgent
            : luminaDesign.color.primary
    }

    panelId: "system-monitor"
    panelOutputName: outputName
    panelVisible: panelWindow !== null
        && OverlayStore.isOpenFor("system-monitor", outputName)
    layerNamespace: "lumina-system-monitor-panel"
    screen: panelWindow ? panelWindow.screen : null
    surfaceItem: monitorSurface
    surfaceRadius: monitorSurface.radius
    onDismissRequested: dismiss()
    onClosed: dismiss()
    onPanelVisibleChanged: {
        if (panelVisible)
            SystemMonitorService.refresh()
    }

    ShellSurface {
        id: monitorSurface

        x: SurfacePlacementPolicy.horizontalX(
            OverlayStore.activePlacement,
            OverlayStore.activeAnchorX,
            width,
            root.width,
            root.luminaDesign.spacing.medium
        )
        width: root.panelWidth
        height: root.panelHeight
        radius: root.luminaDesign.shape.extraLarge
        clip: true

        Flickable {
            id: monitorFlickable

            anchors.fill: parent
            contentWidth: width
            contentHeight:
                dashboardContent.y
                + dashboardContent.height * root.contentScale
                + 24
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 2600

            Column {
                id: dashboardContent

                x: 24
                y: 18
                width:
                    (monitorFlickable.width - 48)
                    / root.contentScale
                spacing: 24
                scale: root.contentScale
                transformOrigin: Item.TopLeft

                Item {
                    width: parent.width
                    height: 58

                    Column {
                        anchors {
                            left: parent.left
                            right: refreshButton.left
                            rightMargin: root.luminaDesign.spacing.medium
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 2

                        Text {
                            width: parent.width
                            text: I18n.tr(
                                "settings.bar.catalog.system-monitor.title",
                                "System monitor"
                            )
                            color: root.luminaDesign.color.onSurface
                            elide: Text.ElideRight
                            font.pixelSize:
                                root.luminaDesign.typography.titleLarge
                            font.weight: Font.Bold
                        }

                        Text {
                            width: parent.width
                            text: I18n.tr(
                                "settings.bar.catalog.system-monitor.description",
                                "Live processor, memory, graphics, storage, and network data"
                            )
                            color: root.luminaDesign.color.textMuted
                            elide: Text.ElideRight
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                        }
                    }

                    Rectangle {
                        id: refreshButton

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        width: 38
                        height: 38
                        radius: root.luminaDesign.shape.full
                        color: refreshMouse.pressed
                            ? root.luminaDesign.color.primary
                            : refreshMouse.containsMouse
                                ? Qt.lighter(
                                    root.luminaDesign.color.accentContainer,
                                    1.08
                                )
                                : root.luminaDesign.color.accentContainer
                        scale: refreshMouse.pressed ? 0.92 : 1
                        activeFocusOnTab: true
                        border.width: activeFocus ? 2 : 0
                        border.color: root.luminaDesign.color.primary

                        Accessible.role: Accessible.Button
                        Accessible.name: I18n.tr(
                            "bar.systemMonitor.refresh",
                            "Refresh data"
                        )
                        Accessible.focusable: true
                        Accessible.focused: activeFocus
                        Accessible.onPressAction:
                            SystemMonitorService.refresh()

                        Keys.onSpacePressed: event => {
                            SystemMonitorService.refresh()
                            event.accepted = true
                        }
                        Keys.onReturnPressed: event => {
                            SystemMonitorService.refresh()
                            event.accepted = true
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration:
                                    root.luminaDesign.motion.effectsFast
                                easing.type:
                                    root.luminaDesign.motion.effectsEasing
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration:
                                    root.luminaDesign.motion.press
                                easing.type:
                                    root.luminaDesign.motion.effectsEasing
                            }
                        }

                        DashboardIcon {
                            id: refreshIcon

                            anchors.centerIn: parent
                            iconName: "view-refresh-symbolic"
                            fallbackSymbol: "↻"
                            iconColor: refreshMouse.pressed
                                ? root.luminaDesign.color.onPrimary
                                : root.luminaDesign.color.onAccentContainer
                            iconSize: 18

                            RotationAnimation on rotation {
                                running:
                                    SystemMonitorService.refreshing
                                from: 0
                                to: 360
                                duration: 850
                                loops: Animation.Infinite
                            }
                        }

                        MouseArea {
                            id: refreshMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                refreshButton.focus = false
                                SystemMonitorService.refresh()
                            }
                        }
                    }
                }

                Rectangle {
                    id: cpuCard

                    width: parent.width
                    height: 250
                    radius: 28
                    color: root.luminaDesign.color.surfaceLow

                    SystemMonitorCardHeader {
                        id: cpuHeader

                        anchors {
                            left: parent.left
                            right: cpuValue.left
                            top: parent.top
                            leftMargin: 24
                            rightMargin: 24
                            topMargin: 24
                        }
                        iconName: "cpu-symbolic"
                        customSource: Qt.resolvedUrl(
                            "../../../assets/icons/cpu-symbolic.svg"
                        )
                        fallbackSymbol: "▣"
                        title: I18n.tr(
                            "bar.systemMonitor.cpu",
                            "Processor"
                        )
                        subtitle: root.cpuSubtitle
                    }

                    Text {
                        id: cpuValue

                        anchors {
                            right: parent.right
                            top: parent.top
                            rightMargin: 24
                            topMargin: 22
                        }
                        text: Math.round(
                            SystemMonitorService.cpuUsage
                        ) + "%"
                        color: root.usageColor(
                            SystemMonitorService.cpuUsage
                        )
                        font.pixelSize: 52
                        font.weight: Font.Bold
                    }

                    SystemMonitorCpuChart {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            leftMargin: 24
                            rightMargin: 24
                            bottomMargin: 20
                        }
                        height: 100
                        history: SystemMonitorService.cpuHistory
                        lineColor: root.usageColor(
                            SystemMonitorService.cpuUsage
                        )
                        pointFillColor: cpuCard.color
                    }
                }

                Row {
                    width: parent.width
                    height: 254
                    spacing: 24

                    Rectangle {
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                        radius: 28
                        color: root.luminaDesign.color.surfaceLow

                        SystemMonitorCardHeader {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 24
                            }
                            iconName: "memory-symbolic"
                            customSource: Qt.resolvedUrl(
                                "../../../assets/icons/memory-symbolic.svg"
                            )
                            fallbackSymbol: "▥"
                            title: I18n.tr(
                                "bar.systemMonitor.memory",
                                "RAM"
                            )
                        }

                        Text {
                            anchors {
                                left: parent.left
                                top: parent.top
                                leftMargin: 24
                                topMargin: 98
                            }
                            text: root.formatBytes(
                                SystemMonitorService.memoryUsedBytes,
                                true
                            )
                            color: root.luminaDesign.color.onSurface
                            font.pixelSize: 28
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors {
                                right: parent.right
                                top: parent.top
                                rightMargin: 24
                                topMargin: 111
                            }
                            text: "/ " + root.formatBytes(
                                SystemMonitorService.memoryTotalBytes,
                                true
                            )
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize: 16
                        }

                        SystemMonitorProgressBar {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                leftMargin: 24
                                rightMargin: 24
                                topMargin: 142
                            }
                            value:
                                SystemMonitorService.memoryUsage / 100
                            fillColor:
                                SystemMonitorService.memoryUsage > 90
                                    ? root.luminaDesign.color.urgent
                                    : root.secondaryMetricColor
                        }

                        Text {
                            anchors {
                                right: parent.right
                                top: parent.top
                                rightMargin: 24
                                topMargin: 166
                            }
                            text: I18n.tr(
                                "bar.systemMonitor.used",
                                "%1% used",
                                [Math.round(
                                    SystemMonitorService.memoryUsage
                                )]
                            )
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }

                        Row {
                            anchors {
                                left: parent.left
                                bottom: parent.bottom
                                leftMargin: 24
                                bottomMargin: 20
                            }
                            spacing: 8

                            Rectangle {
                                visible:
                                    SystemMonitorService.memoryType.length > 0
                                width: memoryTypeLabel.implicitWidth + 24
                                height: 28
                                radius: 14
                                color:
                                    root.luminaDesign.color.surfaceContainer

                                Text {
                                    id: memoryTypeLabel

                                    anchors.centerIn: parent
                                    text: SystemMonitorService.memoryType
                                    color:
                                        root.luminaDesign.color.textMuted
                                    font.pixelSize: 14
                                }
                            }

                            Rectangle {
                                visible:
                                    SystemMonitorService.memorySpeedMhz > 0
                                width: memorySpeedLabel.implicitWidth + 24
                                height: 28
                                radius: 14
                                color:
                                    root.luminaDesign.color.surfaceContainer

                                Text {
                                    id: memorySpeedLabel

                                    anchors.centerIn: parent
                                    text:
                                        SystemMonitorService.memorySpeedMhz
                                        + " MHz"
                                    color:
                                        root.luminaDesign.color.textMuted
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                        radius: 28
                        color: root.luminaDesign.color.surfaceLow

                        SystemMonitorCardHeader {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 24
                            }
                            iconName: "video-display-symbolic"
                            fallbackSymbol: "▦"
                            title: I18n.tr(
                                "bar.systemMonitor.gpu",
                                "Graphics Card"
                            )
                        }

                        Column {
                            anchors {
                                left: parent.left
                                right: gpuUsageValue.left
                                top: parent.top
                                leftMargin: 24
                                rightMargin: 18
                                topMargin: 98
                            }
                            spacing: 4

                            Text {
                                width: parent.width
                                text: SystemMonitorService.gpuName
                                color:
                                    root.luminaDesign.color.textMuted
                                elide: Text.ElideRight
                                font.pixelSize: 16
                                font.weight: Font.Medium
                            }

                            Text {
                                width: parent.width
                                visible:
                                    SystemMonitorService.gpuTemperatureC
                                    >= 0
                                text: I18n.tr(
                                    "bar.systemMonitor.temperature",
                                    "Temp: %1°C",
                                    [Math.round(
                                        SystemMonitorService
                                            .gpuTemperatureC
                                    )]
                                )
                                color:
                                    root.luminaDesign.color.textMuted
                                font.pixelSize: 14
                            }
                        }

                        Text {
                            id: gpuUsageValue

                            anchors {
                                right: parent.right
                                top: parent.top
                                rightMargin: 24
                                topMargin: 98
                            }
                            text: Math.round(
                                SystemMonitorService.gpuUsage
                            ) + "%"
                            color: root.usageColor(
                                SystemMonitorService.gpuUsage
                            )
                            font.pixelSize: 40
                            font.weight: Font.Bold
                        }

                        Text {
                            anchors {
                                left: parent.left
                                bottom: gpuProgress.top
                                leftMargin: 24
                                bottomMargin: 9
                            }
                            text: SystemMonitorService.gpuMemoryLabel
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }

                        Text {
                            anchors {
                                right: parent.right
                                bottom: gpuProgress.top
                                rightMargin: 24
                                bottomMargin: 9
                            }
                            text: root.formatBytes(
                                SystemMonitorService.gpuMemoryUsedBytes,
                                true
                            ) + " / " + root.formatBytes(
                                SystemMonitorService.gpuMemoryTotalBytes,
                                true
                            )
                            color: root.luminaDesign.color.onSurface
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }

                        SystemMonitorProgressBar {
                            id: gpuProgress

                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                leftMargin: 24
                                rightMargin: 24
                                bottomMargin: 28
                            }
                            value:
                                SystemMonitorService.gpuMemoryUsage / 100
                        }
                    }
                }

                Row {
                    width: parent.width
                    height: 218
                    spacing: 24

                    Rectangle {
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                        radius: 28
                        color: root.luminaDesign.color.surfaceLow

                        SystemMonitorCardHeader {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 24
                            }
                            iconName: "drive-harddisk-symbolic"
                            fallbackSymbol: "▰"
                            title: I18n.tr(
                                "bar.systemMonitor.storage",
                                "Storage"
                            )
                        }

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                leftMargin: 24
                                rightMargin: 24
                                topMargin: 98
                            }
                            spacing: 18

                            Repeater {
                                model: SystemMonitorService.storage

                                delegate: Column {
                                    required property var modelData
                                    required property int index

                                    width: parent.width
                                    spacing: 6

                                    Row {
                                        width: parent.width

                                        Text {
                                            width: parent.width / 2
                                            text: String(
                                                modelData.label || ""
                                            )
                                            color: root.luminaDesign
                                                .color.onSurface
                                            elide: Text.ElideRight
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
                                        }

                                        Text {
                                            width: parent.width / 2
                                            text: root.formatBytes(
                                                modelData.usedBytes,
                                                false
                                            ) + " / "
                                                + root.formatBytes(
                                                    modelData.totalBytes,
                                                    false
                                                )
                                            color: root.luminaDesign
                                                .color.textMuted
                                            horizontalAlignment:
                                                Text.AlignRight
                                            elide: Text.ElideRight
                                            font.pixelSize: 14
                                        }
                                    }

                                    SystemMonitorProgressBar {
                                        width: parent.width
                                        height: 12
                                        value: Number(
                                            modelData.totalBytes || 0
                                        ) > 0
                                            ? Number(
                                                modelData.usedBytes || 0
                                            ) / Number(
                                                modelData.totalBytes
                                            )
                                            : 0
                                        fillColor: index === 0
                                            ? root.luminaDesign
                                                .color.primary
                                            : root.secondaryMetricColor
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                        radius: 28
                        color: root.luminaDesign.color.surfaceLow

                        SystemMonitorCardHeader {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 24
                            }
                            iconName:
                                SystemMonitorService.networkInterface
                                    .startsWith("wl")
                                    ? "network-wireless-symbolic"
                                    : "network-wired-symbolic"
                            fallbackSymbol: "⌁"
                            title: root.networkTitle
                        }

                        Row {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                leftMargin: 24
                                rightMargin: 24
                                bottomMargin: 24
                            }
                            height: 92
                            spacing: 16

                            Rectangle {
                                width: (parent.width - parent.spacing) / 2
                                height: parent.height
                                radius: 24
                                color:
                                    root.luminaDesign.color.surfaceContainer

                                Text {
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        leftMargin: 16
                                        topMargin: 14
                                    }
                                    text: "↓  " + I18n.tr(
                                        "bar.systemMonitor.download",
                                        "Download"
                                    )
                                    color:
                                        root.luminaDesign.color.textMuted
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                }

                                Text {
                                    anchors {
                                        left: parent.left
                                        bottom: parent.bottom
                                        leftMargin: 16
                                        bottomMargin: 14
                                    }
                                    text: root.formatRate(
                                        SystemMonitorService
                                            .networkDownloadBytesPerSecond
                                    )
                                    color:
                                        root.luminaDesign.color.primary
                                    font.pixelSize: 28
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    anchors {
                                        left: parent.left
                                        bottom: parent.bottom
                                        leftMargin: 82
                                        bottomMargin: 18
                                    }
                                    text: "MB/s"
                                    color:
                                        root.luminaDesign.color.onSurface
                                    font.pixelSize: 13
                                }
                            }

                            Rectangle {
                                width: (parent.width - parent.spacing) / 2
                                height: parent.height
                                radius: 24
                                color:
                                    root.luminaDesign.color.surfaceContainer

                                Text {
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        leftMargin: 16
                                        topMargin: 14
                                    }
                                    text: "↑  " + I18n.tr(
                                        "bar.systemMonitor.upload",
                                        "Upload"
                                    )
                                    color:
                                        root.luminaDesign.color.textMuted
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                }

                                Text {
                                    anchors {
                                        left: parent.left
                                        bottom: parent.bottom
                                        leftMargin: 16
                                        bottomMargin: 14
                                    }
                                    text: root.formatRate(
                                        SystemMonitorService
                                            .networkUploadBytesPerSecond
                                    )
                                    color:
                                        root.luminaDesign.color.primary
                                    font.pixelSize: 28
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    anchors {
                                        left: parent.left
                                        bottom: parent.bottom
                                        leftMargin: 82
                                        bottomMargin: 18
                                    }
                                    text: "MB/s"
                                    color:
                                        root.luminaDesign.color.onSurface
                                    font.pixelSize: 13
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

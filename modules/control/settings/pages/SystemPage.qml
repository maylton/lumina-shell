pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.audio
import qs.services.brightness
import qs.services.config
import qs.services.connectivity
import qs.services.niri
import qs.services.power
import qs.services.system
import qs.stores.config
import qs.stores.settings

SettingsPage {
    id: root

    title: "System"
    description: "Integrations, environment diagnostics, and recovery"

    SettingsSection {
        title: "Runtime"

        SettingsRow {
            width: parent.width
            title: "Lumina Shell"
            description: "Public beta foundation"
            controlWidth: 180

            Text {
                anchors.centerIn: parent
                text: "0.5.0-dev · "
                    + SystemDiagnosticsService.commit
                color: root.luminaDesign.color.textMuted
                elide: Text.ElideRight
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
            }
        }

        SettingsRow {
            width: parent.width
            title: "Niri"
            description: NiriService.socketPath || "NIRI_SOCKET unavailable"
            available: NiriService.available
            availabilityText: "NIRI_SOCKET unavailable"
            controlWidth: 220

            Text {
                anchors.centerIn: parent
                text: SystemDiagnosticsService.niriVersion
                color: root.luminaDesign.color.textMuted
                elide: Text.ElideRight
                font.pixelSize:
                    root.luminaDesign.typography.labelSmall
            }
        }

        SettingsRow {
            width: parent.width
            title: "Quickshell"
            description: "Validated runtime"
            controlWidth: 260

            Text {
                anchors.centerIn: parent
                text: SystemDiagnosticsService.quickshellVersion
                color: root.luminaDesign.color.textMuted
                elide: Text.ElideRight
                font.pixelSize:
                    root.luminaDesign.typography.labelSmall
            }
        }
    }

    SettingsSection {
        title: "Services"
        description: "Live availability from Lumina's typed services"

        SettingsRow {
            width: parent.width
            title: "PipeWire"
            description: AudioService.outputName
            available: AudioService.ready
            availabilityText: "PipeWire is not ready"
            controlWidth: 100

            Text {
                anchors.centerIn: parent
                text: AudioService.ready ? "Ready" : "Unavailable"
                color: AudioService.ready
                    ? root.luminaDesign.color.primary
                    : root.luminaDesign.color.urgent
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
            }
        }

        SettingsRow {
            width: parent.width
            title: "NetworkManager"
            description: ConnectivityService.networkSummary
            controlWidth: 100

            Text {
                anchors.centerIn: parent
                text: ConnectivityService.generallyConnected
                    ? "Connected"
                    : "Offline"
                color: root.luminaDesign.color.textMuted
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
            }
        }

        SettingsRow {
            width: parent.width
            title: "BlueZ"
            description: ConnectivityService.bluetoothSummary
            available: ConnectivityService.bluetoothAvailable
            availabilityText: "No Bluetooth adapter"
            controlWidth: 100

            Text {
                anchors.centerIn: parent
                text: ConnectivityService.bluetoothAvailable
                    ? "Available"
                    : "Unavailable"
                color: root.luminaDesign.color.textMuted
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
            }
        }

        SettingsRow {
            width: parent.width
            title: "UPower"
            description: PowerService.batteryState
            controlWidth: 100

            Text {
                anchors.centerIn: parent
                text: PowerService.batteryAvailable
                    ? PowerService.batteryPercentage + "%"
                    : "AC system"
                color: root.luminaDesign.color.textMuted
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
            }
        }

        SettingsRow {
            width: parent.width
            title: "Backlight"
            description: BrightnessService.available
                ? BrightnessService.deviceName
                : BrightnessService.lastError
            available: BrightnessService.available
            availabilityText: "No backlight device"
            controlWidth: 100

            Text {
                anchors.centerIn: parent
                text: BrightnessService.available
                    ? BrightnessService.percentage + "%"
                    : "Unavailable"
                color: root.luminaDesign.color.textMuted
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
            }
        }
    }

    SettingsSection {
        title: "Configuration"
        description: ConfigStore.statePath

        SettingsActionRow {
            width: parent.width
            title: "Edit config"
            description: ConfigStore.statePath
            actionLabel: "Edit"
            onActivated: ConfigFileService.openConfigFile()
        }

        SettingsActionRow {
            width: parent.width
            title: "Open config directory"
            description: ConfigFileService.configDirectory
            actionLabel: "Open"
            onActivated: ConfigFileService.openConfigDirectory()
        }

        SettingsActionRow {
            width: parent.width
            title: "Run environment diagnostics"
            description: SystemDiagnosticsService.diagnosticsStatus
            actionLabel: SystemDiagnosticsService.running
                ? "Running…"
                : "Run"
            available: !SystemDiagnosticsService.running
            onActivated: SystemDiagnosticsService.runDiagnostics()
        }

        SettingsActionRow {
            width: parent.width
            title: "Open local documentation"
            description: SystemDiagnosticsService.projectRoot
                + "/docs/user-guide.md"
            actionLabel: "Open"
            onActivated: ConfigFileService.openPath(
                SystemDiagnosticsService.projectRoot
                    + "/docs/user-guide.md"
            )
        }

        SettingsActionRow {
            width: parent.width
            title: "Restore all settings"
            description: "Two-step confirmation protects current preferences"
            actionLabel: SettingsStore.resetConfirmation
                ? "Confirm restore"
                : "Restore"
            destructive: true
            onActivated: {
                if (SettingsStore.resetConfirmation)
                    SettingsStore.confirmReset()
                else
                    SettingsStore.requestReset()
            }
        }
    }
}

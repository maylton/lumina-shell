pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.audio
import qs.services.brightness
import qs.services.config
import qs.services.connectivity
import qs.services.i18n
import qs.services.niri
import qs.services.power
import qs.services.system
import qs.stores.config
import qs.stores.settings

SettingsPage {
    id: root

    title: I18n.tr(
        "settings.category.system.label",
        "System"
    )
    description: I18n.tr(
        "settings.page.system.description",
        "Integrations, environment diagnostics, and recovery"
    )

    SettingsSection {
        title: I18n.tr(
            "settings.system.runtime.section",
            "Runtime"
        )

        SettingsRow {
            width: parent.width
            title: "Lumina Shell"
            description: I18n.tr(
                "settings.system.runtime.beta",
                "Public beta foundation"
            )
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
            description: NiriService.socketPath || I18n.tr(
                "settings.system.runtime.niriUnavailable",
                "NIRI_SOCKET unavailable"
            )
            available: NiriService.available
            availabilityText: I18n.tr(
                "settings.system.runtime.niriUnavailable",
                "NIRI_SOCKET unavailable"
            )
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
            description: I18n.tr(
                "settings.system.runtime.validated",
                "Validated runtime"
            )
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
        title: I18n.tr(
            "settings.system.services.section",
            "Services"
        )
        description: I18n.tr(
            "settings.system.services.description",
            "Live availability from Lumina's typed services"
        )

        SettingsRow {
            width: parent.width
            title: "PipeWire"
            description: AudioService.outputName
            available: AudioService.ready
            availabilityText: I18n.tr(
                "settings.system.services.pipewireNotReady",
                "PipeWire is not ready"
            )
            controlWidth: 100

            Text {
                anchors.centerIn: parent
                text: AudioService.ready
                    ? I18n.tr(
                        "settings.system.status.ready",
                        "Ready"
                    )
                    : I18n.tr(
                        "settings.system.status.unavailable",
                        "Unavailable"
                    )
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
                    ? I18n.tr(
                        "settings.system.status.connected",
                        "Connected"
                    )
                    : I18n.tr(
                        "settings.system.status.offline",
                        "Offline"
                    )
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
            availabilityText: I18n.tr(
                "settings.system.services.noBluetooth",
                "No Bluetooth adapter"
            )
            controlWidth: 100

            Text {
                anchors.centerIn: parent
                text: ConnectivityService.bluetoothAvailable
                    ? I18n.tr(
                        "settings.system.status.available",
                        "Available"
                    )
                    : I18n.tr(
                        "settings.system.status.unavailable",
                        "Unavailable"
                    )
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
                    : I18n.tr(
                        "settings.system.services.acSystem",
                        "AC system"
                    )
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
            availabilityText: I18n.tr(
                "settings.system.services.noBacklight",
                "No backlight device"
            )
            controlWidth: 100

            Text {
                anchors.centerIn: parent
                text: BrightnessService.available
                    ? BrightnessService.percentage + "%"
                    : I18n.tr(
                        "settings.system.status.unavailable",
                        "Unavailable"
                    )
                color: root.luminaDesign.color.textMuted
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
            }
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.system.configuration.section",
            "Configuration"
        )
        description: ConfigStore.statePath

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.system.configuration.edit",
                "Edit config"
            )
            description: ConfigStore.statePath
            actionLabel: I18n.tr(
                "settings.system.action.edit",
                "Edit"
            )
            onActivated: ConfigFileService.openConfigFile()
        }

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.system.configuration.openDirectory",
                "Open config directory"
            )
            description: ConfigFileService.configDirectory
            actionLabel: I18n.tr(
                "settings.common.action.open",
                "Open"
            )
            onActivated: ConfigFileService.openConfigDirectory()
        }

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.system.configuration.diagnostics",
                "Run environment diagnostics"
            )
            description: SystemDiagnosticsService.diagnosticsStatus
            actionLabel: SystemDiagnosticsService.running
                ? I18n.tr(
                    "settings.system.action.running",
                    "Running…"
                )
                : I18n.tr(
                    "settings.system.action.run",
                    "Run"
                )
            available: !SystemDiagnosticsService.running
            onActivated: SystemDiagnosticsService.runDiagnostics()
        }

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.system.configuration.documentation",
                "Open local documentation"
            )
            description: SystemDiagnosticsService.projectRoot
                + "/docs/user-guide.md"
            actionLabel: I18n.tr(
                "settings.common.action.open",
                "Open"
            )
            onActivated: ConfigFileService.openPath(
                SystemDiagnosticsService.projectRoot
                    + "/docs/user-guide.md"
            )
        }

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.system.configuration.restore",
                "Restore all settings"
            )
            description: I18n.tr(
                "settings.system.configuration.restoreDescription",
                "Two-step confirmation protects current preferences"
            )
            actionLabel: SettingsStore.resetConfirmation
                ? I18n.tr(
                    "settings.system.action.confirmRestore",
                    "Confirm restore"
                )
                : I18n.tr(
                    "settings.system.action.restore",
                    "Restore"
                )
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

pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.config
import qs.services.system

SettingsPage {
    id: root

    title: "About"
    description: "Lumina Shell project and local documentation"

    SettingsSection {
        title: "Lumina Shell"
        description: "A Niri-first desktop shell built with Quickshell and QML"

        SettingsRow {
            width: parent.width
            title: "Version"
            description: "Development build"
            controlWidth: 180

            Text {
                anchors.centerIn: parent
                text: "0.5.0-dev · "
                    + SystemDiagnosticsService.commit
                color: root.luminaDesign.color.primary
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
                font.weight: Font.DemiBold
            }
        }

        SettingsRow {
            width: parent.width
            title: "License"
            description: "GNU General Public License"
            controlWidth: 180

            Text {
                anchors.centerIn: parent
                text: "GPL-3.0-or-later"
                color: root.luminaDesign.color.textMuted
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
            }
        }

        SettingsRow {
            width: parent.width
            title: "Repository"
            description: "maylton/lumina-shell"
            controlWidth: 180

            Text {
                anchors.centerIn: parent
                text: "GitHub"
                color: root.luminaDesign.color.textMuted
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
            }
        }
    }

    SettingsSection {
        title: "Technology"

        SettingsRow {
            width: parent.width
            title: "Quickshell · QML · Niri"
            description: "Material 3 Expressive adapted for desktop productivity"
            controlWidth: 0
        }
    }

    SettingsSection {
        title: "Local resources"
        description: "No network request is made by this page"

        SettingsActionRow {
            width: parent.width
            title: "Documentation"
            description: "docs/user-guide.md"
            actionLabel: "Open"
            onActivated: ConfigFileService.openPath(
                SystemDiagnosticsService.projectRoot
                    + "/docs/user-guide.md"
            )
        }

        SettingsActionRow {
            width: parent.width
            title: "Credits and third-party references"
            description: "CREDITS.md"
            actionLabel: "Open"
            onActivated: ConfigFileService.openPath(
                SystemDiagnosticsService.projectRoot
                    + "/CREDITS.md"
            )
        }

        SettingsActionRow {
            width: parent.width
            title: "License text"
            description: "Copyright © Lumina Shell contributors"
            actionLabel: "Open"
            onActivated: ConfigFileService.openPath(
                SystemDiagnosticsService.projectRoot
                    + "/LICENSE"
            )
        }
    }
}

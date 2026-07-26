pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.config
import qs.services.i18n
import qs.services.system

SettingsPage {
    id: root

    title: I18n.tr("settings.category.about.label", "About")
    description: I18n.tr(
        "settings.page.about.description",
        "Lumina Shell project and local documentation"
    )

    SettingsSection {
        title: "Lumina Shell"
        description: I18n.tr(
            "settings.about.description",
            "A Niri-first desktop shell built with Quickshell and QML"
        )

        SettingsRow {
            width: parent.width
            title: I18n.tr("settings.about.version", "Version")
            description: I18n.tr(
                "settings.about.developmentBuild",
                "Development build"
            )
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
            title: I18n.tr("settings.about.license", "License")
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
            title: I18n.tr(
                "settings.about.repository",
                "Repository"
            )
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
        title: I18n.tr(
            "settings.about.technology",
            "Technology"
        )

        SettingsRow {
            width: parent.width
            title: "Quickshell · QML · Niri"
            description: I18n.tr(
                "settings.about.technologyDescription",
                "Material 3 Expressive adapted for desktop productivity"
            )
            controlWidth: 0
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.about.resources",
            "Local resources"
        )
        description: I18n.tr(
            "settings.about.resourcesDescription",
            "No network request is made by this page"
        )

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.about.documentation",
                "Documentation"
            )
            description: "docs/user-guide.md"
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
                "settings.about.credits",
                "Credits and third-party references"
            )
            description: "CREDITS.md"
            actionLabel: I18n.tr(
                "settings.common.action.open",
                "Open"
            )
            onActivated: ConfigFileService.openPath(
                SystemDiagnosticsService.projectRoot
                    + "/CREDITS.md"
            )
        }

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.about.licenseText",
                "License text"
            )
            description: I18n.tr(
                "settings.about.copyright",
                "Copyright © Lumina Shell contributors"
            )
            actionLabel: I18n.tr(
                "settings.common.action.open",
                "Open"
            )
            onActivated: ConfigFileService.openPath(
                SystemDiagnosticsService.projectRoot
                    + "/LICENSE"
            )
        }
    }
}

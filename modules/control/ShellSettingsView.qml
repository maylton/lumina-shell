pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control.settings
import qs.modules.control.settings.pages
import qs.stores.control

FocusScope {
    id: root

    required property string outputName
    property bool active: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool compactSidebar: width < 900
    readonly property real sidebarWidth:
        compactSidebar ? 68 : Math.min(250, Math.max(220, width * 0.22))
    readonly property var categories: [
        {
            id: "appearance",
            label: "Appearance",
            description: "Colors and wallpaper",
            iconName: "applications-graphics-symbolic",
            symbol: "✦"
        },
        {
            id: "bar",
            label: "Bar",
            description: "Layout and widgets",
            iconName: "view-more-horizontal-symbolic",
            symbol: "≡"
        },
        {
            id: "dashboard",
            label: "Dashboard",
            description: "Cards and opening",
            iconName: "view-grid-symbolic",
            symbol: "▦"
        },
        {
            id: "behavior",
            label: "Behavior",
            description: "Focus and motion",
            iconName: "preferences-system-symbolic",
            symbol: "⚙"
        },
        {
            id: "notifications",
            label: "Notifications",
            description: "Popups and history",
            iconName: "preferences-system-notifications-symbolic",
            symbol: "◐"
        },
        {
            id: "osd",
            label: "OSD",
            description: "Feedback and timing",
            iconName: "video-display-symbolic",
            symbol: "▰"
        },
        {
            id: "session",
            label: "Session",
            description: "Actions and safety",
            iconName: "system-shutdown-symbolic",
            symbol: "⏻"
        },
        {
            id: "system",
            label: "System",
            description: "Health and recovery",
            iconName: "computer-symbolic",
            symbol: "●"
        },
        {
            id: "about",
            label: "About",
            description: "Project information",
            iconName: "help-about-symbolic",
            symbol: "i"
        }
    ]

    focus: active

    Row {
        anchors.fill: parent
        spacing: root.luminaDesign.spacing.large

        SettingsSidebar {
            width: root.sidebarWidth
            height: parent.height
            compact: root.compactSidebar
            categories: root.categories
        }

        Item {
            width: parent.width - root.sidebarWidth - parent.spacing
            height: parent.height
            clip: true

            AppearancePage {
                anchors.fill: parent
                outputName: root.outputName
                visible:
                    ControlCenterStore.settingsCategory
                        === "appearance"
                enabled: visible
            }

            BarPage {
                anchors.fill: parent
                visible: ControlCenterStore.settingsCategory === "bar"
                enabled: visible
            }

            DashboardPage {
                anchors.fill: parent
                visible:
                    ControlCenterStore.settingsCategory
                        === "dashboard"
                enabled: visible
            }

            BehaviorPage {
                anchors.fill: parent
                visible:
                    ControlCenterStore.settingsCategory
                        === "behavior"
                enabled: visible
            }

            NotificationsPage {
                anchors.fill: parent
                visible:
                    ControlCenterStore.settingsCategory
                        === "notifications"
                enabled: visible
            }

            OsdPage {
                anchors.fill: parent
                visible: ControlCenterStore.settingsCategory === "osd"
                enabled: visible
            }

            SessionPage {
                anchors.fill: parent
                visible:
                    ControlCenterStore.settingsCategory === "session"
                enabled: visible
            }

            SystemPage {
                anchors.fill: parent
                visible:
                    ControlCenterStore.settingsCategory === "system"
                enabled: visible
            }

            AboutPage {
                anchors.fill: parent
                visible:
                    ControlCenterStore.settingsCategory === "about"
                enabled: visible
            }
        }
    }
}

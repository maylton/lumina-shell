pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control.settings
import qs.modules.control.settings.pages
import qs.services.i18n
import qs.stores.control

FocusScope {
    id: root

    required property string outputName
    property bool active: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool compactSidebar: width < 900
    readonly property int activeCategoryIndex: {
        for (var index = 0; index < categories.length; ++index) {
            if (categories[index].id
                === ControlCenterStore.settingsCategory)
                return index
        }

        return 0
    }
    readonly property real sidebarWidth:
        compactSidebar ? 68 : Math.min(250, Math.max(220, width * 0.22))
    readonly property var categories: [
        {
            id: "appearance",
            label: I18n.tr(
                "settings.category.appearance.label",
                "Appearance"
            ),
            description: I18n.tr(
                "settings.category.appearance.description",
                "Colors and wallpaper"
            ),
            iconName: "applications-graphics-symbolic",
            symbol: "✦"
        },
        {
            id: "bar",
            label: I18n.tr(
                "settings.category.bar.label",
                "Bar"
            ),
            description: I18n.tr(
                "settings.category.bar.description",
                "Layout and widgets"
            ),
            iconName: "view-more-horizontal-symbolic",
            symbol: "≡"
        },
        {
            id: "dashboard",
            label: I18n.tr(
                "settings.category.dashboard.label",
                "Dashboard"
            ),
            description: I18n.tr(
                "settings.category.dashboard.description",
                "Cards and opening"
            ),
            iconName: "view-grid-symbolic",
            symbol: "▦"
        },
        {
            id: "weather",
            label: I18n.tr(
                "settings.category.weather.label",
                "Weather"
            ),
            description: I18n.tr(
                "settings.category.weather.description",
                "Location and forecast"
            ),
            iconName: "weather-clear-symbolic",
            symbol: "☀"
        },
        {
            id: "connectivity",
            label: I18n.tr(
                "settings.category.connectivity.label",
                "Connectivity"
            ),
            description: I18n.tr(
                "settings.category.connectivity.description",
                "Wi-Fi, Ethernet, and Bluetooth"
            ),
            iconName: "network-wireless-symbolic",
            symbol: "⌁"
        },
        {
            id: "behavior",
            label: I18n.tr(
                "settings.category.behavior.label",
                "Behavior"
            ),
            description: I18n.tr(
                "settings.category.behavior.description",
                "Focus and motion"
            ),
            iconName: "preferences-system-symbolic",
            symbol: "⚙"
        },
        {
            id: "notifications",
            label: I18n.tr(
                "settings.category.notifications.label",
                "Notifications"
            ),
            description: I18n.tr(
                "settings.category.notifications.description",
                "Popups and history"
            ),
            iconName: "preferences-system-notifications-symbolic",
            symbol: "◐"
        },
        {
            id: "osd",
            label: I18n.tr(
                "settings.category.osd.label",
                "OSD"
            ),
            description: I18n.tr(
                "settings.category.osd.description",
                "Feedback and timing"
            ),
            iconName: "video-display-symbolic",
            symbol: "▰"
        },
        {
            id: "session",
            label: I18n.tr(
                "settings.category.session.label",
                "Session"
            ),
            description: I18n.tr(
                "settings.category.session.description",
                "Actions and safety"
            ),
            iconName: "system-shutdown-symbolic",
            symbol: "⏻"
        },
        {
            id: "system",
            label: I18n.tr(
                "settings.category.system.label",
                "System"
            ),
            description: I18n.tr(
                "settings.category.system.description",
                "Health and recovery"
            ),
            iconName: "computer-symbolic",
            symbol: "●"
        },
        {
            id: "about",
            label: I18n.tr(
                "settings.category.about.label",
                "About"
            ),
            description: I18n.tr(
                "settings.category.about.description",
                "Project information"
            ),
            iconName: "help-about-symbolic",
            symbol: "i"
        }
    ]

    focus: active

    Row {
        anchors.fill: parent
        spacing: root.luminaDesign.spacing.controlCardGap

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

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "appearance"
                categoryIndex: 0
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory
                        === "appearance"

                AppearancePage {
                    anchors.fill: parent
                    outputName: root.outputName
                }
            }

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "bar"
                categoryIndex: 1
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory === "bar"

                BarPage {
                    anchors.fill: parent
                }
            }

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "dashboard"
                categoryIndex: 2
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory
                        === "dashboard"

                DashboardPage {
                    anchors.fill: parent
                }
            }

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "weather"
                categoryIndex: 3
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory === "weather"

                WeatherPage {
                    anchors.fill: parent
                }
            }

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "connectivity"
                categoryIndex: 4
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory
                        === "connectivity"

                ConnectivityPage {
                    anchors.fill: parent
                }
            }

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "behavior"
                categoryIndex: 5
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory
                        === "behavior"

                BehaviorPage {
                    anchors.fill: parent
                }
            }

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "notifications"
                categoryIndex: 6
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory
                        === "notifications"

                NotificationsPage {
                    anchors.fill: parent
                }
            }

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "osd"
                categoryIndex: 7
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory === "osd"

                OsdPage {
                    anchors.fill: parent
                }
            }

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "session"
                categoryIndex: 8
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory === "session"

                SessionPage {
                    anchors.fill: parent
                }
            }

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "system"
                categoryIndex: 9
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory === "system"

                SystemPage {
                    anchors.fill: parent
                }
            }

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "about"
                categoryIndex: 10
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory === "about"

                AboutPage {
                    anchors.fill: parent
                }
            }
        }
    }
}

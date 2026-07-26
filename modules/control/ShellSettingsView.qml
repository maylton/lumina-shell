pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control.settings
import qs.modules.control.settings.pages
import qs.services.i18n
import qs.stores.control
import qs.stores.shell
import "../dock/DockStrings.js" as DockStrings

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
    property double categoryTransitionRequestedAt: 0
    property string categoryTransitionTarget: ""
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
            id: "dock",
            label: "Dock",
            description: DockStrings.text(
                I18n.locale,
                "categoryDescription"
            ),
            iconName: "user-desktop-symbolic",
            symbol: "▱"
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

    function activePageFrame() {
        for (var index = 0; index < pagesHost.children.length; ++index) {
            const frame = pagesHost.children[index]

            if (frame
                && String(frame.categoryId || "")
                    === ControlCenterStore.settingsCategory) {
                return frame
            }
        }

        return null
    }

    function controlsWithMethod(item, methodName, result) {
        const controls = result || []

        if (!item)
            return controls

        if (typeof item[methodName] === "function")
            controls.push(item)

        const descendants = item.children || []
        for (var index = 0; index < descendants.length; ++index)
            controlsWithMethod(descendants[index], methodName, controls)

        return controls
    }

    function activeControls(methodName) {
        return controlsWithMethod(activePageFrame(), methodName, [])
    }

    function performanceStatus() {
        const combos = activeControls("toggleMenu")
        const sliders = activeControls("benchmarkValue")
        const popups = activeControls("togglePopup")

        return {
            category: ControlCenterStore.settingsCategory,
            dropdowns: combos.map(function(control) {
                return {
                    title: String(control.title || ""),
                    open: Boolean(control.menuOpen),
                    optionCount: Number(
                        control.options ? control.options.length : 0
                    )
                }
            }),
            sliders: sliders.map(function(control) {
                const range = Number(control.to) - Number(control.from)
                return {
                    title: String(control.title || ""),
                    available: Boolean(control.available),
                    value: Number(control.value),
                    from: Number(control.from),
                    to: Number(control.to),
                    normalized: range > 0
                        ? (Number(control.value) - Number(control.from))
                            / range
                        : 0
                }
            }),
            popups: popups.length
        }
    }

    function togglePerformanceDropdown(index) {
        const controls = activeControls("toggleMenu")
        const requested = Number(index)

        if (requested >= 0 && requested < controls.length)
            controls[requested].toggleMenu()
    }

    function setPerformanceSlider(index, normalized) {
        const controls = activeControls("benchmarkValue")
        const requested = Number(index)

        if (requested >= 0 && requested < controls.length)
            controls[requested].benchmarkValue(Number(normalized))
    }

    function togglePerformancePopup(index) {
        const controls = activeControls("togglePopup")
        const requested = Number(index)

        if (requested >= 0 && requested < controls.length)
            controls[requested].togglePopup()
    }

    function togglePerformanceDialog(widgetId) {
        const controls = activeControls(
            "togglePerformanceWidgetDialog"
        )

        if (controls.length > 0) {
            controls[0].togglePerformanceWidgetDialog(
                String(widgetId || "launcher")
            )
        }
    }

    focus: active

    Connections {
        target: ControlCenterStore

        function onSettingsCategoryChanged() {
            if (!root.active)
                return

            root.categoryTransitionRequestedAt = Date.now()
            root.categoryTransitionTarget =
                ControlCenterStore.settingsCategory
            PerformanceTrace.recordInstant(
                "transition",
                "settings-category",
                "requested",
                { target: root.categoryTransitionTarget }
            )
            categoryTransitionTimer.restart()
        }
    }

    Timer {
        id: categoryTransitionTimer

        interval: Math.max(
            root.luminaDesign.motion.pageTransition,
            root.luminaDesign.motion.effectsDefault
        )
        repeat: false
        onTriggered: {
            if (!root.active
                || root.categoryTransitionTarget
                    !== ControlCenterStore.settingsCategory) {
                return
            }

            PerformanceTrace.record(
                "transition",
                "settings-category",
                "settled",
                Math.max(
                    0,
                    Date.now()
                        - root.categoryTransitionRequestedAt
                        - interval
                ),
                {
                    target: root.categoryTransitionTarget,
                    expectedDurationMs: interval,
                    totalDurationMs:
                        Date.now()
                            - root.categoryTransitionRequestedAt
                }
            )
        }
    }

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
            id: pagesHost

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
                categoryId: "dock"
                categoryIndex: 3
                activeIndex: root.activeCategoryIndex
                pageActive:
                    ControlCenterStore.settingsCategory === "dock"

                DockPage {
                    anchors.fill: parent
                }
            }

            SettingsPageFrame {
                anchors.fill: parent
                categoryId: "weather"
                categoryIndex: 4
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
                categoryIndex: 5
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
                categoryIndex: 6
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
                categoryIndex: 7
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
                categoryIndex: 8
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
                categoryIndex: 9
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
                categoryIndex: 10
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
                categoryIndex: 11
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

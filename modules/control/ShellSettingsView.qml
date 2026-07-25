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
    readonly property var categories: [
        {
            id: "appearance",
            label: "Appearance",
            description: "Color and visual language",
            iconName: "applications-graphics-symbolic",
            symbol: "✦"
        },
        {
            id: "bar",
            label: "Bar",
            description: "Status density",
            iconName: "view-more-horizontal-symbolic",
            symbol: "≡"
        },
        {
            id: "wallpaper",
            label: "Wallpaper",
            description: "Sources and palette",
            iconName: "preferences-desktop-wallpaper-symbolic",
            symbol: "▧"
        },
        {
            id: "notifications",
            label: "Notifications",
            description: "Interruptions and DND",
            iconName: "preferences-system-notifications-symbolic",
            symbol: "◐"
        },
        {
            id: "osd",
            label: "OSD",
            description: "Feedback and duration",
            iconName: "video-display-symbolic",
            symbol: "▰"
        },
        {
            id: "system",
            label: "System",
            description: "Health and recovery",
            iconName: "computer-symbolic",
            symbol: "●"
        }
    ]

    focus: active

    Row {
        anchors.fill: parent
        spacing: root.luminaDesign.spacing.large

        DashboardCard {
            width: 252
            height: parent.height
            accessibleName: "Settings categories"

            Column {
                anchors {
                    fill: parent
                    margins: root.luminaDesign.spacing.medium
                }

                spacing: root.luminaDesign.spacing.small

                Repeater {
                    model: root.categories

                    delegate: Rectangle {
                        id: categoryButton

                        required property var modelData
                        readonly property bool selected:
                            ControlCenterStore.settingsCategory
                                === modelData.id

                        width: parent.width
                        height: 70
                        radius: selected
                            ? root.luminaDesign.shape.extraLarge
                            : root.luminaDesign.shape.large
                        color: selected
                            ? root.luminaDesign.color.accentContainer
                            : categoryMouse.containsMouse || activeFocus
                                ? Qt.lighter(
                                    root.luminaDesign.color.surfaceMuted,
                                    1.1
                                )
                                : "transparent"
                        activeFocusOnTab: true
                        border.width: activeFocus ? 2 : 0
                        border.color: root.luminaDesign.color.primary

                        function activate() {
                            ControlCenterStore.setSettingsCategory(
                                modelData.id
                            )
                        }

                        Accessible.role: Accessible.PageTab
                        Accessible.name: modelData.label
                        Accessible.description: modelData.description
                        Accessible.selected: selected
                        Accessible.focusable: true
                        Accessible.focused: activeFocus
                        Accessible.onPressAction: activate()

                        Keys.onSpacePressed: event => {
                            activate()
                            event.accepted = true
                        }

                        Keys.onReturnPressed: event => {
                            activate()
                            event.accepted = true
                        }

                        Behavior on radius {
                            NumberAnimation {
                                duration: root.luminaDesign.motion.medium
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: root.luminaDesign.motion.fast
                            }
                        }

                        Row {
                            anchors {
                                fill: parent
                                margins:
                                    root.luminaDesign.spacing.medium
                            }

                            spacing: root.luminaDesign.spacing.medium

                            DashboardIcon {
                                anchors.verticalCenter:
                                    parent.verticalCenter
                                width: 30
                                height: 30
                                iconName:
                                    categoryButton.modelData.iconName
                                fallbackSymbol:
                                    categoryButton.modelData.symbol
                                iconColor: categoryButton.selected
                                    ? root.luminaDesign.color.onAccentContainer
                                    : root.luminaDesign.color.primary
                                iconSize: 19
                            }

                            Column {
                                anchors.verticalCenter:
                                    parent.verticalCenter
                                width: parent.width - 42
                                spacing: 2

                                Text {
                                    width: parent.width
                                    text:
                                        categoryButton.modelData.label
                                    color: categoryButton.selected
                                        ? root.luminaDesign.color.onAccentContainer
                                        : root.luminaDesign.color.onSurface
                                    elide: Text.ElideRight
                                    font.pixelSize:
                                        root.luminaDesign.typography.bodyMedium
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    width: parent.width
                                    text:
                                        categoryButton.modelData.description
                                    color: categoryButton.selected
                                        ? root.luminaDesign.color.onAccentContainer
                                        : root.luminaDesign.color.textMuted
                                    opacity: 0.78
                                    elide: Text.ElideRight
                                    font.pixelSize:
                                        root.luminaDesign.typography.labelSmall
                                }
                            }
                        }

                        MouseArea {
                            id: categoryMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                categoryButton.forceActiveFocus(
                                    Qt.MouseFocusReason
                                )
                                categoryButton.activate()
                            }
                        }
                    }
                }
            }
        }

        Item {
            width: parent.width - 252 - parent.spacing
            height: parent.height

            AppearancePage {
                anchors.fill: parent
                outputName: root.outputName
                visible:
                    ControlCenterStore.settingsCategory
                        === "appearance"
                enabled: visible
            }

            BarSettings {
                anchors.fill: parent
                visible:
                    ControlCenterStore.settingsCategory === "bar"
                enabled: visible
            }

            WallpaperSettings {
                anchors.fill: parent
                visible:
                    ControlCenterStore.settingsCategory
                        === "wallpaper"
                enabled: visible
            }

            NotificationSettings {
                anchors.fill: parent
                visible:
                    ControlCenterStore.settingsCategory
                        === "notifications"
                enabled: visible
            }

            OsdSettings {
                anchors.fill: parent
                visible:
                    ControlCenterStore.settingsCategory === "osd"
                enabled: visible
            }

            SystemSettings {
                anchors.fill: parent
                visible:
                    ControlCenterStore.settingsCategory === "system"
                enabled: visible
            }
        }
    }
}

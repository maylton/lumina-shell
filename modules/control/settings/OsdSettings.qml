pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.stores.config

Flickable {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var durations: [
        { value: 1200, label: "Short" },
        { value: 1800, label: "Normal" },
        { value: 3000, label: "Long" }
    ]

    clip: true
    contentWidth: width
    contentHeight: contentColumn.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: contentColumn

        width: root.width
        spacing: root.luminaDesign.spacing.large

        Column {
            width: parent.width
            spacing: 3

            Text {
                text: "On-screen display"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleLarge
                font.weight: Font.Bold
            }

            Text {
                text: "Volume and brightness feedback"
                color: root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.labelMedium
            }
        }

        DashboardCard {
            width: parent.width
            height: 116
            accessibleName: "On-screen display visibility"

            QuickToggle {
                anchors {
                    fill: parent
                    margins: root.luminaDesign.spacing.extraLarge
                }

                title: "Show OSD"
                detail: ConfigStore.osdEnabled
                    ? "Volume and brightness feedback enabled"
                    : "Feedback hidden"
                iconName: "video-display-symbolic"
                symbol: "▰"
                checked: ConfigStore.osdEnabled
                onToggled: ConfigStore.setOsdEnabled(
                    !ConfigStore.osdEnabled
                )
            }
        }

        DashboardCard {
            width: parent.width
            height: 122
            accessibleName: "On-screen display duration"

            Column {
                anchors {
                    fill: parent
                    margins: root.luminaDesign.spacing.extraLarge
                }

                spacing: root.luminaDesign.spacing.medium

                Text {
                    text: "Duration"
                    color: root.luminaDesign.color.onSurface
                    font.pixelSize: root.luminaDesign.typography.bodyMedium
                    font.weight: Font.DemiBold
                }

                Row {
                    width: parent.width
                    spacing: root.luminaDesign.spacing.small

                    Repeater {
                        model: root.durations

                        delegate: Rectangle {
                            id: durationButton

                            required property var modelData
                            readonly property bool selected:
                                ConfigStore.osdDuration
                                    === modelData.value

                            width: (
                                parent.width - parent.spacing * 2
                            ) / 3
                            height: 42
                            radius: root.luminaDesign.shape.full
                            color: selected
                                ? root.luminaDesign.color.accentContainer
                                : root.luminaDesign.color.surfaceMuted
                            activeFocusOnTab: true
                            border.width: activeFocus ? 2 : 0
                            border.color: root.luminaDesign.color.primary

                            function activate() {
                                ConfigStore.setOsdDuration(
                                    modelData.value
                                )
                            }

                            Accessible.role: Accessible.RadioButton
                            Accessible.name: modelData.label
                                + " OSD duration"
                            Accessible.checked: selected
                            Accessible.onPressAction: activate()

                            Keys.onSpacePressed: event => {
                                activate()
                                event.accepted = true
                            }

                            Keys.onReturnPressed: event => {
                                activate()
                                event.accepted = true
                            }

                            Text {
                                anchors.centerIn: parent
                                text: durationButton.modelData.label
                                color: durationButton.selected
                                    ? root.luminaDesign.color.onAccentContainer
                                    : root.luminaDesign.color.onSurface
                                font.pixelSize:
                                    root.luminaDesign.typography.labelMedium
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    durationButton.forceActiveFocus(
                                        Qt.MouseFocusReason
                                    )
                                    durationButton.activate()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

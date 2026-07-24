pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.stores.time

PopupWindow {
    id: root

    property var anchorItem: null

    signal dismissed

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real dayCellSize: Math.max(
        luminaDesign.size.dayCell,
        (implicitWidth - luminaDesign.spacing.large * 2
            - luminaDesign.spacing.extraSmall * 6) / 7
    )

    visible: CalendarStore.open && anchorItem !== null
    implicitWidth: luminaDesign.size.calendarWidth
    implicitHeight: calendarContent.implicitHeight + luminaDesign.spacing.large * 2
    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: luminaDesign.spacing.small
    anchor.adjustment: PopupAdjustment.All

    onClosed: {
        CalendarStore.close()
        dismissed()
    }

    Rectangle {
        id: calendarSurface

        anchors.fill: parent
        radius: root.luminaDesign.shape.large
        color: root.luminaDesign.color.surfaceContainer
        border.width: 1
        border.color: root.luminaDesign.color.outline
        opacity: root.visible ? 1.0 : 0.0
        scale: root.visible ? 1.0 : 0.96

        Behavior on opacity {
            NumberAnimation {
                duration: root.luminaDesign.motion.medium
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.luminaDesign.motion.medium
                easing.type: Easing.OutBack
            }
        }

        Column {
            id: calendarContent

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: root.luminaDesign.spacing.large
            }

            spacing: root.luminaDesign.spacing.medium

            Row {
                width: parent.width
                height: root.luminaDesign.size.chipHeight
                spacing: root.luminaDesign.spacing.small

                CalendarActionButton {
                    width: root.luminaDesign.size.chipHeight
                    height: root.luminaDesign.size.chipHeight
                    horizontalPadding: 0
                    label: "‹"
                    onClicked: CalendarStore.showPreviousMonth()
                }

                Item {
                    width: parent.width
                        - root.luminaDesign.size.chipHeight * 2
                        - parent.spacing * 2
                    height: parent.height

                    Text {
                        anchors.centerIn: parent
                        text: CalendarStore.monthTitle
                        color: root.luminaDesign.color.onSurface
                        font.pixelSize: root.luminaDesign.typography.titleMedium
                        font.weight: Font.DemiBold
                    }
                }

                CalendarActionButton {
                    width: root.luminaDesign.size.chipHeight
                    height: root.luminaDesign.size.chipHeight
                    horizontalPadding: 0
                    label: "›"
                    onClicked: CalendarStore.showNextMonth()
                }
            }

            Grid {
                width: parent.width
                height: root.luminaDesign.size.chipHeight
                columns: 7
                columnSpacing: root.luminaDesign.spacing.extraSmall

                Repeater {
                    model: CalendarStore.weekdayLabels

                    delegate: Item {
                        required property var modelData

                        width: root.dayCellSize
                        height: root.luminaDesign.size.chipHeight

                        Text {
                            anchors.centerIn: parent
                            text: String(parent.modelData).toLocaleUpperCase()
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize: root.luminaDesign.typography.labelSmall
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            Grid {
                width: parent.width
                height: root.dayCellSize * 6
                    + root.luminaDesign.spacing.extraSmall * 5
                columns: 7
                columnSpacing: root.luminaDesign.spacing.extraSmall
                rowSpacing: root.luminaDesign.spacing.extraSmall

                Repeater {
                    model: CalendarStore.monthCells

                    delegate: Rectangle {
                        id: dayCell

                        required property var modelData

                        width: root.dayCellSize
                        height: root.dayCellSize
                        radius: root.luminaDesign.shape.full
                        scale: dayMouse.pressed
                            ? 0.88
                            : dayMouse.containsMouse && modelData.enabled
                                ? 1.04
                                : 1.0
                        color: modelData.isSelected
                            ? root.luminaDesign.color.accentContainer
                            : dayMouse.pressed && modelData.enabled
                                ? Qt.darker(root.luminaDesign.color.surfaceMuted, 1.12)
                                : dayMouse.containsMouse && modelData.enabled
                                    ? root.luminaDesign.color.surfaceMuted
                                    : "transparent"
                        border.width: modelData.isToday ? 2 : 0
                        border.color: root.luminaDesign.color.primary

                        Behavior on color {
                            ColorAnimation {
                                duration: root.luminaDesign.motion.fast
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: root.luminaDesign.motion.fast
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: dayCell.modelData.enabled
                                ? String(dayCell.modelData.day)
                                : ""
                            color: dayCell.modelData.isSelected
                                ? root.luminaDesign.color.onAccentContainer
                                : dayCell.modelData.isToday
                                    ? root.luminaDesign.color.primary
                                    : root.luminaDesign.color.onSurface
                            font.pixelSize: root.luminaDesign.typography.bodyMedium
                            font.weight: dayCell.modelData.isToday
                                || dayCell.modelData.isSelected
                                ? Font.DemiBold
                                : Font.Medium
                        }

                        MouseArea {
                            id: dayMouse

                            anchors.fill: parent
                            enabled: dayCell.modelData.enabled
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: CalendarStore.selectDay(dayCell.modelData.day)
                        }
                    }
                }
            }

            CalendarActionButton {
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("Today")
                selected: CalendarStore.showingCurrentMonth
                onClicked: CalendarStore.goToToday()
            }
        }
    }
}

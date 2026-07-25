pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.calendar
import qs.stores.time

DashboardCard {
    id: root

    readonly property bool showTodayAction: height >= 320
    readonly property real daySize: Math.max(
        22,
        Math.min(
            38,
            (calendarGrid.width - 24) / 7,
            (calendarGrid.height - 20) / 6
        )
    )
    readonly property real dayColumnSpacing: Math.max(
        4,
        (calendarGrid.width - daySize * 7) / 6
    )
    readonly property real dayRowSpacing: Math.max(
        4,
        (calendarGrid.height - daySize * 6) / 5
    )

    accessibleName: "Calendar"

    Item {
        id: calendarBody

        anchors {
            fill: parent
            margins: root.luminaDesign.spacing.controlContentInset
        }

        Row {
            id: monthHeader

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            height: 34
            spacing: root.luminaDesign.spacing.small

            CalendarActionButton {
                width: 34
                height: 34
                horizontalPadding: 0
                expressiveMorph: true
                label: "‹"
                onClicked: CalendarStore.showPreviousMonth()
            }

            Text {
                width: parent.width - 76
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                text: CalendarStore.monthTitle
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleMedium
                font.weight: Font.Bold
            }

            CalendarActionButton {
                width: 34
                height: 34
                horizontalPadding: 0
                expressiveMorph: true
                label: "›"
                onClicked: CalendarStore.showNextMonth()
            }
        }

        Grid {
            id: weekdayGrid

            anchors {
                left: parent.left
                right: parent.right
                top: monthHeader.bottom
                topMargin: root.luminaDesign.spacing.medium
            }

            height: 24
            columns: 7
            columnSpacing: root.dayColumnSpacing

            Repeater {
                model: CalendarStore.weekdayLabels

                delegate: Item {
                    required property var modelData

                    width: root.daySize
                    height: weekdayGrid.height

                    Text {
                        anchors.centerIn: parent
                        text: String(parent.modelData)
                            .slice(0, 2)
                            .toLocaleUpperCase()
                        color: root.luminaDesign.color.textMuted
                        font.pixelSize:
                            root.luminaDesign.typography.labelSmall
                        font.weight: Font.Bold
                    }
                }
            }
        }

        CalendarActionButton {
            id: todayButton

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }

            visible: root.showTodayAction
            label: "Today"
            selected: CalendarStore.showingCurrentMonth
            onClicked: CalendarStore.goToToday()
        }

        Item {
            id: gridRegion

            anchors {
                left: parent.left
                right: parent.right
                top: weekdayGrid.bottom
                bottom: root.showTodayAction
                    ? todayButton.top
                    : parent.bottom
                topMargin: root.luminaDesign.spacing.small
                bottomMargin: root.showTodayAction
                    ? root.luminaDesign.spacing.small
                    : 0
            }

            Grid {
                id: calendarGrid

                anchors.fill: parent
                columns: 7
                columnSpacing: root.dayColumnSpacing
                rowSpacing: root.dayRowSpacing

                Repeater {
                    model: CalendarStore.monthCells

                    delegate: Rectangle {
                        id: dayCell

                        required property var modelData

                        width: root.daySize
                        height: root.daySize
                        radius: modelData.isSelected
                            || dayMouse.pressed
                            ? Math.min(
                                width / 2,
                                root.luminaDesign.shape.controlIconActivated
                                    * width / 44
                            )
                            : width / 2
                        activeFocusOnTab: modelData.enabled
                        color: modelData.isSelected
                            ? root.luminaDesign.color.accentContainer
                            : dayMouse.containsMouse && modelData.enabled
                                ? root.luminaDesign.color.surfaceMuted
                                : "transparent"
                        border.width:
                            activeFocus || modelData.isToday ? 2 : 0
                        border.color: root.luminaDesign.color.primary

                        Behavior on radius {
                            NumberAnimation {
                                duration:
                                    root.luminaDesign.motion.spatialFast
                                easing.type:
                                    root.luminaDesign.motion.spatialEasing
                                easing.overshoot:
                                    root.luminaDesign.motion.spatialOvershoot
                            }
                        }

                        Accessible.role: Accessible.Button
                        Accessible.name: modelData.enabled
                            ? "Day " + modelData.day
                            : ""
                        Accessible.selected: modelData.isSelected
                        Accessible.focusable: modelData.enabled
                        Accessible.focused: activeFocus
                        Accessible.onPressAction:
                            CalendarStore.selectDay(modelData.day)

                        Keys.onSpacePressed: event => {
                            CalendarStore.selectDay(modelData.day)
                            event.accepted = true
                        }

                        Keys.onReturnPressed: event => {
                            CalendarStore.selectDay(modelData.day)
                            event.accepted = true
                        }

                        Text {
                            anchors.centerIn: parent
                            text: dayCell.modelData.enabled
                                ? dayCell.modelData.day
                                : ""
                            color: dayCell.modelData.isSelected
                                ? root.luminaDesign.color.onAccentContainer
                                : dayCell.modelData.isToday
                                    ? root.luminaDesign.color.primary
                                    : root.luminaDesign.color.onSurface
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: dayCell.modelData.isToday
                                || dayCell.modelData.isSelected
                                ? Font.Bold
                                : Font.Medium
                        }

                        MouseArea {
                            id: dayMouse

                            anchors.fill: parent
                            enabled: dayCell.modelData.enabled
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                dayCell.forceActiveFocus(
                                    Qt.MouseFocusReason
                                )
                                CalendarStore.selectDay(
                                    dayCell.modelData.day
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

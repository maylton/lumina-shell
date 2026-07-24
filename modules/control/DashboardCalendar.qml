pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.calendar
import qs.stores.time

DashboardCard {
    id: root

    readonly property real daySize: Math.max(
        22,
        Math.min(
            38,
            (
                width
                    - luminaDesign.spacing.large * 2
                    - luminaDesign.spacing.extraSmall * 6
            ) / 7,
            (height - 138) / 6
        )
    )

    accessibleName: "Calendar"

    Column {
        anchors {
            fill: parent
            margins: root.luminaDesign.spacing.large
        }

        spacing: root.luminaDesign.spacing.small

        Row {
            width: parent.width
            height: 34
            spacing: root.luminaDesign.spacing.small

            CalendarActionButton {
                width: 34
                height: 34
                horizontalPadding: 0
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
                label: "›"
                onClicked: CalendarStore.showNextMonth()
            }
        }

        Grid {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 24
            columns: 7
            columnSpacing: root.luminaDesign.spacing.extraSmall

            Repeater {
                model: CalendarStore.weekdayLabels

                delegate: Item {
                    required property var modelData

                    width: root.daySize
                    height: 24

                    Text {
                        anchors.centerIn: parent
                        text: String(parent.modelData)
                            .slice(0, 2)
                            .toLocaleUpperCase()
                        color: root.luminaDesign.color.textMuted
                        font.pixelSize:
                            root.luminaDesign.typography.labelSmall
                        font.weight: Font.DemiBold
                    }
                }
            }
        }

        Grid {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: root.daySize * 6
                + root.luminaDesign.spacing.extraSmall * 5
            columns: 7
            columnSpacing: root.luminaDesign.spacing.extraSmall
            rowSpacing: root.luminaDesign.spacing.extraSmall

            Repeater {
                model: CalendarStore.monthCells

                delegate: Rectangle {
                    id: dayCell

                    required property var modelData

                    width: root.daySize
                    height: root.daySize
                    radius: root.luminaDesign.shape.full
                    activeFocusOnTab: modelData.enabled
                    color: modelData.isSelected
                        ? root.luminaDesign.color.accentContainer
                        : dayMouse.containsMouse && modelData.enabled
                            ? root.luminaDesign.color.surfaceMuted
                            : "transparent"
                    border.width: activeFocus || modelData.isToday ? 2 : 0
                    border.color: root.luminaDesign.color.primary

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
                            dayCell.forceActiveFocus(Qt.MouseFocusReason)
                            CalendarStore.selectDay(
                                dayCell.modelData.day
                            )
                        }
                    }
                }
            }
        }

        CalendarActionButton {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.height >= 270
            label: "Today"
            selected: CalendarStore.showingCurrentMonth
            onClicked: CalendarStore.goToToday()
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.bar.widgets
import qs.stores.time
import qs.stores.config
import qs.stores.shell
import "../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

BarPanelWindow {
    id: root

    required property string outputName
    property var panelWindow: null
    property string barPosition: "top"

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real dayCellSize: Math.max(
        luminaDesign.size.dayCell,
        (implicitWidth - luminaDesign.spacing.large * 2
            - luminaDesign.spacing.extraSmall * 6) / 7
    )

    panelId: "calendar"
    panelOutputName: outputName
    panelVisible: panelWindow !== null
        && CalendarStore.isOpenFor(outputName)
    layerNamespace: "lumina-calendar-panel"
    screen: panelWindow ? panelWindow.screen : null
    surfaceItem: calendarSurface
    surfaceRadius: calendarSurface.radius
    onDismissRequested: CalendarStore.dismiss(outputName)

    onClosed: CalendarStore.dismiss(outputName)

    Rectangle {
        id: calendarSurface

        x: SurfacePlacementPolicy.horizontalX(
            OverlayStore.activePlacement,
            OverlayStore.activeAnchorX,
            width,
            root.width,
            root.luminaDesign.spacing.medium
        )
        y: SurfacePlacementPolicy.verticalY(
            OverlayStore.activePlacement,
            root.barPosition,
            height,
            root.height,
            SurfacePlacementPolicy.barWindowHeight(
                ConfigStore.barHeight,
                ConfigStore.barSurfaceMode,
                ConfigStore.barMargin
            ),
            ConfigStore.barPanelGap,
            root.luminaDesign.spacing.medium,
            OverlayStore.activeAnchorTop,
            OverlayStore.activeAnchorBottom
        )
        width: root.luminaDesign.size.calendarWidth
        height: calendarContent.implicitHeight
            + root.luminaDesign.spacing.large * 2
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

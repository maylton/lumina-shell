import QtQuick
import QtQuick.Layouts
import qs.design
import qs.modules.calendar
import qs.stores.config
import qs.stores.shell
import qs.stores.time

Rectangle {
    id: root

    required property string outputName
    property var panelWindow: null
    property string barPosition: ConfigStore.barPosition
    property bool compact: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property string clockLayout: String(
        ConfigStore.widgetSetting(
            "datetime",
            "clockLayout",
            "inline"
        )
    )
    readonly property string dateMode: String(
        ConfigStore.widgetSetting(
            "datetime",
            "dateMode",
            "short"
        )
    )
    readonly property bool showDate: dateMode !== "hidden"
    readonly property bool showSeparator: Boolean(
        ConfigStore.widgetSetting(
            "datetime",
            "showSeparator",
            true
        )
    )
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "datetime",
            "showBackground",
            true
        )
    )
    readonly property string surfacePlacement: String(
        ConfigStore.widgetSetting(
            "datetime",
            "surfacePlacement",
            "near-widget"
        )
    )
    readonly property bool expanded:
        CalendarStore.isOpenFor(outputName)
    readonly property string formattedDate: {
        if (!showDate)
            return ""

        const style = compact ? "short" : dateMode

        if (style === "weekday")
            return Qt.formatDate(CalendarStore.currentDate, "ddd, d MMM")

        if (style === "full") {
            return CalendarStore.locale.toString(
                CalendarStore.currentDate,
                Locale.LongFormat
            )
        }

        return Qt.formatDate(CalendarStore.currentDate, "d MMM")
    }
    readonly property string accessibleDate: CalendarStore.locale.toString(
        CalendarStore.currentDate,
        Locale.LongFormat
    )

    implicitWidth: dateTimeContent.implicitWidth
        + (luminaDesign.spacing.barHorizontalPadding * 2)
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded || dateTimeMouse.containsMouse
        ? luminaDesign.shape.full
        : luminaDesign.shape.barLarge
    scale: dateTimeMouse.pressed
        ? 0.96
        : 1
    color: expanded || dateTimeMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : showBackground
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: "Open calendar"
    Accessible.description: accessibleDate
        + ", "
        + CalendarStore.formattedTime
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate(root.width / 2)

    onExpandedChanged: BarPanelCoordinator.synchronizeIndependentPanel(
        "calendar",
        root.outputName,
        root.expanded
    )

    function mappedAnchorGeometry(localX) {
        const top = root.mapToItem(
            null,
            Number(localX),
            0
        )
        const bottom = root.mapToItem(
            null,
            Number(localX),
            root.height
        )

        return {
            x: Number(top.x),
            top: Number(top.y),
            bottom: Number(bottom.y)
        }
    }

    function activate(localX) {
        const anchor = mappedAnchorGeometry(localX)

        BarPanelCoordinator.requestToggle(
            "calendar",
            root.outputName,
            root.surfacePlacement,
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

    Keys.onSpacePressed: event => {
        root.activate(root.width / 2)
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.activate(root.width / 2)
        event.accepted = true
    }

    Connections {
        target: BarPanelCoordinator

        function onOpenRequested(
            panelId,
            outputName,
            placement,
            anchorX,
            anchorTop,
            anchorBottom
        ) {
            if (panelId !== "calendar" || outputName !== root.outputName)
                return

            calendarPopup.placement = placement
            calendarPopup.anchorX = anchorX
            CalendarStore.openFor(root.outputName)
        }

        function onCloseRequested(panelId, outputName) {
            if (panelId !== "calendar" || outputName !== root.outputName)
                return

            if (root.expanded)
                CalendarStore.dismiss(root.outputName)
            else
                BarPanelCoordinator.reportClosed("calendar", root.outputName)
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialFast
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialDefault
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    GridLayout {
        id: dateTimeContent

        anchors.centerIn: parent
        columns: root.clockLayout === "inline" ? 3 : 1
        columnSpacing: root.clockLayout === "inline"
            ? root.luminaDesign.spacing.barItemGap
            : Math.max(1, root.luminaDesign.spacing.extraSmall)
        rowSpacing: Math.max(
            1,
            root.luminaDesign.spacing.extraSmall
        )

        Text {
            Layout.alignment: Qt.AlignCenter
            text: CalendarStore.formattedTime
            color: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            font.pixelSize: root.luminaDesign.typography.barClock
            font.weight: Font.Bold
        }

        Rectangle {
            Layout.alignment: Qt.AlignCenter
            visible: dateLabel.visible
                && root.showSeparator
                && root.clockLayout === "inline"
            width: root.luminaDesign.size.barDividerDot
            height: width
            radius: width / 2
            color: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.outline
        }

        Text {
            id: dateLabel

            Layout.alignment: Qt.AlignCenter
            visible: root.showDate && !root.compact
                && root.formattedDate.length > 0
            text: root.formattedDate
            color: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.textMuted
            font.pixelSize:
                root.luminaDesign.typography.barSecondary
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: dateTimeMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            root.focus = false
            root.activate(mouse.x)
        }
    }

    TrayTooltip {
        anchorItem: root
        title: root.accessibleDate
        description: "Open calendar"
        shown: dateTimeMouse.containsMouse
    }

    CalendarPopup {
        id: calendarPopup

        anchorItem: root
        panelWindow: root.panelWindow
        placement: root.surfacePlacement
        outputName: root.outputName
        barPosition: root.barPosition
    }
}

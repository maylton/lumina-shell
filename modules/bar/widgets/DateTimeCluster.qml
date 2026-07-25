import QtQuick
import qs.design
import qs.modules.calendar
import qs.stores.config
import qs.stores.time

Rectangle {
    id: root

    required property string outputName
    property string barPosition: ConfigStore.barPosition
    property bool showDate: ConfigStore.barShowDate
    property bool compact: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded:
        CalendarStore.isOpenFor(outputName)
    readonly property string formattedDate: {
        if (!showDate)
            return ""

        const style = compact ? "short" : ConfigStore.barDateStyle

        if (style === "weekday")
            return Qt.formatDate(CalendarStore.currentDate, "ddd, d MMM")

        if (style === "full")
            return CalendarStore.locale.toString(
                CalendarStore.currentDate,
                Locale.LongFormat
            )

        return Qt.formatDate(CalendarStore.currentDate, "d MMM")
    }
    readonly property string accessibleDate: CalendarStore.locale.toString(
        CalendarStore.currentDate,
        Locale.LongFormat
    )
    implicitWidth: dateTimeLabel.implicitWidth + 24
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded
        ? luminaDesign.shape.full
        : luminaDesign.shape.large
    scale: dateTimeMouse.pressed
        ? 0.94
        : dateTimeMouse.containsMouse
            ? 1.02
            : 1
    color: expanded || dateTimeMouse.containsMouse
        ? luminaDesign.color.accentContainer
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
    Accessible.onPressAction: root.activate()

    function activate() {
        CalendarStore.toggle(outputName)
    }

    Keys.onSpacePressed: event => {
        activate()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activate()
        event.accepted = true
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.fast
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.medium
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.fast
            easing.type: Easing.OutCubic
        }
    }

    Text {
        id: dateTimeLabel

        anchors.centerIn: parent
        text: root.formattedDate.length > 0
            ? root.formattedDate + "  " + CalendarStore.formattedTime
            : CalendarStore.formattedTime
        color: root.expanded
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        font.pixelSize: root.luminaDesign.typography.bodyMedium
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: dateTimeMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            root.activate()
        }
    }

    TrayTooltip {
        anchorItem: root
        title: root.accessibleDate
        description: "Open calendar"
        shown: dateTimeMouse.containsMouse
    }

    CalendarPopup {
        anchorItem: root
        outputName: root.outputName
        barPosition: root.barPosition
    }
}

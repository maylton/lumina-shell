import QtQuick
import qs.design
import qs.modules.control
import qs.services.niri
import qs.stores.config

Rectangle {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real circleDiameter:
        luminaDesign.size.barTouchTarget
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "overview",
            "showBackground",
            false
        )
    )
    readonly property bool showLabel: Boolean(
        ConfigStore.widgetSetting("overview", "showLabel", false)
    )

    width: showLabel
        ? overviewContent.implicitWidth
            + luminaDesign.spacing.barWidgetPadding * 2
        : circleDiameter
    height: circleDiameter
    implicitWidth: circleDiameter
    implicitHeight: circleDiameter
    radius: NiriService.overviewOpen || overviewMouse.pressed
        ? luminaDesign.shape.barIconActivated
        : circleDiameter / 2
    scale: overviewMouse.pressed
        ? 0.96
        : 1.0
    color: NiriService.overviewOpen || overviewMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : showBackground
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: NiriService.overviewOpen
        ? "Close Niri overview"
        : "Open Niri overview"
    Accessible.description: "Show workspaces and windows"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate()

    function activate() {
        NiriService.toggleOverview()
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

    Row {
        id: overviewContent

        anchors.centerIn: parent
        spacing: root.showLabel
            ? root.luminaDesign.spacing.barItemGap
            : 0

        DashboardIcon {
            anchors.verticalCenter: parent.verticalCenter
            iconName: "view-grid-symbolic"
            fallbackSymbol: "▦"
            iconColor: NiriService.overviewOpen
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            iconSize: root.luminaDesign.size.barIcon
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showLabel
            text: "Overview"
            color: NiriService.overviewOpen
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            font.pixelSize:
                root.luminaDesign.typography.barSecondary
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: overviewMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.focus = false
            root.activate()
        }
    }

}

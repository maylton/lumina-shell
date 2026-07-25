pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.session
import qs.stores.config
import qs.stores.session

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: SessionMenuStore.activeOutputName
        === outputName
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "session",
            "showBackground",
            false
        )
    )
    readonly property bool showLabel: Boolean(
        ConfigStore.widgetSetting("session", "showLabel", false)
    )

    implicitWidth: showLabel
        ? sessionContent.implicitWidth
            + luminaDesign.spacing.barWidgetPadding * 2
        : luminaDesign.size.barTouchTarget
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded
        ? luminaDesign.shape.full
        : luminaDesign.shape.barMedium
    color: expanded || sessionMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : showBackground
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    scale: sessionMouse.pressed
        ? 0.96
        : 1.0
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary
    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: "Open session and layout controls"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate()

    Keys.onSpacePressed: event => {
        activate()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activate()
        event.accepted = true
    }

    function activate() {
        if (expanded) {
            SessionService.cancel()
            SessionMenuStore.close()
        } else {
            SessionMenuStore.openFor(outputName)
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

    Row {
        id: sessionContent

        anchors.centerIn: parent
        spacing: root.showLabel
            ? root.luminaDesign.spacing.barItemGap
            : 0

        DashboardIcon {
            anchors.verticalCenter: parent.verticalCenter
            iconName: "system-shutdown-symbolic"
            fallbackSymbol: "⏻"
            iconColor: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            iconSize: root.luminaDesign.size.barIcon
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showLabel
            text: "Session"
            color: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            font.pixelSize:
                root.luminaDesign.typography.barSecondary
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: sessionMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.focus = false
            root.activate()
        }
    }
}

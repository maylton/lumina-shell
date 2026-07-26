import QtQuick
import qs.design
import qs.modules.control

Rectangle {
    id: root

    property string iconName: ""
    property string fallbackSymbol: ""
    property string label: ""
    property string description: ""
    property bool showLabel: true
    property bool individual: false
    property bool showBackground: true
    property bool alert: false
    property bool expressiveBattery: false
    property real batteryPercentage: 0
    property bool batteryCharging: false
    property bool interactive: false
    property bool selected: false

    signal activated(real localX)

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool hovered:
        root.interactive && interactionMouse.containsMouse

    z: interactive ? 2 : 0
    implicitWidth: statusContent.implicitWidth
        + (
            individual
                ? luminaDesign.spacing.barWidgetPadding * 2
                : luminaDesign.spacing.barItemGap
        )
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: individual || interactive ? luminaDesign.shape.barLarge : 0
    color: selected || hovered
        ? luminaDesign.color.accentContainer
        : individual && showBackground
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    scale: interactionMouse.pressed ? 0.96 : 1
    activeFocusOnTab: interactive
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: interactive ? Accessible.Button : Accessible.NoRole
    Accessible.name: description
    Accessible.focusable: interactive
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activated(root.width / 2)

    Keys.onSpacePressed: event => {
        if (root.interactive)
            root.activated(root.width / 2)
        event.accepted = true
    }
    Keys.onReturnPressed: event => {
        if (root.interactive)
            root.activated(root.width / 2)
        event.accepted = true
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialDefault
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Row {
        id: statusContent

        anchors.centerIn: parent
        spacing: root.showLabel
            ? root.luminaDesign.spacing.barItemGap
            : 0

        Behavior on spacing {
            NumberAnimation {
                duration: root.luminaDesign.motion.spatialDefault
                easing.type:
                    root.luminaDesign.motion.spatialEasing
                easing.overshoot:
                    root.luminaDesign.motion.spatialOvershoot
            }
        }

        DashboardIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.expressiveBattery
            iconName: root.iconName
            fallbackSymbol: root.fallbackSymbol
            iconColor: root.alert
                ? root.luminaDesign.color.urgent
                : root.selected
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.onSurface
            iconSize: root.luminaDesign.size.barStatusIcon
        }

        ExpressiveBatteryIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.expressiveBattery
            percentage: root.batteryPercentage
            charging: root.batteryCharging
            iconSize: root.luminaDesign.size.barStatusIcon
            iconColor: root.luminaDesign.color.onSurface
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showLabel && text.length > 0
            text: root.label
            color: root.alert
                ? root.luminaDesign.color.urgent
                : root.selected
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.onSurface
            font.pixelSize:
                root.luminaDesign.typography.barSecondary
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: interactionMouse
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: mouse => {
            root.focus = false
            root.activated(mouse.x)
        }
    }
}

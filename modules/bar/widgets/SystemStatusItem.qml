import QtQuick
import qs.design
import qs.modules.control
import qs.stores.config

Rectangle {
    id: root

    property string iconName: ""
    property string fallbackSymbol: ""
    property string label: ""
    property string description: ""
    property bool showLabel: true
    property bool individual: false
    property bool alert: false
    property bool expressiveBattery: false
    property real batteryPercentage: 0
    property bool batteryCharging: false

    readonly property var luminaDesign: Theme.luminaTokens

    implicitWidth: statusContent.implicitWidth
        + (
            individual
                ? luminaDesign.spacing.barWidgetPadding * 2
                : luminaDesign.spacing.barItemGap
        )
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: individual ? luminaDesign.shape.barLarge : 0
    color: individual && Boolean(
        ConfigStore.widgetSetting(
            "system-status",
            "showBackground",
            true
        )
    )
        ? luminaDesign.color.surfaceMuted
        : "transparent"

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialDefault
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
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
                : root.luminaDesign.color.onSurface
            font.pixelSize:
                root.luminaDesign.typography.barSecondary
            font.weight: Font.DemiBold
        }
    }
}

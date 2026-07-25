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
    property bool alert: false

    readonly property var luminaDesign: Theme.luminaTokens

    implicitWidth: statusContent.implicitWidth
        + (
            individual
                ? luminaDesign.spacing.barWidgetPadding * 2
                : luminaDesign.spacing.barItemGap
        )
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: individual ? luminaDesign.shape.large : 0
    color: individual
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
            iconName: root.iconName
            fallbackSymbol: root.fallbackSymbol
            iconColor: root.alert
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.onSurface
            iconSize: root.luminaDesign.size.barStatusIcon
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

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

    implicitWidth: statusContent.implicitWidth + (individual ? 16 : 4)
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: individual ? luminaDesign.shape.large : 0
    color: individual
        ? luminaDesign.color.surfaceMuted
        : "transparent"

    Row {
        id: statusContent

        anchors.centerIn: parent
        spacing: root.showLabel
            ? root.luminaDesign.spacing.small
            : 0

        DashboardIcon {
            anchors.verticalCenter: parent.verticalCenter
            iconName: root.iconName
            fallbackSymbol: root.fallbackSymbol
            iconColor: root.alert
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.onSurface
            iconSize: 17
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showLabel && text.length > 0
            text: root.label
            color: root.alert
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.onSurface
            font.pixelSize: root.luminaDesign.typography.labelMedium
            font.weight: Font.DemiBold
        }
    }
}

import QtQuick
import qs.design
import qs.modules.control

Rectangle {
    id: root

    property string iconName: ""
    property string customSource: ""
    property string fallbackSymbol: "•"

    readonly property var luminaDesign: Theme.luminaTokens

    implicitWidth: 48
    implicitHeight: 54
    radius: luminaDesign.shape.medium
    color: luminaDesign.color.surfaceContainer

    DashboardIcon {
        anchors.centerIn: parent
        iconName: root.iconName
        customSource: root.customSource
        fallbackSymbol: root.fallbackSymbol
        iconColor: root.luminaDesign.color.primary
        iconSize: 22
    }
}

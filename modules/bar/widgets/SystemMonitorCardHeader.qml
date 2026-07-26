import QtQuick
import qs.design

Item {
    id: root

    property string iconName: ""
    property string customSource: ""
    property string fallbackSymbol: "•"
    property string title: ""
    property string subtitle: ""

    readonly property var luminaDesign: Theme.luminaTokens

    implicitHeight: 54

    SystemMonitorIconBadge {
        id: badge

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        iconName: root.iconName
        customSource: root.customSource
        fallbackSymbol: root.fallbackSymbol
    }

    Column {
        anchors {
            left: badge.right
            right: parent.right
            leftMargin: 12
            verticalCenter: parent.verticalCenter
        }
        spacing: 2

        Text {
            width: parent.width
            text: root.title
            color: root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize: 22
            font.weight: Font.Medium
        }

        Text {
            width: parent.width
            visible: text.length > 0
            text: root.subtitle
            color: root.luminaDesign.color.textMuted
            elide: Text.ElideRight
            font.pixelSize: 16
            font.weight: Font.Normal
        }
    }
}

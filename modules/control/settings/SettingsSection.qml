pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    required property string title
    property string description: ""
    default property alias sectionData: body.data

    readonly property var luminaDesign: Theme.luminaTokens

    width: parent ? parent.width : 0
    implicitHeight: sectionColumn.implicitHeight
        + luminaDesign.spacing.extraLarge * 2
    radius: luminaDesign.shape.large
    color: luminaDesign.color.surfaceBase
    border.width: 1
    border.color: luminaDesign.color.outline

    Accessible.role: Accessible.Grouping
    Accessible.name: title
    Accessible.description: description

    Column {
        id: sectionColumn

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: root.luminaDesign.spacing.extraLarge
        }

        spacing: root.luminaDesign.spacing.medium

        Column {
            width: parent.width
            spacing: 3

            Text {
                text: root.title
                color: root.luminaDesign.color.onSurface
                font.pixelSize:
                    root.luminaDesign.typography.titleMedium
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                visible: text.length > 0
                text: root.description
                color: root.luminaDesign.color.textMuted
                wrapMode: Text.WordWrap
                font.pixelSize:
                    root.luminaDesign.typography.labelSmall
            }
        }

        Column {
            id: body

            width: parent.width
            spacing: root.luminaDesign.spacing.small
        }
    }
}

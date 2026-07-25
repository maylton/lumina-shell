pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    required property string title
    property string description: ""
    property bool groupedRows: true
    default property alias sectionData: body.data

    readonly property var luminaDesign: Theme.luminaTokens

    width: parent ? parent.width : 0
    implicitHeight: sectionColumn.implicitHeight
        + luminaDesign.spacing.controlContentInset * 2
    radius: luminaDesign.shape.extraLarge
    color: luminaDesign.color.surfaceBase
    border.width: 0

    Accessible.role: Accessible.Grouping
    Accessible.name: title
    Accessible.description: description

    Column {
        id: sectionColumn

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: root.luminaDesign.spacing.controlContentInset
        }

        spacing: root.luminaDesign.spacing.controlItemGap

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

        Rectangle {
            width: parent.width
            implicitHeight: body.implicitHeight
            radius: root.luminaDesign.shape.largeIncreased
            color: root.groupedRows
                ? root.luminaDesign.color.surfaceMuted
                : "transparent"
            clip: root.groupedRows

            Column {
                id: body

                property bool settingsGroup: root.groupedRows

                width: parent.width
                spacing: root.groupedRows
                    ? 1
                    : root.luminaDesign.spacing.controlItemGap
            }
        }
    }
}

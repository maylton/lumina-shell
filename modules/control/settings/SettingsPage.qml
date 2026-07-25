pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.stores.config

Flickable {
    id: root

    required property string title
    required property string description
    property string anchorSection: ""
    default property alias pageData: pageBody.data

    readonly property var luminaDesign: Theme.luminaTokens

    clip: true
    contentWidth: width
    contentHeight: pageColumn.implicitHeight
        + luminaDesign.spacing.extraLarge
    boundsBehavior: Flickable.StopAtBounds
    flickDeceleration: 2600

    Column {
        id: pageColumn

        width: root.width
        spacing: root.luminaDesign.spacing.large

        Row {
            width: parent.width
            height: 48

            Column {
                width: parent.width - saveStatus.width
                    - root.luminaDesign.spacing.large
                spacing: 3

                Text {
                    text: root.title
                    color: root.luminaDesign.color.onSurface
                    font.pixelSize:
                        root.luminaDesign.typography.titleLarge
                    font.weight: Font.Bold
                }

                Text {
                    width: parent.width
                    text: root.description
                    color: root.luminaDesign.color.textMuted
                    elide: Text.ElideRight
                    font.pixelSize:
                        root.luminaDesign.typography.labelMedium
                }
            }

            Rectangle {
                id: saveStatus

                width: statusText.implicitWidth + 22
                height: 30
                radius: root.luminaDesign.shape.full
                color: root.luminaDesign.color.surfaceMuted

                Text {
                    id: statusText

                    anchors.centerIn: parent
                    text: ConfigStore.saveStatusLabel
                    color: ConfigStore.lastSaveSucceeded
                        ? root.luminaDesign.color.textMuted
                        : root.luminaDesign.color.urgent
                    font.pixelSize:
                        root.luminaDesign.typography.labelSmall
                    font.weight: Font.DemiBold
                }
            }
        }

        Column {
            id: pageBody

            width: parent.width
            spacing: root.luminaDesign.spacing.large
        }
    }

}

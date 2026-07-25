import QtQuick
import qs.design

Rectangle {
    id: root

    default property alias contentData: content.data
    property int outerMargin: 0

    readonly property var luminaDesign: Theme.luminaTokens

    anchors.margins: outerMargin
    radius: luminaDesign.shape.large
    color: luminaDesign.color.surfaceContainer
    border.width: 1
    border.color: luminaDesign.color.outline

    Item {
        id: content

        anchors.fill: parent
    }
}

import QtQuick
import qs.design

Rectangle {
    id: root

    default property alias contentData: content.data
    property string surfaceMode: "floating"
    property string barPosition: "top"
    property int outerMargin: 0

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool edgeToEdge: surfaceMode === "edge-to-edge"

    anchors.margins: edgeToEdge ? 0 : outerMargin
    radius: edgeToEdge ? 0 : luminaDesign.shape.large
    color: luminaDesign.color.surfaceContainer
    border.width: edgeToEdge ? 0 : 1
    border.color: luminaDesign.color.outline

    Item {
        id: content

        anchors.fill: parent
    }

    Rectangle {
        visible: root.edgeToEdge
        anchors {
            left: parent.left
            right: parent.right
            top: root.barPosition === "bottom"
                ? parent.top
                : undefined
            bottom: root.barPosition === "top"
                ? parent.bottom
                : undefined
        }
        height: 1
        color: root.luminaDesign.color.outline
        opacity: 0.45
    }
}

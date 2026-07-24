pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    property string accessibleName: ""
    property bool emphasized: false

    readonly property var luminaDesign: Theme.luminaTokens

    radius: luminaDesign.shape.large
    color: emphasized
        ? Qt.lighter(luminaDesign.color.surfaceContainer, 1.06)
        : luminaDesign.color.surfaceBase
    border.width: 1
    border.color: emphasized
        ? luminaDesign.color.accentContainer
        : luminaDesign.color.outline

    Accessible.role: Accessible.Pane
    Accessible.name: accessibleName
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.design

Flickable {
    id: root

    property real maximumHeight: 340
    default property alias listData: listColumn.data

    readonly property var luminaDesign: Theme.luminaTokens

    width: parent ? parent.width : 0
    implicitHeight: Math.min(
        maximumHeight,
        Math.max(0, listColumn.implicitHeight)
    )
    height: implicitHeight
    contentWidth: width
    contentHeight: listColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickDeceleration: 2600

    Controls.ScrollBar.vertical: Controls.ScrollBar {
        policy: root.contentHeight > root.height
            ? Controls.ScrollBar.AsNeeded
            : Controls.ScrollBar.AlwaysOff
    }

    Column {
        id: listColumn

        property bool settingsGroup: true

        width: root.width
        spacing: 1
    }
}

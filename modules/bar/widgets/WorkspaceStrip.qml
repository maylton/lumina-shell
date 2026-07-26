pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.stores.config

Rectangle {
    id: root

    property var workspaces: []
    property real itemSpacing: 0

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "workspaces",
            "showBackground",
            false
        )
    )
    readonly property string labelMode: String(
        ConfigStore.widgetSetting(
            "workspaces",
            "labelMode",
            "active"
        )
    )
    readonly property string inactiveStyle: String(
        ConfigStore.widgetSetting(
            "workspaces",
            "inactiveStyle",
            "dot"
        )
    )

    implicitWidth: workspaceRow.implicitWidth
        + (showBackground ? luminaDesign.spacing.barItemGap * 2 : 0)
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: luminaDesign.shape.full
    color: showBackground
        ? luminaDesign.color.surfaceMuted
        : "transparent"

    Row {
        id: workspaceRow

        anchors.centerIn: parent
        spacing: Math.min(
            root.itemSpacing,
            root.luminaDesign.spacing.barItemGap
        )

        Repeater {
            model: root.workspaces

            delegate: WorkspacePill {
                required property var modelData

                workspace: modelData
                labelMode: root.labelMode
                inactiveStyle: root.inactiveStyle
            }
        }
    }
}

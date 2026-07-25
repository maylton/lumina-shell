pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Row {
    id: root

    property var workspaces: []
    property real itemSpacing: 0

    readonly property var luminaDesign: Theme.luminaTokens

    spacing: Math.min(
        itemSpacing,
        luminaDesign.spacing.barItemGap
    )

    Repeater {
        model: root.workspaces

        delegate: WorkspacePill {
            required property var modelData

            workspace: modelData
        }
    }
}

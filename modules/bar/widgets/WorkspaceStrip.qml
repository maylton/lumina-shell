pragma ComponentBehavior: Bound

import QtQuick

Row {
    id: root

    property var workspaces: []
    property real itemSpacing: 0

    spacing: itemSpacing

    Repeater {
        model: root.workspaces

        delegate: WorkspacePill {
            required property var modelData

            workspace: modelData
        }
    }
}

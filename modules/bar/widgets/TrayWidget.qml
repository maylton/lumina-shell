pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.SystemTray
import qs.design

Item {
    id: root

    property bool expressive: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var activeItems: {
        const items = []
        const values = SystemTray.items.values

        for (var index = 0; index < values.length; ++index) {
            const item = values[index]

            if (item && item.status !== Status.Passive)
                items.push(item)
        }

        return items
    }
    readonly property int itemCount: activeItems.length

    visible: itemCount > 0
    implicitWidth: visible ? trayRow.implicitWidth : 0
    implicitHeight: luminaDesign.size.chipHeight

    Row {
        id: trayRow

        anchors.verticalCenter: parent.verticalCenter
        spacing: root.luminaDesign.spacing.extraSmall

        Repeater {
            model: root.activeItems

            delegate: TrayItem {
                required property var modelData

                trayItem: modelData
                expressive: root.expressive
            }
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import qs.design

SettingsRow {
    id: root

    property string actionLabel: "Open"
    property bool destructive: false

    controlWidth: Math.max(110, actionText.implicitWidth + 30)

    Rectangle {
        anchors.fill: parent
        radius: root.luminaDesign.shape.full
        color: root.destructive
            ? root.luminaDesign.color.errorContainer
            : root.luminaDesign.color.accentContainer
        border.width: root.destructive ? 1 : 0
        border.color: root.luminaDesign.color.urgent

        Text {
            id: actionText

            anchors.centerIn: parent
            text: root.actionLabel
            color: root.destructive
                ? root.luminaDesign.color.onErrorContainer
                : root.luminaDesign.color.onAccentContainer
            font.pixelSize: root.luminaDesign.typography.labelMedium
            font.weight: Font.DemiBold
        }
    }
}

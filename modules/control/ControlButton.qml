pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.audio
import qs.services.connectivity
import qs.stores.control

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded:
        ControlCenterStore.activeOutputName === outputName

    implicitWidth: statusRow.implicitWidth + 20
    implicitHeight: luminaDesign.size.chipHeight
    radius: expanded ? luminaDesign.shape.full : luminaDesign.shape.medium
    color: expanded || controlMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : "transparent"
    scale: controlMouse.pressed
        ? 0.94
        : controlMouse.containsMouse
            ? 1.03
            : 1

    Accessible.role: Accessible.Button
    Accessible.name: "Open quick settings"
    Accessible.description: ConnectivityService.networkSummary
        + ", volume "
        + Math.round(AudioService.outputVolume * 100)
        + " percent"

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.fast
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.fast
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: statusRow

        anchors.centerIn: parent
        spacing: 6

        Text {
            text: ConnectivityService.wifiConnected
                ? "◉"
                : ConnectivityService.wiredConnected
                    ? "◆"
                    : "◇"
            color: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : ConnectivityService.networkSummary === "Offline"
                    ? root.luminaDesign.color.urgent
                    : root.luminaDesign.color.primary
            font.pixelSize: root.luminaDesign.typography.labelMedium
        }

        Text {
            text: AudioService.outputMuted
                ? "×"
                : Math.round(AudioService.outputVolume * 100) + "%"
            color: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            font.pixelSize: root.luminaDesign.typography.labelMedium
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: controlMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ControlCenterStore.toggle(root.outputName)
    }
}

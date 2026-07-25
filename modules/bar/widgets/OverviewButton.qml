import QtQuick
import qs.design
import qs.services.niri

Rectangle {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    implicitWidth: overviewLabel.implicitWidth + 20
    implicitHeight: luminaDesign.size.chipHeight
    radius: NiriService.overviewOpen
        ? luminaDesign.shape.full
        : luminaDesign.shape.medium
    scale: overviewMouse.pressed
        ? 0.94
        : overviewMouse.containsMouse
            ? 1.03
            : 1.0
    color: NiriService.overviewOpen || overviewMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : luminaDesign.color.surfaceMuted

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.fast
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.medium
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.fast
            easing.type: Easing.OutCubic
        }
    }

    Text {
        id: overviewLabel

        anchors.centerIn: parent
        text: NiriService.overviewOpen ? "Close overview" : "Overview"
        color: NiriService.overviewOpen
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        font.pixelSize: root.luminaDesign.typography.labelMedium
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: overviewMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: NiriService.toggleOverview()
    }
}

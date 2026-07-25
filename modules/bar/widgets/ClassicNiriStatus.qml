import QtQuick
import qs.design
import qs.services.niri

Column {
    id: root

    required property bool showActionError
    required property string outputSummary

    readonly property var luminaDesign: Theme.luminaTokens

    spacing: 0

    Row {
        spacing: root.luminaDesign.spacing.small

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: root.luminaDesign.size.statusDot
            height: root.luminaDesign.size.statusDot
            radius: width / 2
            color: root.showActionError
                ? root.luminaDesign.color.urgent
                : NiriService.connected
                    ? root.luminaDesign.color.primary
                    : NiriService.demoMode
                        ? root.luminaDesign.color.outline
                        : root.luminaDesign.color.urgent

            Behavior on color {
                ColorAnimation {
                    duration: root.luminaDesign.motion.medium
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.showActionError
                ? "Niri action failed"
                : NiriService.actionRunning
                    ? "Niri · Working"
                    : NiriService.demoMode
                        ? "Demo"
                        : NiriService.connected
                            ? "Niri"
                            : "Connecting"
            color: root.showActionError
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.textMuted
            font.pixelSize: root.luminaDesign.typography.labelSmall
            font.weight: Font.Medium
        }
    }

    Text {
        width: Math.min(implicitWidth, 240)
        text: root.showActionError
            ? NiriService.lastActionError
            : root.outputSummary
        color: root.showActionError
            ? root.luminaDesign.color.urgent
            : root.luminaDesign.color.textMuted
        elide: Text.ElideRight
        font.pixelSize: root.luminaDesign.typography.labelSmall
    }
}

import QtQuick
import qs.design
import qs.services.niri
import qs.stores.niri

Rectangle {
    id: root

    required property var workspace

    readonly property var luminaDesign: Theme.luminaTokens

    implicitWidth: workspaceLabel.implicitWidth + 18
    implicitHeight: luminaDesign.size.chipHeight
    radius: workspace.is_focused
        ? luminaDesign.shape.full
        : workspace.is_active
            ? luminaDesign.shape.large
            : luminaDesign.shape.small
    scale: workspaceMouse.pressed
        ? 0.92
        : workspaceMouse.containsMouse
            ? 1.04
            : 1.0
    color: workspace.is_focused || workspaceMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : workspace.is_active
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    border.width: workspace.is_urgent ? 1 : 0
    border.color: luminaDesign.color.urgent

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
        id: workspaceLabel

        anchors.centerIn: parent
        text: WorkspaceStore.labelFor(root.workspace)
        color: root.workspace.is_focused
            ? root.luminaDesign.color.onAccentContainer
            : root.workspace.is_urgent
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.textMuted
        font.pixelSize: root.luminaDesign.typography.labelMedium
        font.weight: root.workspace.is_active
            ? Font.DemiBold
            : Font.Medium
    }

    MouseArea {
        id: workspaceMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: NiriService.focusWorkspace(root.workspace)
    }
}

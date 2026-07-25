import QtQuick
import qs.design
import qs.services.niri
import qs.stores.niri

Rectangle {
    id: root

    required property var workspace
    property string visualStyle: "classic"

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expressive: visualStyle === "expressive"
    readonly property bool selected: Boolean(workspace.is_focused)
    readonly property bool active: Boolean(workspace.is_active)

    implicitWidth: expressive
        ? selected || active
            ? workspaceLabel.implicitWidth + 28
            : Math.max(
                luminaDesign.size.barTouchTarget,
                workspaceLabel.implicitWidth + 16
            )
        : workspaceLabel.implicitWidth + 18
    implicitHeight: expressive
        ? luminaDesign.size.barTouchTarget
        : luminaDesign.size.chipHeight
    radius: selected
        ? luminaDesign.shape.workspaceActive
        : active
            ? expressive
                ? luminaDesign.shape.large
                : luminaDesign.shape.large
            : expressive
                ? luminaDesign.shape.workspaceResting
                : luminaDesign.shape.small
    scale: workspaceMouse.pressed
        ? 0.92
        : workspaceMouse.containsMouse
            ? 1.04
            : 1.0
    color: selected || workspaceMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : active
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    border.width: workspace.is_urgent ? 1 : 0
    border.color: luminaDesign.color.urgent
    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: "Switch to workspace "
        + WorkspaceStore.labelFor(workspace)
    Accessible.description: workspace.is_urgent
        ? "Workspace requests attention"
        : selected
            ? "Focused workspace"
            : active
                ? "Active workspace"
                : "Inactive workspace"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.checked: selected
    Accessible.onPressAction: root.activate()

    function activate() {
        NiriService.focusWorkspace(workspace)
    }

    Keys.onSpacePressed: event => {
        activate()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activate()
        event.accepted = true
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.luminaDesign.motion.workspaceTransform
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.fast
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.workspaceTransform
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
        color: root.selected
            ? root.luminaDesign.color.onAccentContainer
            : root.workspace.is_urgent
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.textMuted
        font.pixelSize: root.luminaDesign.typography.labelMedium
        font.weight: root.active
            ? Font.DemiBold
            : Font.Medium
    }

    MouseArea {
        id: workspaceMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            root.activate()
        }
    }

    TrayTooltip {
        anchorItem: root
        title: "Workspace " + WorkspaceStore.labelFor(root.workspace)
        description: root.workspace.is_urgent
            ? "Requests attention"
            : root.selected
                ? "Focused on this output"
                : root.active
                    ? "Active on this output"
                    : "Switch workspace"
        shown: workspaceMouse.containsMouse
    }
}

import QtQuick
import qs.design
import qs.services.niri
import qs.stores.niri

Rectangle {
    id: root

    required property var workspace

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool selected: Boolean(workspace.is_focused)
    readonly property bool active: Boolean(workspace.is_active)

    implicitWidth: selected
        ? workspaceLabel.implicitWidth + 32
        : active
            ? workspaceLabel.implicitWidth + 24
            : luminaDesign.size.barTouchTarget
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: luminaDesign.shape.full
    scale: workspaceMouse.pressed
        ? 0.96
        : 1.0
    color: "transparent"
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary
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
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Rectangle {
        id: workspaceVisual

        anchors.centerIn: parent
        width: root.selected
            ? root.width
            : root.active
                ? workspaceLabel.implicitWidth + 24
                : workspaceMouse.containsMouse
                    ? 18
                    : 10
        height: root.selected
            ? root.height
            : root.active
                ? root.height - 6
                : workspaceMouse.containsMouse
                    ? 18
                    : 10
        radius: root.selected
            ? root.luminaDesign.shape.workspaceActive
            : root.active
                ? root.luminaDesign.shape.large
                : root.luminaDesign.shape.full
        color: root.selected || workspaceMouse.containsMouse
            ? root.luminaDesign.color.accentContainer
            : root.active
                ? root.luminaDesign.color.surfaceMuted
                : root.luminaDesign.color.outline
        border.width: root.workspace.is_urgent ? 2 : 0
        border.color: root.luminaDesign.color.urgent

        Behavior on width {
            NumberAnimation {
                duration: root.luminaDesign.motion.workspaceTransform
                easing.type: root.luminaDesign.motion.spatialEasing
                easing.overshoot:
                    root.luminaDesign.motion.spatialOvershoot
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: root.luminaDesign.motion.workspaceTransform
                easing.type: root.luminaDesign.motion.spatialEasing
                easing.overshoot:
                    root.luminaDesign.motion.spatialOvershoot
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: root.luminaDesign.motion.effectsFast
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: root.luminaDesign.motion.workspaceTransform
                easing.type: root.luminaDesign.motion.spatialEasing
                easing.overshoot:
                    root.luminaDesign.motion.spatialOvershoot
            }
        }

        Text {
            id: workspaceLabel

            anchors.centerIn: parent
            visible: root.selected || root.active
            opacity: visible ? 1 : 0
            text: WorkspaceStore.labelFor(root.workspace)
            color: root.selected
                ? root.luminaDesign.color.onAccentContainer
                : root.workspace.is_urgent
                    ? root.luminaDesign.color.urgent
                    : root.luminaDesign.color.onSurface
            font.pixelSize: root.luminaDesign.typography.labelMedium
            font.weight: Font.DemiBold

            Behavior on opacity {
                NumberAnimation {
                    duration: root.luminaDesign.motion.effectsFast
                    easing.type:
                        root.luminaDesign.motion.effectsEasing
                }
            }
        }
    }

    MouseArea {
        id: workspaceMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.focus = false
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

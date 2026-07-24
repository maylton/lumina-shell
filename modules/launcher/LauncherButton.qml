pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.stores.launcher

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: LauncherStore.open
        && LauncherStore.activeOutputName === outputName

    implicitWidth: launcherLabel.implicitWidth + 20
    implicitHeight: luminaDesign.size.chipHeight
    radius: expanded ? luminaDesign.shape.full : luminaDesign.shape.medium
    scale: launcherMouse.pressed
        ? 0.94
        : launcherMouse.containsMouse
            ? 1.03
            : 1.0
    color: expanded || launcherMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : luminaDesign.color.surfaceMuted
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: "Open application launcher"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: LauncherStore.toggle(root.outputName)

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
        id: launcherLabel

        anchors.centerIn: parent
        text: "Apps"
        color: root.expanded
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        font.pixelSize: root.luminaDesign.typography.labelMedium
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: launcherMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: LauncherStore.toggle(root.outputName)
    }
}

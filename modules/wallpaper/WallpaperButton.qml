pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.wallpaper

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: WallpaperService.pickerOutputName
        === outputName

    implicitWidth: wallpaperLabel.implicitWidth + 20
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded ? luminaDesign.shape.full : luminaDesign.shape.medium
    color: expanded || wallpaperMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : "transparent"
    scale: wallpaperMouse.pressed
        ? 0.94
        : wallpaperMouse.containsMouse
            ? 1.03
            : 1.0
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary
    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: "Open wallpaper picker"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction:
        WallpaperService.togglePicker(root.outputName)

    Keys.onSpacePressed: event => {
        WallpaperService.togglePicker(root.outputName)
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        WallpaperService.togglePicker(root.outputName)
        event.accepted = true
    }

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

    Text {
        id: wallpaperLabel

        anchors.centerIn: parent
        text: "Wall"
        color: root.expanded
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        font.pixelSize: root.luminaDesign.typography.labelMedium
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: wallpaperMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            WallpaperService.togglePicker(root.outputName)
        }
    }
}

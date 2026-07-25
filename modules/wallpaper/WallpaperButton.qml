pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.wallpaper
import qs.stores.config

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: WallpaperService.pickerOutputName
        === outputName
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "wallpaper",
            "showBackground",
            false
        )
    )
    readonly property bool showLabel: Boolean(
        ConfigStore.widgetSetting("wallpaper", "showLabel", false)
    )

    implicitWidth: showLabel
        ? wallpaperContent.implicitWidth
            + luminaDesign.spacing.barWidgetPadding * 2
        : luminaDesign.size.barTouchTarget
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded
        ? luminaDesign.shape.full
        : luminaDesign.shape.barMedium
    color: expanded || wallpaperMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : showBackground
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    scale: wallpaperMouse.pressed
        ? 0.96
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
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialFast
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

    Row {
        id: wallpaperContent

        anchors.centerIn: parent
        spacing: root.showLabel
            ? root.luminaDesign.spacing.barItemGap
            : 0

        DashboardIcon {
            anchors.verticalCenter: parent.verticalCenter
            iconName: "preferences-desktop-wallpaper-symbolic"
            fallbackSymbol: "▧"
            iconColor: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            iconSize: root.luminaDesign.size.barIcon
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showLabel
            text: "Wallpaper"
            color: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            font.pixelSize:
                root.luminaDesign.typography.barSecondary
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: wallpaperMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.focus = false
            WallpaperService.togglePicker(root.outputName)
        }
    }
}

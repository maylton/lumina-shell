pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.services.i18n
import "DockStrings.js" as DockStrings

Rectangle {
    id: root

    required property var item
    required property int iconSize

    signal activated
    signal pinToggled

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool focused: Boolean(item && item.focused)
    readonly property bool running: Boolean(item && item.running)
    readonly property bool urgent: Boolean(item && item.urgent)
    readonly property bool pinned: Boolean(item && item.pinned)
    readonly property string title: String(item && item.title || "Application")
    readonly property string pinHint: pinned
        ? DockStrings.text(I18n.locale, "rightClickUnpin")
        : DockStrings.text(I18n.locale, "rightClickPin")

    width: iconSize + 12
    height: iconSize + 12
    radius: itemMouse.pressed
        ? luminaDesign.shape.medium
        : focused || itemMouse.containsMouse
            ? luminaDesign.shape.large
            : luminaDesign.shape.full
    color: focused
        ? luminaDesign.color.accentContainer
        : itemMouse.containsMouse
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    scale: itemMouse.pressed
        ? 0.94
        : itemMouse.containsMouse
            ? 1.07
            : 1
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: title
    Accessible.description: (running
        ? DockStrings.text(I18n.locale, "running") + ". "
        : "") + pinHint
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activated()

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialFast
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot: root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Keys.onSpacePressed: event => {
        root.activated()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.activated()
        event.accepted = true
    }

    Image {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        source: Quickshell.iconPath(
            String(root.item && root.item.icon
                || "application-x-executable"),
            "application-x-executable"
        )
        sourceSize.width: width
        sourceSize.height: height
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Rectangle {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 2
        }
        visible: root.running
        width: root.focused ? 20 : 7
        height: 4
        radius: 2
        color: root.urgent
            ? root.luminaDesign.color.urgent
            : root.focused
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.outline

        Behavior on width {
            NumberAnimation {
                duration: root.luminaDesign.motion.spatialFast
                easing.type: root.luminaDesign.motion.spatialEasing
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: root.luminaDesign.motion.effectsFast
            }
        }
    }

    Rectangle {
        anchors {
            right: parent.right
            top: parent.top
            margins: 4
        }
        visible: root.pinned
        width: 7
        height: 7
        radius: 4
        color: root.luminaDesign.color.primary
    }

    MouseArea {
        id: itemMouse

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            root.forceActiveFocus(Qt.MouseFocusReason)

            if (mouse.button === Qt.RightButton)
                root.pinToggled()
            else
                root.activated()
        }
    }
}

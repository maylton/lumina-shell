pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.i18n
import "DockStrings.js" as DockStrings

Rectangle {
    id: root

    property bool opened: false
    property bool pinned: false
    property string applicationTitle: ""

    signal actionTriggered
    signal closeRequested

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property string actionLabel: pinned
        ? DockStrings.text(I18n.locale, "unpinFromDock")
        : DockStrings.text(I18n.locale, "pinToDock")

    visible: opened
    width: 224
    height: 52
    radius: luminaDesign.shape.large
    color: luminaDesign.color.surfaceContainer
    border.width: 1
    border.color: luminaDesign.color.outline
    activeFocusOnTab: false

    Accessible.role: Accessible.Menu
    Accessible.name: applicationTitle.length > 0
        ? DockStrings.text(I18n.locale, "applicationMenu")
            + ": " + applicationTitle
        : DockStrings.text(I18n.locale, "applicationMenu")

    function open() {
        opened = true
        Qt.callLater(function() {
            menuAction.forceActiveFocus(Qt.PopupFocusReason)
        })
    }

    function close() {
        opened = false
        menuAction.focus = false
    }

    Keys.onEscapePressed: event => {
        root.closeRequested()
        event.accepted = true
    }

    Rectangle {
        id: menuAction

        anchors {
            fill: parent
            margins: 6
        }
        radius: root.luminaDesign.shape.medium
        color: actionMouse.pressed
            ? root.luminaDesign.color.pressedState
            : actionMouse.containsMouse || activeFocus
                ? root.luminaDesign.color.surfaceMuted
                : "transparent"
        activeFocusOnTab: true
        border.width: activeFocus ? 2 : 0
        border.color: root.luminaDesign.color.primary

        Accessible.role: Accessible.MenuItem
        Accessible.name: root.actionLabel
        Accessible.focusable: true
        Accessible.focused: activeFocus
        Accessible.onPressAction: root.actionTriggered()

        Keys.onSpacePressed: event => {
            root.actionTriggered()
            event.accepted = true
        }

        Keys.onReturnPressed: event => {
            root.actionTriggered()
            event.accepted = true
        }

        Behavior on color {
            ColorAnimation {
                duration: root.luminaDesign.motion.effectsFast
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }

        Row {
            anchors {
                fill: parent
                leftMargin: root.luminaDesign.spacing.medium
                rightMargin: root.luminaDesign.spacing.medium
            }
            spacing: root.luminaDesign.spacing.medium

            DashboardIcon {
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                iconName: root.pinned
                    ? "list-remove-symbolic"
                    : "emblem-favorite-symbolic"
                fallbackSymbol: root.pinned ? "−" : "◆"
                iconColor: root.luminaDesign.color.onSurface
                iconSize: 18
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                    - root.luminaDesign.spacing.medium
                    - 24
                text: root.actionLabel
                color: root.luminaDesign.color.onSurface
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.labelMedium
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: actionMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.actionTriggered()
        }
    }
}

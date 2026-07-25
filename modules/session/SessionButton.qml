pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.session
import qs.stores.session

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: SessionMenuStore.activeOutputName
        === outputName

    implicitWidth: sessionLabel.implicitWidth + 20
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded ? luminaDesign.shape.full : luminaDesign.shape.medium
    color: expanded || sessionMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : "transparent"
    scale: sessionMouse.pressed
        ? 0.94
        : sessionMouse.containsMouse
            ? 1.03
            : 1.0
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary
    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: "Open session and layout controls"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate()

    Keys.onSpacePressed: event => {
        activate()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activate()
        event.accepted = true
    }

    function activate() {
        if (expanded) {
            SessionService.cancel()
            SessionMenuStore.close()
        } else {
            SessionMenuStore.openFor(outputName)
        }
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
        id: sessionLabel

        anchors.centerIn: parent
        text: "Session"
        color: root.expanded
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        font.pixelSize: root.luminaDesign.typography.labelMedium
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: sessionMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.focus = false
            root.activate()
        }
    }
}

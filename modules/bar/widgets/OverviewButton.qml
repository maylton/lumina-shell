import QtQuick
import qs.design
import qs.modules.control
import qs.services.niri

Rectangle {
    id: root

    property bool expressive: false

    readonly property var luminaDesign: Theme.luminaTokens

    implicitWidth: expressive
        ? luminaDesign.size.barTouchTarget
        : overviewLabel.implicitWidth + 20
    implicitHeight: expressive
        ? luminaDesign.size.barTouchTarget
        : luminaDesign.size.chipHeight
    radius: NiriService.overviewOpen
        ? luminaDesign.shape.full
        : luminaDesign.shape.medium
    scale: overviewMouse.pressed
        ? 0.94
        : overviewMouse.containsMouse
            ? 1.03
            : 1.0
    color: NiriService.overviewOpen || overviewMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : luminaDesign.color.surfaceMuted
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: NiriService.overviewOpen
        ? "Close Niri overview"
        : "Open Niri overview"
    Accessible.description: "Show workspaces and windows"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate()

    function activate() {
        NiriService.toggleOverview()
    }

    Keys.onSpacePressed: event => {
        activate()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activate()
        event.accepted = true
    }

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

    DashboardIcon {
        anchors.centerIn: parent
        visible: root.expressive
        iconName: "view-grid-symbolic"
        fallbackSymbol: "▦"
        iconColor: NiriService.overviewOpen
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        iconSize: 18
    }

    Text {
        id: overviewLabel
        anchors.centerIn: parent
        visible: !root.expressive
        text: NiriService.overviewOpen ? "Close overview" : "Overview"
        color: NiriService.overviewOpen
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        font.pixelSize: root.luminaDesign.typography.labelMedium
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: overviewMouse

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
        title: NiriService.overviewOpen
            ? "Close overview"
            : "Open overview"
        description: "Niri workspace and window overview"
        shown: overviewMouse.containsMouse
    }
}

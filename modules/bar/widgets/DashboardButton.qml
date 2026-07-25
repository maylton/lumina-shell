import QtQuick
import qs.design
import qs.modules.control
import qs.stores.control

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded:
        ControlCenterStore.activeOutputName === outputName

    implicitWidth: luminaDesign.size.barTouchTarget
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded
        ? luminaDesign.shape.large
        : luminaDesign.shape.full
    color: expanded || dashboardMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : "transparent"
    scale: dashboardMouse.pressed
        ? 0.92
        : dashboardMouse.containsMouse
            ? 1.04
            : 1
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: "Open Lumina dashboard"
    Accessible.description: "Quick controls and shell settings"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate()

    function activate() {
        if (expanded
            && ControlCenterStore.activePage === "dashboard") {
            ControlCenterStore.close()
        } else {
            ControlCenterStore.openFor(outputName, "dashboard")
        }
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
        customSource: Qt.resolvedUrl(
            "../../../assets/icons/rocket-symbolic.svg"
        )
        fallbackSymbol: "🚀"
        iconColor: root.expanded
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.primary
        iconSize: 18
    }

    MouseArea {
        id: dashboardMouse

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
        title: "Lumina dashboard"
        description: "Quick controls and shell settings"
        shown: dashboardMouse.containsMouse
    }
}

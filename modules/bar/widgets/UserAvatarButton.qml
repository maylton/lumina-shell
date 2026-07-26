import QtQuick
import qs.design
import qs.modules.control
import qs.stores.config
import qs.stores.control
import qs.stores.system
import qs.stores.shell

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded:
        ControlCenterStore.activeOutputName === outputName
    readonly property real circleDiameter:
        luminaDesign.size.barTouchTarget
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "dashboard",
            "showBackground",
            false
        )
    )
    readonly property string avatarDisplay: String(
        ConfigStore.widgetSetting(
            "dashboard",
            "avatarDisplay",
            "image"
        )
    )
    readonly property bool showUserName: Boolean(
        ConfigStore.widgetSetting(
            "dashboard",
            "showUserName",
            false
        )
    )
    readonly property string surfacePlacement: String(
        ConfigStore.widgetSetting(
            "dashboard",
            "surfacePlacement",
            "centered"
        )
    )

    width: showUserName
        ? avatarContent.implicitWidth
            + luminaDesign.spacing.barWidgetPadding * 2
        : circleDiameter
    height: circleDiameter
    implicitWidth: circleDiameter
    implicitHeight: circleDiameter
    radius: expanded || avatarMouse.pressed
        ? luminaDesign.shape.barIconActivated
        : circleDiameter / 2
    color: expanded || avatarMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : showBackground
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    scale: avatarMouse.pressed ? 0.96 : 1
    activeFocusOnTab: true
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: "Open dashboard for "
        + SystemInfoStore.displayName
    Accessible.description: "Quick controls and session actions"
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate(root.width / 2)

    function mappedAnchorX(localX) {
        const point = root.mapToItem(
            null,
            Number(localX),
            root.height / 2
        )
        return Number(point.x)
    }

    function activate(localX) {
        OverlayStore.prepareFor(
            "control",
            root.outputName,
            root.surfacePlacement,
            mappedAnchorX(localX)
        )

        if (expanded
            && ControlCenterStore.activePage === "dashboard") {
            ControlCenterStore.close()
        } else {
            ControlCenterStore.openFor(outputName, "dashboard")
        }
    }

    Keys.onSpacePressed: event => {
        root.activate(root.width / 2)
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.activate(root.width / 2)
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
        id: avatarContent

        anchors.centerIn: parent
        spacing: root.showUserName
            ? root.luminaDesign.spacing.barItemGap
            : 0

        UserAvatar {
            anchors.verticalCenter: parent.verticalCenter
            avatarSize: root.luminaDesign.size.barTouchTarget
            cornerRadius: avatarSize / 2
            useImage: root.avatarDisplay !== "initials"
            borderWidth: 0
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showUserName
            text: SystemInfoStore.displayName
            color: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            font.pixelSize:
                root.luminaDesign.typography.barSecondary
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: avatarMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            root.focus = false
            root.activate(mouse.x)
        }
    }

    TrayTooltip {
        anchorItem: root
        title: SystemInfoStore.displayName
        description: "Open Dashboard and session actions"
        shown: avatarMouse.containsMouse
    }
}

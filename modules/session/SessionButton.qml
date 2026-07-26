pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.i18n
import qs.services.session
import qs.stores.config
import qs.stores.session
import qs.stores.shell

Rectangle {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expanded: SessionMenuStore.activeOutputName
        === outputName
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "session",
            "showBackground",
            false
        )
    )
    readonly property bool showLabel: Boolean(
        ConfigStore.widgetSetting("session", "showLabel", false)
    )
    readonly property string surfacePlacement: String(
        ConfigStore.widgetSetting(
            "session",
            "surfacePlacement",
            "centered"
        )
    )

    implicitWidth: showLabel
        ? sessionContent.implicitWidth
            + luminaDesign.spacing.barWidgetPadding * 2
        : luminaDesign.size.barTouchTarget
    implicitHeight: luminaDesign.size.barTouchTarget
    radius: expanded
        ? luminaDesign.shape.full
        : luminaDesign.shape.barMedium
    color: expanded || sessionMouse.containsMouse
        ? luminaDesign.color.accentContainer
        : showBackground
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    scale: sessionMouse.pressed
        ? 0.96
        : 1.0
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary
    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: I18n.tr(
        "bar.session.accessibleName",
        "Open session and layout controls"
    )
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activate(root.width / 2)

    Keys.onSpacePressed: event => {
        root.activate(root.width / 2)
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.activate(root.width / 2)
        event.accepted = true
    }

    function mappedAnchorGeometry(localX) {
        const top = root.mapToItem(
            null,
            Number(localX),
            0
        )
        const bottom = root.mapToItem(
            null,
            Number(localX),
            root.height
        )

        return {
            x: Number(top.x),
            top: Number(top.y),
            bottom: Number(bottom.y)
        }
    }

    function activate(localX) {
        const anchor = mappedAnchorGeometry(localX)

        BarPanelCoordinator.requestToggle(
            "session",
            root.outputName,
            root.surfacePlacement,
            anchor.x,
            anchor.top,
            anchor.bottom
        )
    }

    Connections {
        target: BarPanelCoordinator

        function onOpenRequested(
            panelId,
            outputName,
            placement,
            anchorX,
            anchorTop,
            anchorBottom
        ) {
            if (panelId !== "session" || outputName !== root.outputName)
                return

            OverlayStore.prepareFor(
                "session",
                root.outputName,
                placement,
                anchorX,
                anchorTop,
                anchorBottom
            )
            SessionMenuStore.openFor(root.outputName)
        }

        function onCloseRequested(panelId, outputName) {
            if (panelId !== "session" || outputName !== root.outputName)
                return

            SessionService.cancel()
            if (root.expanded)
                SessionMenuStore.close()
            else
                BarPanelCoordinator.reportClosed("session", root.outputName)
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
        id: sessionContent

        anchors.centerIn: parent
        spacing: root.showLabel
            ? root.luminaDesign.spacing.barItemGap
            : 0

        DashboardIcon {
            anchors.verticalCenter: parent.verticalCenter
            iconName: "system-shutdown-symbolic"
            fallbackSymbol: "⏻"
            iconColor: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            iconSize: root.luminaDesign.size.barIcon
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showLabel
            text: I18n.tr("bar.session.label", "Session")
            color: root.expanded
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            font.pixelSize:
                root.luminaDesign.typography.barSecondary
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: sessionMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            root.focus = false
            root.activate(mouse.x)
        }
    }
}

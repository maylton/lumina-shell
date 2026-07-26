pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.i18n

Rectangle {
    id: root

    required property string deviceName
    required property string address
    property bool connected: false
    property bool paired: false
    property bool busy: false
    property string primaryLabel: ""
    property string primaryIcon: ""
    property bool showForget: false

    signal primaryActivated()
    signal forgetActivated()

    readonly property var luminaDesign: Theme.luminaTokens

    implicitWidth: 360
    implicitHeight: 64
    radius: luminaDesign.shape.large
    color: primaryMouse.containsMouse || forgetMouse.containsMouse
        ? luminaDesign.color.surfaceMuted
        : "transparent"
    opacity: busy ? 0.55 : 1

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

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40
            radius: root.luminaDesign.shape.full
            color: root.connected
                ? root.luminaDesign.color.accentContainer
                : root.luminaDesign.color.surfaceMuted

            DashboardIcon {
                anchors.centerIn: parent
                iconName: root.connected
                    ? "bluetooth-active-symbolic"
                    : "bluetooth-symbolic"
                fallbackSymbol: "ᛒ"
                iconColor: root.connected
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.onSurface
                iconSize: 19
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(
                80,
                parent.width
                    - 40
                    - primaryButton.width
                    - forgetButton.width
                    - parent.spacing * 3
            )
            spacing: 2

            Text {
                width: parent.width
                text: root.deviceName
                color: root.luminaDesign.color.onSurface
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.bodyMedium
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: root.address
                color: root.luminaDesign.color.textMuted
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.labelSmall
            }
        }

        Rectangle {
            id: primaryButton

            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(78, primaryText.implicitWidth + 24)
            height: 36
            radius: root.luminaDesign.shape.full
            color: primaryMouse.containsMouse
                ? root.luminaDesign.color.accentContainer
                : root.luminaDesign.color.surfaceMuted
            activeFocusOnTab: !root.busy
            border.width: activeFocus ? 2 : 0
            border.color: root.luminaDesign.color.primary

            Accessible.role: Accessible.Button
            Accessible.name: root.primaryLabel + " " + root.deviceName
            Accessible.focusable: !root.busy
            Accessible.focused: activeFocus
            Accessible.onPressAction: root.primaryActivated()

            Keys.onSpacePressed: event => {
                root.primaryActivated()
                event.accepted = true
            }
            Keys.onReturnPressed: event => {
                root.primaryActivated()
                event.accepted = true
            }

            Text {
                id: primaryText

                anchors.centerIn: parent
                text: root.primaryLabel
                color: primaryMouse.containsMouse
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.labelMedium
                font.weight: Font.DemiBold
            }

            MouseArea {
                id: primaryMouse

                anchors.fill: parent
                hoverEnabled: true
                enabled: !root.busy
                cursorShape: enabled
                    ? Qt.PointingHandCursor
                    : Qt.ArrowCursor
                onClicked: root.primaryActivated()
            }
        }

        Rectangle {
            id: forgetButton

            anchors.verticalCenter: parent.verticalCenter
            visible: root.showForget
            width: visible ? 36 : 0
            height: 36
            radius: root.luminaDesign.shape.full
            color: forgetMouse.containsMouse
                ? root.luminaDesign.color.errorContainer
                : "transparent"
            activeFocusOnTab: visible && !root.busy
            border.width: activeFocus ? 2 : 0
            border.color: root.luminaDesign.color.primary

            Accessible.role: Accessible.Button
            Accessible.name: I18n.tr(
                "bar.bluetooth.forgetNamed",
                "Forget %1",
                [root.deviceName]
            )
            Accessible.focusable: visible && !root.busy
            Accessible.focused: activeFocus
            Accessible.onPressAction: root.forgetActivated()

            Keys.onSpacePressed: event => {
                root.forgetActivated()
                event.accepted = true
            }
            Keys.onReturnPressed: event => {
                root.forgetActivated()
                event.accepted = true
            }

            DashboardIcon {
                anchors.centerIn: parent
                iconName: "edit-delete-symbolic"
                fallbackSymbol: "×"
                iconColor: forgetMouse.containsMouse
                    ? root.luminaDesign.color.onErrorContainer
                    : root.luminaDesign.color.textMuted
                iconSize: 17
            }

            MouseArea {
                id: forgetMouse

                anchors.fill: parent
                hoverEnabled: true
                enabled: root.showForget && !root.busy
                cursorShape: enabled
                    ? Qt.PointingHandCursor
                    : Qt.ArrowCursor
                onClicked: root.forgetActivated()
            }
        }
    }
}

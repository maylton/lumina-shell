pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.i18n
import "../../../services/i18n/SettingsStrings.js" as SettingsStrings

Rectangle {
    id: root

    required property string title
    property string description: ""
    property string iconName: ""
    property string symbol: ""
    property string availabilityText: ""
    property bool available: true
    property bool restartRequired: false
    property real controlWidth: 140
    default property alias controlData: controlHost.data

    signal activated

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool grouped:
        parent
            && typeof parent.settingsGroup !== "undefined"
            && parent.settingsGroup
    readonly property bool lastGroupedItem:
        !grouped
            || !parent
            || parent.children.length === 0
            || parent.children[parent.children.length - 1] === root

    implicitHeight: Math.max(68, contentRow.implicitHeight + 24)
    radius: grouped
        ? luminaDesign.shape.none
        : rowMouse.pressed
            ? luminaDesign.shape.medium
            : luminaDesign.shape.large
    color: grouped
        ? "transparent"
        : rowMouse.pressed
            ? Qt.lighter(luminaDesign.color.surfaceMuted, 1.12)
            : rowMouse.containsMouse || activeFocus
                ? Qt.lighter(luminaDesign.color.surfaceMuted, 1.06)
                : luminaDesign.color.surfaceMuted
    opacity: enabled && available ? 1 : 0.56
    scale: rowMouse.pressed && !grouped ? 0.99 : 1
    activeFocusOnTab: available
    border.width: activeFocus && !grouped ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: title
    Accessible.description: description
        + (availabilityText ? ". " + availabilityText : "")
        + (restartRequired
            ? ". " + SettingsStrings.text(
                I18n.locale,
                "restartRequired"
            )
            : "")
    Accessible.focusable: available
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activated()

    function releasePointerFocus() {
        root.forceActiveFocus()
        root.focus = false
    }

    function activateFromPointer() {
        releasePointerFocus()
        root.activated()
    }

    Keys.onSpacePressed: event => {
        if (root.available)
            root.activated()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        if (root.available)
            root.activated()
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

    Behavior on opacity {
        NumberAnimation {
            duration: root.luminaDesign.motion.effectsDefault
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Rectangle {
        id: groupedStateLayer

        anchors {
            fill: parent
            leftMargin: 4
            rightMargin: 4
            topMargin: 3
            bottomMargin: 3
        }

        visible: root.grouped
        radius: root.luminaDesign.shape.medium
        color: root.activeFocus
            ? root.luminaDesign.color.primary
            : root.luminaDesign.color.onSurface
        opacity: rowMouse.pressed
            ? 0.10
            : rowMouse.containsMouse || root.activeFocus
                ? 0.06
                : 0
        border.width: root.activeFocus ? 2 : 0
        border.color: root.luminaDesign.color.primary

        Behavior on color {
            ColorAnimation {
                duration: root.luminaDesign.motion.effectsFast
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.luminaDesign.motion.effectsFast
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }
    }

    Row {
        id: contentRow

        z: 1
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 12
        }

        spacing: root.luminaDesign.spacing.controlItemGap

        DashboardIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.iconName.length > 0 || root.symbol.length > 0
            width: visible ? 28 : 0
            height: 28
            iconName: root.iconName
            fallbackSymbol: root.symbol
            iconColor: root.luminaDesign.color.primary
            iconSize: 18
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
                - (contentRow.children[0].visible
                    ? contentRow.children[0].width + parent.spacing
                    : 0)
                - controlHost.width
                - parent.spacing
            spacing: 3

            Row {
                width: parent.width
                spacing: root.luminaDesign.spacing.small

                Text {
                    width: parent.width
                        - restartBadge.width
                        - parent.spacing
                    text: root.title
                    color: root.luminaDesign.color.onSurface
                    elide: Text.ElideRight
                    font.pixelSize:
                        root.luminaDesign.typography.bodyMedium
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    id: restartBadge

                    visible: root.restartRequired
                    width: visible ? restartText.implicitWidth + 12 : 0
                    height: 22
                    radius: root.luminaDesign.shape.full
                    color: root.luminaDesign.color.accentContainer

                    Text {
                        id: restartText

                        anchors.centerIn: parent
                        text: SettingsStrings.text(
                            I18n.locale,
                            "restart"
                        )
                        color:
                            root.luminaDesign.color.onAccentContainer
                        font.pixelSize:
                            root.luminaDesign.typography.labelSmall
                        font.weight: Font.DemiBold
                    }
                }
            }

            Text {
                width: parent.width
                visible: text.length > 0
                text: root.available
                    ? root.description
                    : root.availabilityText || root.description
                color: root.luminaDesign.color.textMuted
                wrapMode: Text.WordWrap
                font.pixelSize: root.luminaDesign.typography.labelSmall
            }
        }

        Item {
            id: controlHost

            anchors.verticalCenter: parent.verticalCenter
            width: root.controlWidth
            height: Math.max(36, childrenRect.height)
        }
    }

    MouseArea {
        id: rowMouse

        anchors.fill: parent
        z: 0
        enabled: root.available
        hoverEnabled: true
        cursorShape: root.available
            ? Qt.PointingHandCursor
            : Qt.ForbiddenCursor
        onClicked: root.activateFromPointer()
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 12
            rightMargin: 12
        }

        z: 2
        visible: root.grouped && !root.lastGroupedItem
        height: 1
        color: root.luminaDesign.color.divider
    }
}

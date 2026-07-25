import QtQuick
import qs.design

Rectangle {
    id: root

    required property string widgetTitle
    property string description: ""
    property bool checked: true
    property bool canMoveUp: true
    property bool canMoveDown: true

    signal toggled(bool checked)
    signal moveUp
    signal moveDown

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

    implicitHeight: 68
    radius: grouped
        ? luminaDesign.shape.none
        : luminaDesign.shape.large
    color: grouped
        ? "transparent"
        : luminaDesign.color.surfaceMuted

    Accessible.role: Accessible.Grouping
    Accessible.name: widgetTitle
    Accessible.description: description

    Column {
        anchors {
            left: parent.left
            right: actions.left
            verticalCenter: parent.verticalCenter
            leftMargin: 14
            rightMargin: root.luminaDesign.spacing.medium
        }
        spacing: 3

        Text {
            width: parent.width
            text: root.widgetTitle
            color: root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.bodyMedium
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: root.description
            color: root.luminaDesign.color.textMuted
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.labelSmall
        }
    }

    Row {
        id: actions

        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        spacing: root.luminaDesign.spacing.small

        Rectangle {
            id: visibilityButton

            width: visibilityText.implicitWidth + 18
            height: 36
            radius: root.luminaDesign.shape.full
            color: root.checked
                ? root.luminaDesign.color.accentContainer
                : root.luminaDesign.color.surfaceBase
            activeFocusOnTab: true
            border.width: activeFocus ? 2 : 1
            border.color: activeFocus
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.outline

            Accessible.role: Accessible.CheckBox
            Accessible.name: "Show " + root.widgetTitle
            Accessible.checked: root.checked
            Accessible.focusable: true
            Accessible.focused: activeFocus
            Accessible.onPressAction: root.toggled(!root.checked)

            Keys.onSpacePressed: event => {
                root.toggled(!root.checked)
                event.accepted = true
            }

            Keys.onReturnPressed: event => {
                root.toggled(!root.checked)
                event.accepted = true
            }

            Text {
                id: visibilityText

                anchors.centerIn: parent
                text: root.checked ? "Shown" : "Hidden"
                color: root.checked
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.labelSmall
                font.weight: Font.DemiBold
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    visibilityButton.forceActiveFocus(
                        Qt.MouseFocusReason
                    )
                    root.toggled(!root.checked)
                }
            }
        }

        Rectangle {
            id: upButton

            width: 36
            height: 36
            radius: upMouse.pressed
                ? Math.min(
                    width / 2,
                    root.luminaDesign.shape.controlIconActivated
                        * width / 44
                )
                : width / 2
            color: root.luminaDesign.color.surfaceBase
            opacity: root.canMoveUp ? 1 : 0.4
            activeFocusOnTab: root.canMoveUp
            border.width: activeFocus ? 2 : 1
            border.color: activeFocus
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.outline

            Behavior on radius {
                NumberAnimation {
                    duration:
                        root.luminaDesign.motion.spatialFast
                    easing.type:
                        root.luminaDesign.motion.spatialEasing
                    easing.overshoot:
                        root.luminaDesign.motion.spatialOvershoot
                }
            }

            Accessible.role: Accessible.Button
            Accessible.name: "Move " + root.widgetTitle + " up"
            Accessible.focusable: root.canMoveUp
            Accessible.focused: activeFocus
            Accessible.onPressAction: {
                if (root.canMoveUp)
                    root.moveUp()
            }

            Keys.onSpacePressed: event => {
                if (root.canMoveUp)
                    root.moveUp()
                event.accepted = true
            }

            Keys.onReturnPressed: event => {
                if (root.canMoveUp)
                    root.moveUp()
                event.accepted = true
            }

            Text {
                anchors.centerIn: parent
                text: "↑"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: 17
                font.weight: Font.Bold
            }

            MouseArea {
                id: upMouse

                anchors.fill: parent
                enabled: root.canMoveUp
                cursorShape: enabled
                    ? Qt.PointingHandCursor
                    : Qt.ArrowCursor
                onClicked: {
                    upButton.forceActiveFocus(Qt.MouseFocusReason)
                    root.moveUp()
                }
            }
        }

        Rectangle {
            id: downButton

            width: 36
            height: 36
            radius: downMouse.pressed
                ? Math.min(
                    width / 2,
                    root.luminaDesign.shape.controlIconActivated
                        * width / 44
                )
                : width / 2
            color: root.luminaDesign.color.surfaceBase
            opacity: root.canMoveDown ? 1 : 0.4
            activeFocusOnTab: root.canMoveDown
            border.width: activeFocus ? 2 : 1
            border.color: activeFocus
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.outline

            Behavior on radius {
                NumberAnimation {
                    duration:
                        root.luminaDesign.motion.spatialFast
                    easing.type:
                        root.luminaDesign.motion.spatialEasing
                    easing.overshoot:
                        root.luminaDesign.motion.spatialOvershoot
                }
            }

            Accessible.role: Accessible.Button
            Accessible.name: "Move " + root.widgetTitle + " down"
            Accessible.focusable: root.canMoveDown
            Accessible.focused: activeFocus
            Accessible.onPressAction: {
                if (root.canMoveDown)
                    root.moveDown()
            }

            Keys.onSpacePressed: event => {
                if (root.canMoveDown)
                    root.moveDown()
                event.accepted = true
            }

            Keys.onReturnPressed: event => {
                if (root.canMoveDown)
                    root.moveDown()
                event.accepted = true
            }

            Text {
                anchors.centerIn: parent
                text: "↓"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: 17
                font.weight: Font.Bold
            }

            MouseArea {
                id: downMouse

                anchors.fill: parent
                enabled: root.canMoveDown
                cursorShape: enabled
                    ? Qt.PointingHandCursor
                    : Qt.ArrowCursor
                onClicked: {
                    downButton.forceActiveFocus(Qt.MouseFocusReason)
                    root.moveDown()
                }
            }
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 12
            rightMargin: 12
        }

        visible: root.grouped && !root.lastGroupedItem
        height: 1
        color: root.luminaDesign.color.divider
    }
}

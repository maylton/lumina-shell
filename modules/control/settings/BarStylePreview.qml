import QtQuick
import qs.design

Rectangle {
    id: root

    required property string label
    required property string visualStyle
    property bool selected: false

    signal activated

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool expressive: visualStyle === "expressive"

    implicitHeight: 126
    radius: selected
        ? luminaDesign.shape.extraLargeIncreased
        : luminaDesign.shape.extraLarge
    color: selected
        ? luminaDesign.color.accentContainer
        : luminaDesign.color.surfaceMuted
    border.width: selected || activeFocus ? 2 : 1
    border.color: selected || activeFocus
        ? luminaDesign.color.primary
        : luminaDesign.color.outline
    activeFocusOnTab: true
    scale: previewMouse.pressed ? 0.98 : 1

    Accessible.role: Accessible.RadioButton
    Accessible.name: label + " bar style"
    Accessible.checked: selected
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activated()

    Keys.onSpacePressed: event => {
        activated()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        activated()
        event.accepted = true
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

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }
        height: 62
        radius: root.luminaDesign.shape.large
        color: root.luminaDesign.color.surfaceBase

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: root.expressive ? 0 : 8
            }
            height: 30
            radius: root.expressive
                ? 0
                : root.luminaDesign.shape.medium
            color: root.luminaDesign.color.surfaceContainer
            border.width: root.expressive ? 0 : 1
            border.color: root.luminaDesign.color.outline

            Row {
                anchors.centerIn: parent
                spacing: 5

                Repeater {
                    model: root.expressive ? [12, 28, 12, 36] : [26, 18, 22]

                    Rectangle {
                        required property var modelData
                        required property int index

                        width: Number(modelData)
                        height: 12
                        radius: index === 1 && root.expressive
                            ? root.luminaDesign.shape.full
                            : root.luminaDesign.shape.small
                        color: index === 1
                            ? root.luminaDesign.color.accentContainer
                            : root.luminaDesign.color.textMuted
                        opacity: index === 1 ? 1 : 0.55
                    }
                }
            }
        }
    }

    Text {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 14
        }
        text: root.label + (root.selected ? "  ✓" : "")
        color: root.selected
            ? root.luminaDesign.color.onAccentContainer
            : root.luminaDesign.color.onSurface
        font.pixelSize: root.luminaDesign.typography.labelMedium
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: previewMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            root.activated()
        }
    }
}

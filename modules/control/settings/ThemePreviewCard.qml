pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Rectangle {
    id: root

    required property string label
    property string mode: "dark"
    property bool selected: false

    signal activated

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var previewPalette: Theme.previewPalette(mode)
    readonly property color previewSurface:
        previewPalette.surfaceBase
    readonly property color previewContainer:
        previewPalette.surfaceMuted
    readonly property color previewText:
        previewPalette.onSurface
    readonly property color previewPrimary:
        previewPalette.primary

    implicitHeight: 154
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
    Accessible.name: label + " theme"
    Accessible.checked: selected
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: root.activated()

    function activateFromPointer() {
        root.forceActiveFocus()
        root.focus = false
        root.activated()
    }

    Keys.onSpacePressed: event => {
        root.activated()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        root.activated()
        event.accepted = true
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.spatialDefault
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Rectangle {
        anchors {
            fill: parent
            margins: 8
            bottomMargin: 34
        }

        radius: root.luminaDesign.shape.large
        color: root.previewSurface

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 10
            }

            height: 18
            radius: 8
            color: root.previewContainer

            Row {
                anchors {
                    fill: parent
                    margins: 4
                }
                spacing: 4

                Repeater {
                    model: 4

                    Rectangle {
                        required property int index

                        width: 20 + index * 5
                        height: 10
                        radius: 5
                        color: index === 0
                            ? root.previewPrimary
                            : root.previewText
                        opacity: index === 0 ? 1 : 0.4
                    }
                }
            }
        }

        Row {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 10
            }

            height: 58
            spacing: 8

            Rectangle {
                width: parent.width * 0.35
                height: parent.height
                radius: root.luminaDesign.shape.medium
                color: root.previewContainer
            }

            Rectangle {
                width: parent.width * 0.65 - parent.spacing
                height: parent.height
                radius: root.luminaDesign.shape.medium
                color: root.previewContainer

                Column {
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    spacing: 6

                    Rectangle {
                        width: parent.width * 0.8
                        height: 8
                        radius: 4
                        color: root.previewText
                        opacity: 0.7
                    }

                    Rectangle {
                        width: parent.width * 0.55
                        height: 8
                        radius: 4
                        color: root.previewText
                        opacity: 0.35
                    }
                }
            }
        }
    }

    Text {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 10
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
        onClicked: root.activateFromPointer()
    }
}

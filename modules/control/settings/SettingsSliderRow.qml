pragma ComponentBehavior: Bound

import QtQuick
import qs.design

SettingsRow {
    id: root

    property real value: 0
    property real from: 0
    property real to: 1
    property real stepSize: 0.1
    property string valueLabel: Math.round(value * 100) + "%"

    signal valueEdited(real value)

    controlWidth: 220
    Accessible.role: Accessible.Slider
    Accessible.description: description + ". Current value " + valueLabel

    function clampValue(candidate) {
        return Math.max(from, Math.min(to, candidate))
    }

    function step(direction) {
        valueEdited(clampValue(value + stepSize * direction))
    }

    onActivated: step(1)

    Keys.onLeftPressed: event => {
        step(-1)
        event.accepted = true
    }

    Keys.onRightPressed: event => {
        step(1)
        event.accepted = true
    }

    Row {
        anchors.fill: parent
        spacing: root.luminaDesign.spacing.medium

        Rectangle {
            id: track

            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - valueText.width - parent.spacing
            height: 16
            radius: root.luminaDesign.shape.full
            color: root.grouped
                ? root.luminaDesign.color.surfaceBase
                : root.luminaDesign.color.surfaceMuted

            Rectangle {
                width: parent.width * (
                    (root.value - root.from)
                    / Math.max(0.001, root.to - root.from)
                )
                height: parent.height
                radius: parent.radius
                color: root.luminaDesign.color.primary
            }

            Rectangle {
                width: 6
                height: 28
                radius: root.luminaDesign.shape.full
                x: Math.max(
                    0,
                    Math.min(
                        parent.width - width,
                        parent.width * (
                            (root.value - root.from)
                            / Math.max(0.001, root.to - root.from)
                        ) - width / 2
                    )
                )
                anchors.verticalCenter: parent.verticalCenter
                color: root.luminaDesign.color.primary
            }

            MouseArea {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                height: 36
                acceptedButtons: Qt.LeftButton
                onPressed: mouse => updateValue(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed)
                        updateValue(mouse.x)
                }

                function updateValue(position) {
                    const ratio = Math.max(
                        0,
                        Math.min(1, position / width)
                    )
                    const raw = root.from
                        + ratio * (root.to - root.from)
                    const stepped = Math.round(
                        (raw - root.from) / root.stepSize
                    ) * root.stepSize + root.from
                    root.valueEdited(root.clampValue(stepped))
                }
            }
        }

        Text {
            id: valueText

            anchors.verticalCenter: parent.verticalCenter
            width: 52
            text: root.valueLabel
            horizontalAlignment: Text.AlignRight
            color: root.luminaDesign.color.primary
            font.pixelSize: root.luminaDesign.typography.labelMedium
            font.weight: Font.DemiBold
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import "../SliderGeometry.js" as Geometry

SettingsRow {
    id: root

    property real value: 0
    property real from: 0
    property real to: 1
    property real stepSize: 0.1
    property string valueLabel: Math.round(value * 100) + "%"

    signal valueEdited(real value)

    readonly property real normalizedValue:
        Geometry.normalizedValue(value, from, to)
    readonly property var sliderTokens:
        luminaDesign.slider

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

        Item {
            id: track

            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - valueText.width - parent.spacing
            height: root.sliderTokens.handleHeight

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: Geometry.activeWidth(
                    track.width,
                    handle.width,
                    root.sliderTokens.handleGap,
                    root.normalizedValue
                )
                height: root.sliderTokens.trackHeight
                radius: root.luminaDesign.shape.full
                color: root.luminaDesign.color.primary
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: Geometry.inactiveX(
                    track.width,
                    handle.width,
                    root.sliderTokens.handleGap,
                    root.normalizedValue
                )
                width: Geometry.inactiveWidth(
                    track.width,
                    handle.width,
                    root.sliderTokens.handleGap,
                    root.normalizedValue
                )
                height: root.sliderTokens.trackHeight
                radius: root.luminaDesign.shape.full
                color: root.grouped
                    ? root.luminaDesign.color.surfaceBase
                    : root.luminaDesign.color.surfaceMuted
            }

            Rectangle {
                id: handle

                width: root.sliderTokens.handleWidth
                height: root.sliderTokens.handleHeight
                radius: root.luminaDesign.shape.full
                x: Geometry.handleX(
                    track.width,
                    width,
                    root.normalizedValue
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
                enabled: root.available
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

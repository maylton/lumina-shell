pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import ".." as ControlComponents
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

    controlWidth: 220
    Accessible.role: Accessible.Slider
    Accessible.description: description + ". Current value " + valueLabel

    function clampValue(candidate) {
        return Math.max(from, Math.min(to, candidate))
    }

    function step(direction) {
        if (!available)
            return

        valueEdited(clampValue(value + stepSize * direction))
    }

    function editNormalized(normalized) {
        if (!available)
            return

        const raw = from + normalized * (to - from)
        const stepped = Math.round(
            (raw - from) / stepSize
        ) * stepSize + from

        valueEdited(clampValue(stepped))
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

        ControlComponents.MaterialSlider {
            id: slider

            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - valueText.width - parent.spacing
            height: implicitHeight
            value: root.normalizedValue
            available: root.available
            activeColor: root.available
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.outline
            inactiveColor: root.grouped
                ? root.luminaDesign.color.surfaceBase
                : root.luminaDesign.color.surfaceMuted
            handleColor: root.available
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.outline

            onInteractionStarted:
                root.forceActiveFocus(Qt.MouseFocusReason)
            onValueRequested: normalized =>
                root.editNormalized(normalized)
        }

        Text {
            id: valueText

            anchors.verticalCenter: parent.verticalCenter
            width: 52
            text: root.valueLabel
            horizontalAlignment: Text.AlignRight
            color: root.available
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.textMuted
            font.pixelSize: root.luminaDesign.typography.labelMedium
            font.weight: Font.DemiBold
        }
    }
}

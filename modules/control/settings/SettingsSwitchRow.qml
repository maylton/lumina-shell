pragma ComponentBehavior: Bound

import QtQuick
import qs.design

SettingsRow {
    id: root

    property bool checked: false

    signal toggled(bool checked)

    controlWidth: 58

    Accessible.role: Accessible.CheckBox
    Accessible.checked: checked
    onActivated: {
        if (available)
            toggled(!checked)
    }

    Rectangle {
        anchors.centerIn: parent
        width: 52
        height: 32
        radius: root.luminaDesign.shape.full
        color: root.checked
            ? root.luminaDesign.color.primary
            : root.luminaDesign.color.surfaceMuted
        border.width: root.checked ? 0 : 1
        border.color: root.luminaDesign.color.outline

        Behavior on color {
            ColorAnimation {
                duration: root.luminaDesign.motion.effectsDefault
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }

        Rectangle {
            width: root.checked ? 24 : 16
            height: width
            radius: root.luminaDesign.shape.full
            x: root.checked
                ? parent.width - width - 3
                : 8
            anchors.verticalCenter: parent.verticalCenter
            color: root.checked
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.textMuted

            Behavior on x {
                NumberAnimation {
                    duration:
                        root.luminaDesign.motion.spatialDefault
                    easing.type:
                        root.luminaDesign.motion.spatialEasing
                    easing.overshoot:
                        root.luminaDesign.motion.spatialOvershoot
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: root.luminaDesign.motion.spatialFast
                    easing.type:
                        root.luminaDesign.motion.spatialEasing
                    easing.overshoot:
                        root.luminaDesign.motion.spatialOvershoot
                }
            }
        }
    }
}

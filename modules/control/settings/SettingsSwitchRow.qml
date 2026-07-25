pragma ComponentBehavior: Bound

import QtQuick
import qs.design

SettingsRow {
    id: root

    property bool checked: false

    signal toggled(bool checked)

    controlWidth: 52

    Accessible.role: Accessible.CheckBox
    Accessible.checked: checked
    onActivated: {
        if (available)
            toggled(!checked)
    }

    Rectangle {
        anchors.centerIn: parent
        width: 48
        height: 28
        radius: 14
        color: root.checked
            ? root.luminaDesign.color.primary
            : root.luminaDesign.color.surfaceMuted
        border.width: root.checked ? 0 : 1
        border.color: root.luminaDesign.color.outline

        Behavior on color {
            ColorAnimation {
                duration: root.luminaDesign.motion.fast
            }
        }

        Rectangle {
            width: root.checked ? 22 : 18
            height: width
            radius: width / 2
            x: root.checked
                ? parent.width - width - 3
                : 4
            anchors.verticalCenter: parent.verticalCenter
            color: root.checked
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.textMuted

            Behavior on x {
                NumberAnimation {
                    duration: root.luminaDesign.motion.medium
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: root.luminaDesign.motion.fast
                }
            }
        }
    }
}

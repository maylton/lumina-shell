pragma ComponentBehavior: Bound

import QtQuick
import qs.design

Row {
    id: root

    required property var options
    property string currentValue: ""

    signal selected(string value)

    readonly property var luminaDesign: Theme.luminaTokens

    spacing: luminaDesign.spacing.small

    Repeater {
        model: root.options

        delegate: Rectangle {
            id: segment

            required property var modelData
            readonly property bool selected:
                String(modelData.value) === root.currentValue

            width: (
                root.width - root.spacing
                    * Math.max(0, root.options.length - 1)
            ) / Math.max(1, root.options.length)
            height: root.height
            radius: selected
                ? root.luminaDesign.shape.full
                : root.luminaDesign.shape.large
            color: selected
                ? root.luminaDesign.color.accentContainer
                : root.luminaDesign.color.surfaceMuted
            activeFocusOnTab: true
            border.width: activeFocus ? 2 : 1
            border.color: activeFocus
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.outline

            Behavior on radius {
                NumberAnimation {
                    duration:
                        root.luminaDesign.motion.spatialDefault
                    easing.type:
                        root.luminaDesign.motion.spatialEasing
                    easing.overshoot:
                        root.luminaDesign.motion.spatialOvershoot
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration:
                        root.luminaDesign.motion.effectsDefault
                    easing.type:
                        root.luminaDesign.motion.effectsEasing
                }
            }

            Accessible.role: Accessible.RadioButton
            Accessible.name: String(modelData.label)
            Accessible.checked: selected
            Accessible.focusable: true
            Accessible.focused: activeFocus
            Accessible.onPressAction:
                root.selected(String(modelData.value))

            Keys.onSpacePressed: event => {
                root.selected(String(modelData.value))
                event.accepted = true
            }

            Keys.onReturnPressed: event => {
                root.selected(String(modelData.value))
                event.accepted = true
            }

            Text {
                anchors.centerIn: parent
                text: String(segment.modelData.label)
                color: segment.selected
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.onSurface
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
                font.weight: Font.DemiBold
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    segment.forceActiveFocus(Qt.MouseFocusReason)
                    root.selected(String(segment.modelData.value))
                }
            }
        }
    }
}

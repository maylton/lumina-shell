pragma ComponentBehavior: Bound

import QtQuick
import qs.design

SettingsRow {
    id: root

    property var options: []
    property string currentValue: ""

    signal selected(string value)

    controlWidth: 170
    Accessible.role: Accessible.ComboBox
    Accessible.description:
        description + ". Current value " + currentLabel()

    function currentIndex() {
        for (var i = 0; i < options.length; ++i) {
            if (String(options[i].value) === currentValue)
                return i
        }

        return -1
    }

    function currentLabel() {
        const index = currentIndex()
        return index >= 0
            ? String(options[index].label)
            : currentValue
    }

    function selectOffset(offset) {
        if (!available || options.length === 0)
            return

        const current = currentIndex()
        const next = (
            (current < 0 ? 0 : current) + offset + options.length
        ) % options.length
        selected(String(options[next].value))
    }

    onActivated: selectOffset(1)

    Keys.onLeftPressed: event => {
        selectOffset(-1)
        event.accepted = true
    }

    Keys.onRightPressed: event => {
        selectOffset(1)
        event.accepted = true
    }

    Rectangle {
        anchors.fill: parent
        radius: root.luminaDesign.shape.full
        color: root.luminaDesign.color.surfaceMuted
        border.width: 1
        border.color: root.activeFocus
            ? root.luminaDesign.color.primary
            : root.luminaDesign.color.outline

        Row {
            anchors {
                fill: parent
                leftMargin: root.luminaDesign.spacing.large
                rightMargin: root.luminaDesign.spacing.large
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - arrow.implicitWidth
                text: root.currentLabel()
                color: root.luminaDesign.color.onSurface
                elide: Text.ElideRight
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
                font.weight: Font.DemiBold
            }

            Text {
                id: arrow

                anchors.verticalCenter: parent.verticalCenter
                text: "›"
                color: root.luminaDesign.color.primary
                font.pixelSize: 18
                font.weight: Font.Bold
            }
        }
    }
}

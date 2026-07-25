pragma ComponentBehavior: Bound

import QtQuick
import qs.design

SettingsRow {
    id: root

    property string text: ""
    property string placeholderText: ""
    property int maximumLength: 128
    property bool readOnly: false

    signal accepted(string value)

    controlWidth: 240
    Accessible.role: Accessible.EditableText
    Accessible.value: editor.text

    Rectangle {
        anchors.fill: parent
        radius: root.luminaDesign.shape.full
        color: root.grouped
            ? root.luminaDesign.color.surfaceBase
            : root.luminaDesign.color.surfaceMuted
        border.width: editor.activeFocus ? 2 : 1
        border.color: editor.activeFocus
            ? root.luminaDesign.color.primary
            : root.luminaDesign.color.outline

        TextInput {
            id: editor

            anchors {
                fill: parent
                leftMargin: root.luminaDesign.spacing.large
                rightMargin: root.luminaDesign.spacing.large
            }

            verticalAlignment: TextInput.AlignVCenter
            text: root.text
            readOnly: root.readOnly || !root.available
            maximumLength: root.maximumLength
            selectByMouse: true
            clip: true
            color: root.luminaDesign.color.onSurface
            selectionColor: root.luminaDesign.color.accentContainer
            selectedTextColor: root.luminaDesign.color.onAccentContainer
            font.pixelSize: root.luminaDesign.typography.labelMedium

            onEditingFinished: root.accepted(text.trim())
            Keys.onReturnPressed: event => {
                root.accepted(text.trim())
                event.accepted = true
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: root.luminaDesign.spacing.large
                verticalCenter: parent.verticalCenter
            }

            visible: editor.text.length === 0
                && !editor.activeFocus
                && root.placeholderText.length > 0
            text: root.placeholderText
            color: root.luminaDesign.color.textMuted
            font.pixelSize: root.luminaDesign.typography.labelMedium
        }
    }

    onTextChanged: {
        if (!editor.activeFocus && editor.text !== text)
            editor.text = text
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.design
import "SettingsDropdownLogic.js" as DropdownLogic

SettingsRow {
    id: root

    property var options: []
    property string currentValue: ""

    signal selected(string value)

    controlWidth: 170
    Accessible.role: Accessible.ComboBox
    Accessible.description:
        description + ". Current value " + currentLabel()

    readonly property real popupHeight:
        options.length
            * luminaDesign.size.settingsMenuItemHeight
            + Math.max(0, options.length - 1)
                * luminaDesign.spacing.extraSmall
            + luminaDesign.spacing.small * 2

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

    function popupPosition() {
        const controlLeft = width - controlWidth - 12
        const controlHalfHeight = 18
        const popupGap = luminaDesign.spacing.extraSmall
        const belowY =
            height / 2 + controlHalfHeight + popupGap
        const aboveY =
            height / 2
                - controlHalfHeight
                - popupGap
                - popupHeight
        const overlay = Controls.Overlay.overlay

        if (!overlay)
            return Qt.point(controlLeft, belowY)

        const origin = mapToItem(overlay, 0, 0)
        const globalY = DropdownLogic.popupY(
            origin.y + belowY,
            origin.y + aboveY,
            popupHeight,
            overlay.height,
            luminaDesign.spacing.large
        )

        return Qt.point(
            controlLeft,
            globalY - origin.y
        )
    }

    function openMenu() {
        if (!available || options.length === 0)
            return

        dropdownPopup.highlightedIndex =
            DropdownLogic.initialIndex(
                currentIndex(),
                options.length
            )
        dropdownPopup.open()
    }

    function toggleMenu() {
        if (dropdownPopup.opened)
            dropdownPopup.close()
        else
            openMenu()
    }

    function selectIndex(index) {
        if (index < 0 || index >= options.length)
            return

        selected(String(options[index].value))
        dropdownPopup.close()
    }

    onActivated: toggleMenu()

    Keys.onDownPressed: event => {
        openMenu()
        event.accepted = true
    }

    Keys.onUpPressed: event => {
        openMenu()
        event.accepted = true
    }

    Rectangle {
        anchors.fill: parent
        radius: root.luminaDesign.shape.full
        color: root.grouped
            ? root.luminaDesign.color.surfaceBase
            : root.luminaDesign.color.surfaceMuted
        border.width: 1
        border.color: root.activeFocus
            || dropdownPopup.opened
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
                text: "⌄"
                rotation: dropdownPopup.opened ? 180 : 0
                color: root.luminaDesign.color.primary
                font.pixelSize: 18
                font.weight: Font.Bold

                Behavior on rotation {
                    NumberAnimation {
                        duration:
                            root.luminaDesign.motion.spatialFast
                        easing.type:
                            root.luminaDesign.motion.spatialEasing
                        easing.overshoot:
                            root.luminaDesign.motion.spatialOvershoot
                    }
                }
            }
        }
    }

    Controls.Popup {
        id: dropdownPopup

        property int highlightedIndex: -1

        parent: root
        x: root.popupPosition().x
        y: root.popupPosition().y
        width: root.controlWidth
        height: root.popupHeight
        padding: root.luminaDesign.spacing.small
        focus: true
        modal: false
        closePolicy:
            Controls.Popup.CloseOnEscape
                | Controls.Popup.CloseOnPressOutside

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: root.luminaDesign.motion.effectsDefault
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: root.luminaDesign.motion.effectsFast
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }

        onOpened: {
            highlightedIndex = DropdownLogic.initialIndex(
                root.currentIndex(),
                root.options.length
            )
            menuFocus.forceActiveFocus(Qt.PopupFocusReason)
        }

        background: Rectangle {
            radius: root.luminaDesign.shape.large
            color: root.luminaDesign.color.surfaceContainer
            border.width: 1
            border.color: root.luminaDesign.color.outline
        }

        contentItem: FocusScope {
            id: menuFocus

            focus: true

            Keys.onUpPressed: event => {
                dropdownPopup.highlightedIndex =
                    DropdownLogic.offsetIndex(
                        dropdownPopup.highlightedIndex,
                        -1,
                        root.options.length
                    )
                event.accepted = true
            }

            Keys.onDownPressed: event => {
                dropdownPopup.highlightedIndex =
                    DropdownLogic.offsetIndex(
                        dropdownPopup.highlightedIndex,
                        1,
                        root.options.length
                    )
                event.accepted = true
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Home) {
                    dropdownPopup.highlightedIndex =
                        root.options.length > 0 ? 0 : -1
                    event.accepted = true
                } else if (event.key === Qt.Key_End) {
                    dropdownPopup.highlightedIndex =
                        root.options.length - 1
                    event.accepted = true
                }
            }

            Keys.onReturnPressed: event => {
                root.selectIndex(dropdownPopup.highlightedIndex)
                event.accepted = true
            }

            Keys.onSpacePressed: event => {
                root.selectIndex(dropdownPopup.highlightedIndex)
                event.accepted = true
            }

            Column {
                anchors.fill: parent
                spacing: root.luminaDesign.spacing.extraSmall

                Repeater {
                    model: root.options

                    delegate: Rectangle {
                        id: optionItem

                        required property var modelData
                        required property int index
                        readonly property bool selected:
                            String(modelData.value)
                                === root.currentValue
                        readonly property bool highlighted:
                            dropdownPopup.highlightedIndex === index

                        width: parent.width
                        height:
                            root.luminaDesign.size.settingsMenuItemHeight
                        radius: selected
                            ? root.luminaDesign.shape.full
                            : root.luminaDesign.shape.medium
                        color: selected
                            ? root.luminaDesign.color.accentContainer
                            : highlighted
                                ? root.luminaDesign.color.surfaceMuted
                                : "transparent"

                        Accessible.role: Accessible.MenuItem
                        Accessible.name: String(modelData.label)
                        Accessible.selected: selected
                        Accessible.onPressAction:
                            root.selectIndex(index)

                        Behavior on color {
                            ColorAnimation {
                                duration:
                                    root.luminaDesign.motion.effectsFast
                                easing.type:
                                    root.luminaDesign.motion.effectsEasing
                            }
                        }

                        Row {
                            anchors {
                                fill: parent
                                leftMargin:
                                    root.luminaDesign.spacing.large
                                rightMargin:
                                    root.luminaDesign.spacing.large
                            }

                            Text {
                                anchors.verticalCenter:
                                    parent.verticalCenter
                                width: parent.width
                                    - checkmark.implicitWidth
                                text: String(optionItem.modelData.label)
                                color: optionItem.selected
                                    ? root.luminaDesign.color.onAccentContainer
                                    : root.luminaDesign.color.onSurface
                                elide: Text.ElideRight
                                font.pixelSize:
                                    root.luminaDesign.typography.labelMedium
                                font.weight: optionItem.selected
                                    ? Font.Bold
                                    : Font.Medium
                            }

                            Text {
                                id: checkmark

                                anchors.verticalCenter:
                                    parent.verticalCenter
                                visible: optionItem.selected
                                text: "✓"
                                color:
                                    root.luminaDesign.color.onAccentContainer
                                font.pixelSize: 14
                                font.weight: Font.Bold
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onContainsMouseChanged: {
                                if (containsMouse)
                                    dropdownPopup.highlightedIndex =
                                        optionItem.index
                            }
                            onClicked:
                                root.selectIndex(optionItem.index)
                        }
                    }
                }
            }
        }
    }
}

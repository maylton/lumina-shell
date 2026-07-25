pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.design
import qs.modules.control
import qs.services.i18n

Rectangle {
    id: root

    property var widgets: []

    signal addWidget(string widgetId)

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool hasWidgets: widgets.length > 0

    implicitHeight: 56
    radius: luminaDesign.shape.largeIncreased
    color: addMouse.containsMouse || activeFocus
        ? luminaDesign.color.accentContainer
        : luminaDesign.color.surfaceMuted
    activeFocusOnTab: visible
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Button
    Accessible.name: I18n.tr(
        "settings.bar.widget.add",
        "Add widgets"
    )
    Accessible.description: hasWidgets
        ? I18n.tr(
            "settings.bar.widget.addDescription",
            "Choose a removed widget for this region"
        )
        : I18n.tr(
            "settings.bar.widget.addEmpty",
            "All widgets for this region are active"
        )
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: togglePopup()

    function togglePopup() {
        if (addPopup.opened)
            addPopup.close()
        else
            addPopup.open()
    }

    Keys.onSpacePressed: event => {
        togglePopup()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        togglePopup()
        event.accepted = true
    }

    Row {
        anchors {
            left: parent.left
            leftMargin: root.luminaDesign.spacing.large
            verticalCenter: parent.verticalCenter
        }
        spacing: root.luminaDesign.spacing.medium

        DashboardIcon {
            anchors.verticalCenter: parent.verticalCenter
            iconName: "list-add-symbolic"
            fallbackSymbol: "+"
            iconColor: root.luminaDesign.color.primary
            iconSize: 20
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: I18n.tr(
                "settings.bar.widget.add",
                "Add widgets"
            )
            color: root.luminaDesign.color.onSurface
            font.pixelSize:
                root.luminaDesign.typography.bodyMedium
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: addMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            root.togglePopup()
        }
    }

    Controls.Popup {
        id: addPopup

        readonly property point anchorOrigin: parent
            ? root.mapToItem(parent, 0, 0)
            : Qt.point(0, 0)
        readonly property real preferredBelow:
            anchorOrigin.y + root.height
                + root.luminaDesign.spacing.small

        parent: Controls.Overlay.overlay
        x: parent
            ? Math.max(
                root.luminaDesign.spacing.medium,
                Math.min(
                    parent.width - width
                        - root.luminaDesign.spacing.medium,
                    anchorOrigin.x + root.width - width
                )
            )
            : 0
        y: parent
            ? preferredBelow + height
                <= parent.height
                    - root.luminaDesign.spacing.medium
                ? preferredBelow
                : Math.max(
                    root.luminaDesign.spacing.medium,
                    anchorOrigin.y - height
                        - root.luminaDesign.spacing.small
                )
            : 0
        width: Math.min(360, root.width)
        height: Math.min(
            Math.max(96, root.widgets.length * 66)
                + root.luminaDesign.spacing.medium * 2,
            340
        )
        padding: root.luminaDesign.spacing.medium
        focus: true
        closePolicy:
            Controls.Popup.CloseOnEscape
                | Controls.Popup.CloseOnPressOutside
        onOpened: {
            const firstItem = addRepeater.itemAt(0)

            if (firstItem)
                firstItem.forceActiveFocus(
                    Qt.PopupFocusReason
                )
        }

        background: Rectangle {
            radius: root.luminaDesign.shape.extraLarge
            color: root.luminaDesign.color.surfaceContainer
            border.width: 1
            border.color: root.luminaDesign.color.outline
        }

        contentItem: Flickable {
            contentWidth: width
            contentHeight: addList.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: addList

                width: parent.width
                spacing: root.luminaDesign.spacing.small

                Text {
                    width: parent.width
                    visible: !root.hasWidgets
                    text: I18n.tr(
                        "settings.bar.widget.addEmpty",
                        "All widgets for this region are active"
                    )
                    color: root.luminaDesign.color.textMuted
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    font.pixelSize:
                        root.luminaDesign.typography.labelMedium
                    topPadding:
                        root.luminaDesign.spacing.controlItemGap
                    bottomPadding:
                        root.luminaDesign.spacing.controlItemGap
                }

                Repeater {
                    id: addRepeater

                    model: root.widgets

                    delegate: Rectangle {
                        id: option

                        required property var modelData

                        width: addList.width
                        height: 58
                        radius:
                            root.luminaDesign.shape.largeIncreased
                        color: optionMouse.containsMouse
                            || activeFocus
                            ? root.luminaDesign.color.accentContainer
                            : root.luminaDesign.color.surfaceMuted
                        activeFocusOnTab: true

                        Accessible.role: Accessible.Button
                        Accessible.name: I18n.tr(
                            "settings.bar.widget.addNamed",
                            "Add %1",
                            [String(modelData.title)]
                        )
                        Accessible.description:
                            String(modelData.description)
                        Accessible.onPressAction: activate()

                        function activate() {
                            root.addWidget(String(modelData.id))
                            addPopup.close()
                        }

                        Keys.onSpacePressed: event => {
                            activate()
                            event.accepted = true
                        }

                        Keys.onReturnPressed: event => {
                            activate()
                            event.accepted = true
                        }

                        Row {
                            anchors {
                                fill: parent
                                leftMargin:
                                    root.luminaDesign.spacing.medium
                                rightMargin:
                                    root.luminaDesign.spacing.medium
                            }
                            spacing:
                                root.luminaDesign.spacing.medium

                            DashboardIcon {
                                anchors.verticalCenter:
                                    parent.verticalCenter
                                iconName:
                                    String(option.modelData.icon)
                                fallbackSymbol: "+"
                                iconColor:
                                    root.luminaDesign.color.primary
                                iconSize: 20
                            }

                            Column {
                                anchors.verticalCenter:
                                    parent.verticalCenter
                                width: parent.width
                                    - root.luminaDesign.spacing.medium
                                    - 24
                                spacing: 2

                                Text {
                                    width: parent.width
                                    text: String(
                                        option.modelData.title
                                    )
                                    color: root.luminaDesign.color.onSurface
                                    elide: Text.ElideRight
                                    font.pixelSize:
                                        root.luminaDesign.typography.bodyMedium
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    width: parent.width
                                    text: String(
                                        option.modelData.description
                                    )
                                    color: root.luminaDesign.color.textMuted
                                    elide: Text.ElideRight
                                    font.pixelSize:
                                        root.luminaDesign.typography.labelSmall
                                }
                            }
                        }

                        MouseArea {
                            id: optionMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: option.activate()
                        }
                    }
                }
            }
        }
    }
}

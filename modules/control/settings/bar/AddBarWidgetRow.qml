pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.design
import qs.modules.control
import qs.services.i18n
import qs.stores.shell

Rectangle {
    id: root

    property var widgets: []
    property double openRequestedAt: 0
    property bool openPending: false
    property int openRequestGeneration: 0

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
        "Add or move widgets"
    )
    Accessible.description: hasWidgets
        ? I18n.tr(
            "settings.bar.widget.addDescription",
            "Choose a widget to add or move to this area"
        )
        : I18n.tr(
            "settings.bar.widget.addEmpty",
            "All widgets are already in this area"
        )
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: togglePopup()

    function togglePopup() {
        if (addPopup.opened || addPopup.visible || openPending) {
            dismissPopup()
            return
        }

        const generation = ++openRequestGeneration
        openRequestedAt = Date.now()
        openPending = true
        PerformanceTrace.recordInstant(
            "popup",
            "add-bar-widget",
            "requested",
            { optionCount: root.widgets.length }
        )

        Qt.callLater(function() {
            if (!root.openPending
                || generation !== root.openRequestGeneration) {
                return
            }

            root.openPending = false
            addPopup.open()
        })
    }

    function dismissPopup() {
        ++openRequestGeneration
        openPending = false
        openRequestedAt = 0
        addPopup.close()
    }

    function toggleFromPointer() {
        root.forceActiveFocus()
        root.focus = false
        root.togglePopup()
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
                "Add or move widgets"
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
        onClicked: root.toggleFromPointer()
    }

    Controls.Popup {
        id: addPopup

        readonly property point anchorTopLeft:
            root.mapToItem(null, 0, 0)
        readonly property point anchorBottomRight:
            root.mapToItem(null, root.width, root.height)
        readonly property real edgeMargin:
            root.luminaDesign.spacing.medium
        readonly property real preferredBelow:
            anchorBottomRight.y + root.luminaDesign.spacing.small
        readonly property real preferredAbove:
            anchorTopLeft.y - height - root.luminaDesign.spacing.small
        readonly property real maximumHeight: parent
            ? Math.max(
                160,
                Math.min(460, parent.height - edgeMargin * 2)
            )
            : 460

        parent: Controls.Overlay.overlay
        x: parent
            ? Math.max(
                edgeMargin,
                Math.min(
                    parent.width - width - edgeMargin,
                    anchorBottomRight.x - width
                )
            )
            : 0
        y: parent
            ? preferredBelow + height
                <= parent.height - edgeMargin
                    ? preferredBelow
                    : Math.max(
                        edgeMargin,
                        Math.min(
                            parent.height - height - edgeMargin,
                            preferredAbove
                        )
                    )
            : 0
        width: Math.min(380, Math.max(320, root.width))
        height: Math.min(
            Math.max(96, root.widgets.length * 66)
                + root.luminaDesign.spacing.medium * 2,
            maximumHeight
        )
        padding: root.luminaDesign.spacing.medium
        focus: true
        closePolicy:
            Controls.Popup.CloseOnEscape
                | Controls.Popup.CloseOnPressOutside
        onOpened: {
            root.openPending = false

            if (root.openRequestedAt > 0) {
                PerformanceTrace.record(
                    "popup",
                    "add-bar-widget",
                    "opened",
                    Date.now() - root.openRequestedAt,
                    { optionCount: root.widgets.length }
                )
                root.openRequestedAt = 0
            }

            const firstItem = addRepeater.itemAt(0)

            if (firstItem)
                firstItem.forceActiveFocus(
                    Qt.PopupFocusReason
                )
        }
        onClosed: {
            root.openPending = false
            root.openRequestedAt = 0
        }

        background: Rectangle {
            radius: root.luminaDesign.shape.extraLarge
            color: root.luminaDesign.color.surfaceContainer
            border.width: 1
            border.color: root.luminaDesign.color.outline
        }

        contentItem: Flickable {
            id: addFlickable

            contentWidth: width
            contentHeight: addList.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 2600

            Controls.ScrollBar.vertical: Controls.ScrollBar {
                policy: addFlickable.contentHeight > addFlickable.height
                    ? Controls.ScrollBar.AlwaysOn
                    : Controls.ScrollBar.AlwaysOff
            }

            Column {
                id: addList

                width: addFlickable.width
                    - (addFlickable.contentHeight > addFlickable.height
                        ? 12
                        : 0)
                spacing: root.luminaDesign.spacing.small

                Text {
                    width: parent.width
                    visible: !root.hasWidgets
                    text: I18n.tr(
                        "settings.bar.widget.addEmpty",
                        "All widgets are already in this area"
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
                            "Add or move %1 here",
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

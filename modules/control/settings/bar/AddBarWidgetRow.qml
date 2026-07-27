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

        readonly property point overlaySceneOrigin: parent
            ? parent.mapToItem(null, 0, 0)
            : Qt.point(0, 0)
        readonly property point anchorTopLeftScene:
            root.mapToItem(null, 0, 0)
        readonly property point anchorBottomRightScene:
            root.mapToItem(null, root.width, root.height)
        readonly property point anchorTopLeft: Qt.point(
            anchorTopLeftScene.x - overlaySceneOrigin.x,
            anchorTopLeftScene.y - overlaySceneOrigin.y
        )
        readonly property point anchorBottomRight: Qt.point(
            anchorBottomRightScene.x - overlaySceneOrigin.x,
            anchorBottomRightScene.y - overlaySceneOrigin.y
        )
        readonly property real edgeMargin:
            root.luminaDesign.spacing.medium
        readonly property real popupGap:
            root.luminaDesign.spacing.small
        readonly property real naturalHeight:
            Math.max(96, root.widgets.length * 66)
                + root.luminaDesign.spacing.medium * 2
        readonly property real availableBelow: parent
            ? Math.max(
                0,
                parent.height - edgeMargin
                    - anchorBottomRight.y - popupGap
            )
            : 0
        readonly property real availableAbove: parent
            ? Math.max(
                0,
                anchorTopLeft.y - edgeMargin - popupGap
            )
            : 0
        readonly property bool openBelow:
            availableBelow >= Math.min(220, naturalHeight)
                || availableBelow >= availableAbove
        readonly property real maximumHeight: Math.max(
            96,
            Math.min(
                400,
                openBelow ? availableBelow : availableAbove
            )
        )
        readonly property real anchorCenterX:
            (anchorTopLeft.x + anchorBottomRight.x) / 2

        parent: Controls.Overlay.overlay
        x: parent
            ? Math.max(
                edgeMargin,
                Math.min(
                    parent.width - width - edgeMargin,
                    anchorCenterX - width / 2
                )
            )
            : 0
        y: parent
            ? Math.max(
                edgeMargin,
                Math.min(
                    parent.height - height - edgeMargin,
                    openBelow
                        ? anchorBottomRight.y + popupGap
                        : anchorTopLeft.y - height - popupGap
                )
            )
            : 0
        width: Math.min(380, Math.max(320, root.width))
        height: Math.min(naturalHeight, maximumHeight)
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

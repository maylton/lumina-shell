pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQml.Models
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
    Accessible.onPressAction: toggleMenu()

    function toggleMenu() {
        if (addMenu.opened || addMenu.visible || openPending) {
            dismissMenu()
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
            addMenu.open()
        })
    }

    function dismissMenu() {
        ++openRequestGeneration
        openPending = false
        openRequestedAt = 0
        addMenu.close()
    }

    function toggleFromPointer() {
        root.forceActiveFocus()
        root.focus = false
        root.toggleMenu()
    }

    Keys.onSpacePressed: event => {
        toggleMenu()
        event.accepted = true
    }

    Keys.onReturnPressed: event => {
        toggleMenu()
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

    Controls.Menu {
        id: addMenu

        parent: root
        x: 0
        y: root.height + root.luminaDesign.spacing.small
        width: Math.min(420, root.width)
        cascade: false
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
        }

        onClosed: {
            root.openPending = false
            root.openRequestedAt = 0
        }

        Controls.MenuItem {
            visible: !root.hasWidgets
            enabled: false
            text: I18n.tr(
                "settings.bar.widget.addEmpty",
                "All widgets are already in this area"
            )
        }

        Instantiator {
            model: root.widgets

            delegate: Controls.MenuItem {
                required property var modelData

                text: String(modelData.title)
                Accessible.description:
                    String(modelData.description)
                onTriggered: {
                    root.addWidget(String(modelData.id))
                    addMenu.close()
                }
            }

            onObjectAdded: (index, object) =>
                addMenu.insertItem(index, object)
            onObjectRemoved: (index, object) =>
                addMenu.removeItem(object)
        }
    }
}

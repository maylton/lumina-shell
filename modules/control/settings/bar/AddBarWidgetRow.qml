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
        padding: root.luminaDesign.spacing.small
        cascade: false
        focus: true
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

        background: Rectangle {
            radius: root.luminaDesign.shape.large
            color: root.luminaDesign.color.surfaceContainer
            border.width: 1
            border.color: root.luminaDesign.color.outline
        }

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
            implicitHeight:
                root.luminaDesign.size.settingsMenuItemHeight
            leftPadding: root.luminaDesign.spacing.large
            rightPadding: root.luminaDesign.spacing.large

            background: Rectangle {
                radius: root.luminaDesign.shape.medium
                color: "transparent"
            }

            contentItem: Text {
                text: I18n.tr(
                    "settings.bar.widget.addEmpty",
                    "All widgets are already in this area"
                )
                color: root.luminaDesign.color.textMuted
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                font.pixelSize:
                    root.luminaDesign.typography.labelMedium
                font.weight: Font.Medium
            }
        }

        Instantiator {
            model: root.widgets

            delegate: Controls.MenuItem {
                id: widgetMenuItem

                required property var modelData

                implicitHeight: Math.max(
                    root.luminaDesign.size.settingsMenuItemHeight,
                    52
                )
                leftPadding: root.luminaDesign.spacing.medium
                rightPadding: root.luminaDesign.spacing.medium

                Accessible.name: String(modelData.title)
                Accessible.description:
                    String(modelData.description)

                background: Rectangle {
                    radius: root.luminaDesign.shape.medium
                    color: widgetMenuItem.highlighted
                        ? root.luminaDesign.color.surfaceMuted
                        : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration:
                                root.luminaDesign.motion.effectsFast
                            easing.type:
                                root.luminaDesign.motion.effectsEasing
                        }
                    }
                }

                contentItem: Row {
                    spacing: root.luminaDesign.spacing.medium

                    DashboardIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        iconName: String(widgetMenuItem.modelData.icon)
                        fallbackSymbol: "+"
                        iconColor: root.luminaDesign.color.primary
                        iconSize: 18
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                            - root.luminaDesign.spacing.medium
                            - 22
                        spacing: 1

                        Text {
                            width: parent.width
                            text: String(widgetMenuItem.modelData.title)
                            color: root.luminaDesign.color.onSurface
                            elide: Text.ElideRight
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width
                            text: String(
                                widgetMenuItem.modelData.description
                            )
                            color: root.luminaDesign.color.textMuted
                            elide: Text.ElideRight
                            font.pixelSize:
                                root.luminaDesign.typography.labelSmall
                        }
                    }
                }

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

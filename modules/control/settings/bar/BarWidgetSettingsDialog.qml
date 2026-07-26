pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.design
import qs.modules.control.settings.bar.widgets
import qs.services.i18n
import qs.stores.config
import "BarWidgetCatalog.js" as BarWidgetCatalog

Controls.Popup {
    id: root

    property string widgetId: ""
    property var widget: BarWidgetCatalog.find(widgetId)
    property Item restoreFocusItem: null

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property string displayTitle: widget
        ? I18n.tr(
            ["settings", "bar", "catalog", widgetId, "title"]
                .join("."),
            String(widget.title)
        )
        : ""
    readonly property string displayDescription: widget
        ? I18n.tr(
            [
                "settings",
                "bar",
                "catalog",
                widgetId,
                "description"
            ].join("."),
            String(widget.description)
        )
        : ""
    readonly property var componentRegistry: ({
        launcher: launcherSettings,
        overview: overviewSettings,
        workspaces: workspacesSettings,
        datetime: dateTimeSettings,
        context: contextSettings,
        tray: traySettings,
        notifications: notificationsSettings,
        "system-status": systemStatusSettings,
        dashboard: userAvatarSettings,
        wallpaper: wallpaperSettings,
        session: sessionSettings
    })

    parent: Controls.Overlay.overlay
    x: parent ? Math.round((parent.width - width) / 2) : 0
    y: parent ? Math.round((parent.height - height) / 2) : 0
    width: parent
        ? Math.min(520, Math.max(440, parent.width - 80))
        : 480
    height: parent
        ? Math.min(680, Math.max(360, parent.height - 80))
        : 620
    padding: 0
    modal: true
    focus: true
    closePolicy:
        Controls.Popup.CloseOnEscape
            | Controls.Popup.CloseOnPressOutside

    function openFor(requestedWidgetId, sourceItem) {
        const requested = BarWidgetCatalog.find(requestedWidgetId)

        if (!requested || !requested.configurable)
            return

        widgetId = requested.id
        restoreFocusItem = sourceItem && sourceItem.activeFocus
            ? sourceItem
            : null
        open()
    }

    onOpened: closeButton.forceActiveFocus(Qt.PopupFocusReason)

    onClosed: {
        if (restoreFocusItem)
            restoreFocusItem.forceActiveFocus(Qt.PopupFocusReason)

        restoreFocusItem = null
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: root.luminaDesign.motion.effectsDefault
                easing.type: root.luminaDesign.motion.effectsEasing
            }

            NumberAnimation {
                property: "scale"
                from: 0.96
                to: 1
                duration: root.luminaDesign.motion.spatialDefault
                easing.type: root.luminaDesign.motion.spatialEasing
                easing.overshoot:
                    root.luminaDesign.motion.spatialOvershoot
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: root.luminaDesign.motion.effectsFast
                easing.type: root.luminaDesign.motion.effectsEasing
            }

            NumberAnimation {
                property: "scale"
                from: 1
                to: 0.98
                duration: root.luminaDesign.motion.spatialFast
                easing.type: root.luminaDesign.motion.spatialEasing
            }
        }
    }

    background: Rectangle {
        radius: root.luminaDesign.shape.extraLarge
        color: root.luminaDesign.color.surfaceContainer
        border.width: 1
        border.color: root.luminaDesign.color.outline
    }

    Controls.Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.46)
    }

    contentItem: FocusScope {
        Column {
            anchors {
                fill: parent
                margins: root.luminaDesign.spacing.controlContentInset
            }
            spacing: root.luminaDesign.spacing.controlItemGap

            Row {
                width: parent.width
                height: 52
                spacing: root.luminaDesign.spacing.medium

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                        - closeButton.width
                        - resetButton.width
                        - parent.spacing * 2
                    spacing: 3

                    Text {
                        width: parent.width
                        text: root.displayTitle
                        color: root.luminaDesign.color.onSurface
                        elide: Text.ElideRight
                        font.pixelSize:
                            root.luminaDesign.typography.titleLarge
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        text: root.displayDescription
                        color: root.luminaDesign.color.textMuted
                        elide: Text.ElideRight
                        font.pixelSize:
                            root.luminaDesign.typography.labelMedium
                    }
                }

                Rectangle {
                    id: resetButton

                    anchors.verticalCenter: parent.verticalCenter
                    width: resetLabel.implicitWidth + 24
                    height: 36
                    radius: root.luminaDesign.shape.full
                    color: resetMouse.containsMouse || activeFocus
                        ? root.luminaDesign.color.accentContainer
                        : root.luminaDesign.color.surfaceMuted
                    activeFocusOnTab: true
                    border.width: activeFocus ? 2 : 0
                    border.color: root.luminaDesign.color.primary

                    Accessible.role: Accessible.Button
                    Accessible.name: I18n.tr(
                        "settings.bar.widget.reset",
                        "Reset this widget"
                    )
                    Accessible.focusable: true
                    Accessible.focused: activeFocus
                    Accessible.onPressAction: activate()

                    function activate() {
                        ConfigStore.resetBarWidgetSettings(
                            root.widgetId
                        )
                    }

                    function activateFromPointer() {
                        resetButton.forceActiveFocus()
                        resetButton.focus = false
                        resetButton.activate()
                    }

                    Keys.onSpacePressed: event => {
                        activate()
                        event.accepted = true
                    }

                    Keys.onReturnPressed: event => {
                        activate()
                        event.accepted = true
                    }

                    Text {
                        id: resetLabel

                        anchors.centerIn: parent
                        text: I18n.tr(
                            "settings.bar.widget.reset",
                            "Reset this widget"
                        )
                        color: root.luminaDesign.color.onSurface
                        font.pixelSize:
                            root.luminaDesign.typography.labelSmall
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        id: resetMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: resetButton.activateFromPointer()
                    }
                }

                BarWidgetActionButton {
                    id: closeButton

                    iconName: "window-close-symbolic"
                    fallbackSymbol: "×"
                    accessibleName: I18n.tr(
                        "settings.bar.widget.close",
                        "Close widget settings"
                    )
                    onClicked: root.close()
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: root.luminaDesign.color.divider
            }

            Flickable {
                width: parent.width
                height: parent.height - 52
                    - parent.spacing * 2 - 1
                contentWidth: width
                contentHeight: settingsLoader.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 2600

                Loader {
                    id: settingsLoader

                    width: parent.width
                    sourceComponent:
                        root.componentRegistry[root.widgetId] || null
                }
            }
        }
    }

    Component {
        id: launcherSettings
        LauncherWidgetSettings {}
    }

    Component {
        id: overviewSettings
        OverviewWidgetSettings {}
    }

    Component {
        id: workspacesSettings
        WorkspacesWidgetSettings {}
    }

    Component {
        id: dateTimeSettings
        DateTimeWidgetSettings {}
    }

    Component {
        id: contextSettings
        ContextWidgetSettings {}
    }

    Component {
        id: traySettings
        TrayWidgetSettings {}
    }

    Component {
        id: notificationsSettings
        NotificationsWidgetSettings {}
    }

    Component {
        id: systemStatusSettings
        SystemStatusWidgetSettings {}
    }

    Component {
        id: userAvatarSettings
        UserAvatarWidgetSettings {}
    }

    Component {
        id: wallpaperSettings
        WallpaperWidgetSettings {}
    }

    Component {
        id: sessionSettings
        SessionWidgetSettings {}
    }
}

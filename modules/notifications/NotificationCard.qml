pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.services.notifications
import qs.stores.config

Rectangle {
    id: root

    required property var entry
    property bool popupMode: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property int timeout: {
        const requested = Number(entry.expireTimeout)

        if (requested > 0)
            return Math.max(3000, Math.min(requested, 15000))

        return Number(entry.urgency) >= 2
            ? Math.max(10000, ConfigStore.notificationPopupDuration)
            : ConfigStore.notificationPopupDuration
    }

    implicitHeight: cardContent.implicitHeight
        + root.luminaDesign.spacing.large * 2
    radius: cardMouse.containsMouse
        ? root.luminaDesign.shape.largeIncreased
        : root.luminaDesign.shape.large
    color: root.luminaDesign.color.surfaceMuted
    border.width: Number(entry.urgency) >= 2 || cardMouse.containsMouse ? 1 : 0
    border.color: Number(entry.urgency) >= 2
        ? root.luminaDesign.color.urgent
        : root.luminaDesign.color.outline
    scale: cardMouse.pressed ? 0.99 : 1.0

    Accessible.role: Accessible.Pane
    Accessible.name: String(entry.summary || "Notification")
    Accessible.description: String(entry.body || "")

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.fast
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.medium
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.fast
        }
    }

    Timer {
        interval: root.timeout
        running: root.popupMode
            && !root.entry.resident
            && !root.entry.closed
        repeat: false
        onTriggered: NotificationService.expire(root.entry.key)
    }

    MouseArea {
        id: cardMouse

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    Row {
        id: header

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: root.luminaDesign.spacing.large
        }

        spacing: root.luminaDesign.spacing.medium

        Rectangle {
            id: iconContainer

            visible: ConfigStore.notificationShowImages
            width: visible
                ? root.luminaDesign.size.notificationIcon + 6
                : 0
            height: width
            radius: root.luminaDesign.shape.medium
            color: root.entry.read
                ? root.luminaDesign.color.surfaceContainer
                : root.luminaDesign.color.accentContainer

            Image {
                anchors.centerIn: parent
                width: root.luminaDesign.size.notificationIcon - 6
                height: width
                source: String(root.entry.icon || "").indexOf("/") >= 0
                    ? String(root.entry.icon)
                    : Quickshell.iconPath(
                        String(root.entry.icon || "dialog-information"),
                        "dialog-information"
                    )
                sourceSize.width: width
                sourceSize.height: height
                asynchronous: false
                fillMode: Image.PreserveAspectFit
            }
        }

        Column {
            width: parent.width
                - (ConfigStore.notificationShowImages
                    ? iconContainer.width
                    : 0)
                - closeButton.width
                - parent.spacing * 2
            spacing: 2

            Row {
                width: parent.width
                spacing: root.luminaDesign.spacing.small

                Text {
                    width: parent.width - timeLabel.width - parent.spacing
                    text: String(root.entry.appName || "Application")
                    color: root.luminaDesign.color.textMuted
                    elide: Text.ElideRight
                    font.pixelSize:
                        root.luminaDesign.typography.labelMedium
                    font.weight: Font.DemiBold
                }

                Text {
                    id: timeLabel

                    text: Qt.formatTime(
                        new Date(Number(root.entry.receivedAt)),
                        "HH:mm"
                    )
                    color: root.luminaDesign.color.textMuted
                    font.pixelSize: root.luminaDesign.typography.labelSmall
                }
            }

            Text {
                width: parent.width
                text: String(root.entry.summary || "Notification")
                color: root.luminaDesign.color.onSurface
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.titleMedium
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                visible: text.length > 0
                text: String(root.entry.body || "")
                color: root.luminaDesign.color.textMuted
                wrapMode: Text.Wrap
                maximumLineCount: root.popupMode ? 4 : 8
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.labelMedium
            }

            Row {
                width: parent.width
                visible: !root.entry.closed
                    && root.entry.actions
                    && root.entry.actions.length > 0
                spacing: root.luminaDesign.spacing.small

                Repeater {
                    model: root.entry.actions || []

                    delegate: Rectangle {
                        id: actionButton

                        required property var modelData

                        width: actionLabel.implicitWidth + 16
                        height: 30
                        activeFocusOnTab: true
                        radius: root.luminaDesign.shape.full
                        color: actionMouse.containsMouse
                            ? root.luminaDesign.color.accentContainer
                            : root.luminaDesign.color.surfaceContainer
                        border.width: activeFocus ? 2 : 0
                        border.color: root.luminaDesign.color.primary

                        Accessible.role: Accessible.Button
                        Accessible.name:
                            String(modelData.text || "Open")
                        Accessible.focusable: true
                        Accessible.focused: activeFocus
                        Accessible.onPressAction:
                            NotificationService.invokeAction(
                                root.entry,
                                modelData
                            )

                        Keys.onSpacePressed: event => {
                            NotificationService.invokeAction(
                                root.entry,
                                modelData
                            )
                            event.accepted = true
                        }

                        Keys.onReturnPressed: event => {
                            NotificationService.invokeAction(
                                root.entry,
                                modelData
                            )
                            event.accepted = true
                        }

                        Text {
                            id: actionLabel

                            anchors.centerIn: parent
                            text: String(actionButton.modelData.text || "Open")
                            color: actionMouse.containsMouse
                                ? root.luminaDesign.color.onAccentContainer
                                : root.luminaDesign.color.onSurface
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: actionMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                actionButton.focus = false
                                NotificationService.invokeAction(
                                    root.entry,
                                    actionButton.modelData
                                )
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: closeButton

            width: 30
            height: 30
            activeFocusOnTab: true
            radius: root.luminaDesign.shape.full
            color: closeMouse.containsMouse
                ? root.luminaDesign.color.accentContainer
                : "transparent"
            border.width: activeFocus ? 2 : 0
            border.color: root.luminaDesign.color.primary

            Accessible.role: Accessible.Button
            Accessible.name: "Dismiss notification"
            Accessible.focusable: true
            Accessible.focused: activeFocus
            Accessible.onPressAction:
                NotificationService.dismissNotification(root.entry)

            Keys.onSpacePressed: event => {
                NotificationService.dismissNotification(root.entry)
                event.accepted = true
            }

            Keys.onReturnPressed: event => {
                NotificationService.dismissNotification(root.entry)
                event.accepted = true
            }

            Text {
                anchors.centerIn: parent
                text: "×"
                color: closeMouse.containsMouse
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.textMuted
                font.pixelSize: 18
            }

            MouseArea {
                id: closeMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    closeButton.focus = false
                    NotificationService.dismissNotification(root.entry)
                }
            }
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            topMargin: root.luminaDesign.spacing.medium
            bottomMargin: root.luminaDesign.spacing.medium
        }

        visible: !root.entry.read
        width: 4
        radius: root.luminaDesign.shape.full
        color: Number(root.entry.urgency) >= 2
            ? root.luminaDesign.color.urgent
            : root.luminaDesign.color.primary
    }

    Column {
        id: cardContent

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: root.luminaDesign.spacing.large
        }

        spacing: root.luminaDesign.spacing.small

        Item {
            width: 1
            height: header.implicitHeight
        }
    }
}

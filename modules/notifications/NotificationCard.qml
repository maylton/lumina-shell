pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.services.notifications

Rectangle {
    id: root

    required property var entry
    property bool popupMode: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property int timeout: {
        const requested = Number(entry.expireTimeout)

        if (requested > 0)
            return Math.max(3000, Math.min(requested, 15000))

        return Number(entry.urgency) >= 2 ? 10000 : 6000
    }

    implicitHeight: cardContent.implicitHeight
        + root.luminaDesign.spacing.large * 2
    radius: root.luminaDesign.shape.large
    color: entry.read
        ? root.luminaDesign.color.surfaceContainer
        : root.luminaDesign.color.surfaceMuted
    border.width: Number(entry.urgency) >= 2 || cardMouse.containsMouse ? 1 : 0
    border.color: Number(entry.urgency) >= 2
        ? root.luminaDesign.color.urgent
        : root.luminaDesign.color.outline
    scale: cardMouse.pressed ? 0.99 : 1.0

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.fast
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.fast
            easing.type: Easing.OutCubic
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

        Image {
            width: root.luminaDesign.size.notificationIcon
            height: width
            source: String(root.entry.icon || "").indexOf("/") >= 0
                ? String(root.entry.icon)
                : Quickshell.iconPath(
                    String(root.entry.icon || "dialog-information"),
                    "dialog-information"
                )
            sourceSize.width: width
            sourceSize.height: height
            asynchronous: true
            fillMode: Image.PreserveAspectFit
        }

        Column {
            width: parent.width
                - root.luminaDesign.size.notificationIcon
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
                    font.pixelSize: root.luminaDesign.typography.labelSmall
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
                font.pixelSize: root.luminaDesign.typography.bodyMedium
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
                        height: 26
                        radius: root.luminaDesign.shape.full
                        color: actionMouse.containsMouse
                            ? root.luminaDesign.color.accentContainer
                            : root.luminaDesign.color.surfaceMuted

                        Text {
                            id: actionLabel

                            anchors.centerIn: parent
                            text: String(actionButton.modelData.text || "Open")
                            color: actionMouse.containsMouse
                                ? root.luminaDesign.color.onAccentContainer
                                : root.luminaDesign.color.onSurface
                            font.pixelSize: root.luminaDesign.typography.labelSmall
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: actionMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationService.invokeAction(
                                root.entry,
                                actionButton.modelData
                            )
                        }
                    }
                }
            }
        }

        Rectangle {
            id: closeButton

            width: 26
            height: 26
            radius: root.luminaDesign.shape.full
            color: closeMouse.containsMouse
                ? root.luminaDesign.color.accentContainer
                : "transparent"

            Text {
                anchors.centerIn: parent
                text: "×"
                color: closeMouse.containsMouse
                    ? root.luminaDesign.color.onAccentContainer
                    : root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.titleLarge
            }

            MouseArea {
                id: closeMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NotificationService.dismissNotification(root.entry)
            }
        }
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

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.services.i18n
import "../../services/i18n/LauncherStrings.js" as LauncherStrings

Rectangle {
    id: root

    required property var result
    required property bool selected

    signal activated
    signal contextMenuRequested(var sourceItem)

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool supportsDockPinning:
        result
        && result.kind === "application"
        && result.entry
        && String(result.entry.id || "").length > 0
    readonly property string kindLabel:
        result.kind === "application"
            ? LauncherStrings.text(I18n.locale, "kindApplication")
            : result.kind === "window"
                ? LauncherStrings.text(I18n.locale, "kindWindow")
                : LauncherStrings.text(I18n.locale, "kindAction")

    implicitHeight: root.luminaDesign.size.launcherRowHeight
    radius: selected
        ? root.luminaDesign.shape.large
        : root.luminaDesign.shape.medium
    scale: resultMouse.pressed ? 0.98 : 1
    color: selected || resultMouse.containsMouse
        ? root.luminaDesign.color.accentContainer
        : "transparent"

    Accessible.role: Accessible.ListItem
    Accessible.name: String(result.title || "")
    Accessible.description: String(result.subtitle || "")
    Accessible.selected: selected
    Accessible.onPressAction: root.activated()

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.luminaDesign.motion.press
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Image {
        id: resultIcon

        anchors {
            left: parent.left
            leftMargin: root.luminaDesign.spacing.medium
            verticalCenter: parent.verticalCenter
        }

        width: root.luminaDesign.size.launcherIcon
        height: width
        source: Quickshell.iconPath(
            String(root.result.icon || "application-x-executable"),
            "application-x-executable"
        )
        sourceSize.width: width
        sourceSize.height: height
        asynchronous: false
        fillMode: Image.PreserveAspectFit
    }

    Column {
        anchors {
            left: resultIcon.right
            right: kindLabelContainer.left
            leftMargin: root.luminaDesign.spacing.medium
            rightMargin: root.luminaDesign.spacing.medium
            verticalCenter: parent.verticalCenter
        }

        spacing: 2

        Text {
            width: parent.width
            text: String(root.result.title || "")
            color: root.selected
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.bodyMedium
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: String(root.result.subtitle || "")
            visible: text.length > 0
            color: root.selected
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.textMuted
            opacity: 0.82
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.labelSmall
        }
    }

    Rectangle {
        id: kindLabelContainer

        anchors {
            right: parent.right
            rightMargin: root.luminaDesign.spacing.medium
            verticalCenter: parent.verticalCenter
        }

        width: kindText.implicitWidth + 12
        height: 22
        radius: root.luminaDesign.shape.full
        color: root.selected
            ? root.luminaDesign.color.pressedState
            : root.luminaDesign.color.surfaceMuted

        Text {
            id: kindText

            anchors.centerIn: parent
            text: root.kindLabel
            color: root.selected
                ? root.luminaDesign.color.onAccentContainer
                : root.luminaDesign.color.textMuted
            font.pixelSize: root.luminaDesign.typography.labelSmall
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: resultMouse

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (root.supportsDockPinning)
                    root.contextMenuRequested(root)
                return
            }

            root.activated()
        }
    }
}

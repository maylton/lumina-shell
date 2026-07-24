pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.design

Item {
    id: root

    property var menuEntry: null
    property int depth: 0
    property int closeRevision: 0

    signal actionTriggered

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool separator: menuEntry ? menuEntry.isSeparator : false
    readonly property bool entryEnabled: menuEntry ? menuEntry.enabled : false
    readonly property bool hasChildren: menuEntry ? menuEntry.hasChildren : false
    readonly property bool hasIndicator: menuEntry
        && menuEntry.buttonType !== QsMenuButtonType.None
    readonly property bool checked: menuEntry
        && menuEntry.checkState === Qt.Checked

    property bool expanded: false

    implicitWidth: 256
    implicitHeight: separator
        ? 9
        : entryButton.height + (expanded && hasChildren ? childEntries.implicitHeight : 0)

    onCloseRevisionChanged: expanded = false

    QsMenuOpener {
        id: childOpener
        menu: root.hasChildren ? root.menuEntry : null
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: root.luminaDesign.spacing.medium
            rightMargin: root.luminaDesign.spacing.medium
        }

        height: 1
        visible: root.separator
        color: root.luminaDesign.color.outline
        opacity: 0.55
    }

    Rectangle {
        id: entryButton

        width: parent.width
        height: root.separator ? 0 : 34
        visible: !root.separator
        radius: root.luminaDesign.shape.small
        opacity: root.entryEnabled ? 1.0 : 0.45
        scale: entryMouse.pressed ? 0.98 : 1.0
        color: entryMouse.pressed
            ? Qt.darker(root.luminaDesign.color.surfaceMuted, 1.12)
            : entryMouse.containsMouse
                ? root.luminaDesign.color.surfaceMuted
                : "transparent"

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

        Item {
            id: leadingArea

            anchors {
                left: parent.left
                leftMargin: root.luminaDesign.spacing.medium
                verticalCenter: parent.verticalCenter
            }

            width: root.luminaDesign.size.trayIcon
            height: root.luminaDesign.size.trayIcon

            Text {
                anchors.centerIn: parent
                visible: root.hasIndicator
                text: root.checked
                    ? root.menuEntry.buttonType === QsMenuButtonType.RadioButton
                        ? "●"
                        : "✓"
                    : root.menuEntry.buttonType === QsMenuButtonType.RadioButton
                        ? "○"
                        : "□"
                color: root.checked
                    ? root.luminaDesign.color.primary
                    : root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.labelMedium
                font.weight: Font.DemiBold
            }

            IconImage {
                anchors.fill: parent
                visible: !root.hasIndicator && String(source).length > 0
                source: root.menuEntry ? String(root.menuEntry.icon || "") : ""
                asynchronous: true
                mipmap: true
            }
        }

        Text {
            anchors {
                left: leadingArea.right
                right: childMarker.left
                leftMargin: root.luminaDesign.spacing.medium
                rightMargin: root.luminaDesign.spacing.small
                verticalCenter: parent.verticalCenter
            }

            text: root.menuEntry
                ? String(root.menuEntry.text || "").replace(/[\n\r]+/g, " ")
                : ""
            color: root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.labelMedium
            font.weight: root.checked ? Font.DemiBold : Font.Medium
        }

        Text {
            id: childMarker

            anchors {
                right: parent.right
                rightMargin: root.luminaDesign.spacing.medium
                verticalCenter: parent.verticalCenter
            }

            width: root.luminaDesign.size.trayIcon
            horizontalAlignment: Text.AlignHCenter
            text: root.hasChildren ? (root.expanded ? "⌄" : "›") : ""
            color: root.luminaDesign.color.textMuted
            font.pixelSize: root.luminaDesign.typography.titleMedium
            font.weight: Font.DemiBold
        }

        MouseArea {
            id: entryMouse

            anchors.fill: parent
            enabled: root.entryEnabled
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: {
                if (!root.menuEntry)
                    return

                if (root.hasChildren) {
                    root.expanded = !root.expanded
                } else {
                    root.menuEntry.triggered()
                    root.actionTriggered()
                }
            }
        }
    }

    Column {
        id: childEntries

        anchors {
            left: parent.left
            right: parent.right
            top: entryButton.bottom
            leftMargin: root.luminaDesign.spacing.medium
        }

        visible: root.expanded && root.hasChildren
        spacing: root.luminaDesign.spacing.extraSmall

        Repeater {
            model: childOpener.children

            delegate: Loader {
                id: childLoader

                required property var modelData

                width: childEntries.width
                active: childEntries.visible
                source: "TrayMenuEntry.qml"

                onLoaded: {
                    item.menuEntry = modelData
                    item.depth = root.depth + 1
                    item.closeRevision = Qt.binding(() => root.closeRevision)
                    item.actionTriggered.connect(() => root.actionTriggered())
                }
            }
        }
    }
}

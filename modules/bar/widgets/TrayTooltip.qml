pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design

PopupWindow {
    id: root

    property var anchorItem: null
    property string title: ""
    property string description: ""
    property bool shown: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool hasContent: title.length > 0 || description.length > 0

    visible: shown && hasContent && anchorItem !== null
    implicitWidth: Math.min(
        320,
        Math.max(
            160,
            Math.max(titleLabel.implicitWidth, descriptionLabel.implicitWidth)
                + luminaDesign.spacing.large * 2
        )
    )
    implicitHeight: tooltipContent.implicitHeight + luminaDesign.spacing.medium * 2
    color: "transparent"
    grabFocus: false

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: luminaDesign.spacing.small
    anchor.adjustment: PopupAdjustment.All

    Rectangle {
        anchors.fill: parent
        radius: root.luminaDesign.shape.medium
        color: root.luminaDesign.color.surfaceMuted
        border.width: 1
        border.color: root.luminaDesign.color.outline
        opacity: root.visible ? 1.0 : 0.0
        scale: root.visible ? 1.0 : 0.96

        Behavior on opacity {
            NumberAnimation {
                duration: root.luminaDesign.motion.fast
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.luminaDesign.motion.fast
                easing.type: Easing.OutCubic
            }
        }

        Column {
            id: tooltipContent

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: root.luminaDesign.spacing.medium
            }

            spacing: root.luminaDesign.spacing.extraSmall

            Text {
                id: titleLabel

                width: parent.width
                text: root.title
                visible: text.length > 0
                color: root.luminaDesign.color.onSurface
                wrapMode: Text.Wrap
                font.pixelSize: root.luminaDesign.typography.labelMedium
                font.weight: Font.DemiBold
            }

            Text {
                id: descriptionLabel

                width: parent.width
                text: root.description
                visible: text.length > 0
                color: root.luminaDesign.color.textMuted
                wrapMode: Text.Wrap
                font.pixelSize: root.luminaDesign.typography.labelSmall
            }
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.stores.config

Flickable {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens

    clip: true
    contentWidth: width
    contentHeight: contentColumn.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: contentColumn

        width: root.width
        spacing: root.luminaDesign.spacing.large

        Column {
            width: parent.width
            spacing: 3

            Text {
                text: "Bar"
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleLarge
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                text: "Status density and information shown in the shell bar"
                color: root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.labelMedium
                wrapMode: Text.WordWrap
            }
        }

        DashboardCard {
            width: parent.width
            height: 116
            accessibleName: "Bar settings"

            QuickToggle {
                anchors {
                    fill: parent
                    margins: root.luminaDesign.spacing.extraLarge
                }

                title: "Status details"
                detail: ConfigStore.showStatusDetails
                    ? "Show output and Niri state"
                    : "Use compact status"
                iconName: "view-more-horizontal-symbolic"
                symbol: "≡"
                checked: ConfigStore.showStatusDetails
                onToggled: ConfigStore.setShowStatusDetails(
                    !ConfigStore.showStatusDetails
                )
            }
        }

        Text {
            width: parent.width
            text: "Position, widget ordering, spacing, and per-monitor "
                + "behavior remain roadmap work."
            color: root.luminaDesign.color.textMuted
            font.pixelSize: root.luminaDesign.typography.labelSmall
            wrapMode: Text.WordWrap
        }
    }
}

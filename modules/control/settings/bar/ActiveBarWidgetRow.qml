import QtQuick
import qs.design
import qs.modules.control
import qs.services.i18n

Rectangle {
    id: root

    required property var widget
    property bool canMoveUp: false
    property bool canMoveDown: false

    signal configure(var sourceItem)
    signal moveUp
    signal moveDown
    signal remove

    readonly property var luminaDesign: Theme.luminaTokens

    implicitHeight: 72
    radius: luminaDesign.shape.largeIncreased
    color: luminaDesign.color.surfaceMuted

    Accessible.role: Accessible.Grouping
    Accessible.name: String(widget.title || widget.id)
    Accessible.description: String(widget.description || "")

    DashboardIcon {
        id: widgetIcon

        anchors {
            left: parent.left
            leftMargin: root.luminaDesign.spacing.large
            verticalCenter: parent.verticalCenter
        }
        iconName: String(root.widget.icon || "")
        fallbackSymbol: "•"
        iconColor: root.luminaDesign.color.primary
        iconSize: 22
    }

    Column {
        anchors {
            left: widgetIcon.right
            right: actions.left
            leftMargin: root.luminaDesign.spacing.medium
            rightMargin: root.luminaDesign.spacing.medium
            verticalCenter: parent.verticalCenter
        }
        spacing: 3

        Text {
            width: parent.width
            text: String(root.widget.title || root.widget.id)
            color: root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize:
                root.luminaDesign.typography.bodyMedium
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: String(root.widget.description || "")
            color: root.luminaDesign.color.textMuted
            elide: Text.ElideRight
            font.pixelSize:
                root.luminaDesign.typography.labelSmall
        }
    }

    Row {
        id: actions

        anchors {
            right: parent.right
            rightMargin: root.luminaDesign.spacing.medium
            verticalCenter: parent.verticalCenter
        }
        spacing: root.luminaDesign.spacing.small

        BarWidgetActionButton {
            id: configureButton

            visible: Boolean(root.widget.configurable)
            iconName: "emblem-system-symbolic"
            fallbackSymbol: "⚙"
            accessibleName: I18n.tr(
                "settings.bar.widget.configure",
                "Configure %1",
                [String(root.widget.title || root.widget.id)]
            )
            onClicked: root.configure(configureButton)
        }

        BarWidgetActionButton {
            iconName: "go-up-symbolic"
            fallbackSymbol: "↑"
            accessibleName: I18n.tr(
                "settings.bar.widget.moveUp",
                "Move %1 up",
                [String(root.widget.title || root.widget.id)]
            )
            actionEnabled: root.canMoveUp
            onClicked: root.moveUp()
        }

        BarWidgetActionButton {
            iconName: "go-down-symbolic"
            fallbackSymbol: "↓"
            accessibleName: I18n.tr(
                "settings.bar.widget.moveDown",
                "Move %1 down",
                [String(root.widget.title || root.widget.id)]
            )
            actionEnabled: root.canMoveDown
            onClicked: root.moveDown()
        }

        BarWidgetActionButton {
            iconName: "list-remove-symbolic"
            fallbackSymbol: "−"
            destructive: true
            accessibleName: I18n.tr(
                "settings.bar.widget.remove",
                "Remove %1 from the bar",
                [String(root.widget.title || root.widget.id)]
            )
            onClicked: root.remove()
        }
    }
}

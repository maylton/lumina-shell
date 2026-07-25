pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.services.config
import qs.services.i18n
import qs.stores.config
import qs.stores.control

DashboardCard {
    id: root

    property bool compact: false
    required property var categories

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property int selectedIndex: {
        for (var index = 0; index < categories.length; ++index) {
            if (String(categories[index].id)
                === ControlCenterStore.settingsCategory) {
                return index
            }
        }

        return 0
    }

    accessibleName: I18n.tr(
        "settings.sidebar.accessibleName",
        "Settings categories"
    )
    radius: luminaDesign.shape.extraLarge
    border.width: 0

    Column {
        anchors {
            fill: parent
            margins: root.luminaDesign.spacing.controlItemGap
        }

        spacing: root.luminaDesign.spacing.controlItemGap

        Rectangle {
            id: editButton

            width: parent.width
            height: 50
            radius: editMouse.pressed
                ? root.luminaDesign.shape.medium
                : root.luminaDesign.shape.extraLarge
            color: editMouse.pressed
                ? Qt.darker(
                    root.luminaDesign.color.accentContainer,
                    1.08
                )
                : root.luminaDesign.color.accentContainer
            activeFocusOnTab: true
            border.width: activeFocus ? 2 : 0
            border.color: root.luminaDesign.color.primary

            Behavior on radius {
                NumberAnimation {
                    duration: root.luminaDesign.motion.spatialFast
                    easing.type: root.luminaDesign.motion.spatialEasing
                    easing.overshoot:
                        root.luminaDesign.motion.spatialOvershoot
                }
            }

            Accessible.role: Accessible.Button
            Accessible.name: I18n.tr(
                "settings.sidebar.editConfig",
                "Edit config"
            )
            Accessible.description: ConfigStore.statePath
            Accessible.focusable: true
            Accessible.focused: activeFocus
            Accessible.onPressAction:
                ConfigFileService.openConfigFile()

            Keys.onSpacePressed: event => {
                ConfigFileService.openConfigFile()
                event.accepted = true
            }

            Keys.onReturnPressed: event => {
                ConfigFileService.openConfigFile()
                event.accepted = true
            }

            Row {
                anchors.centerIn: parent
                spacing: root.luminaDesign.spacing.controlItemGap

                DashboardIcon {
                    width: 20
                    height: 20
                    iconName: "document-edit-symbolic"
                    fallbackSymbol: "✎"
                    iconColor:
                        root.luminaDesign.color.onAccentContainer
                    iconSize: 18
                }

                Text {
                    visible: !root.compact
                    text: I18n.tr(
                        "settings.sidebar.editConfig",
                        "Edit config"
                    )
                    color:
                        root.luminaDesign.color.onAccentContainer
                    font.pixelSize:
                        root.luminaDesign.typography.bodyMedium
                    font.weight: Font.Bold
                }
            }

            MouseArea {
                id: editMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    editButton.forceActiveFocus(Qt.MouseFocusReason)
                    ConfigFileService.openConfigFile()
                }
            }

            Rectangle {
                visible: editMouse.containsMouse && !root.compact
                z: 20
                anchors {
                    left: parent.left
                    top: parent.bottom
                    topMargin: 4
                }
                width: Math.min(
                    390,
                    pathText.implicitWidth + 18
                )
                height: 28
                radius: root.luminaDesign.shape.medium
                color: root.luminaDesign.color.surfaceMuted
                border.width: 1
                border.color: root.luminaDesign.color.outline

                Text {
                    id: pathText

                    anchors {
                        fill: parent
                        margins: 7
                    }
                    text: ConfigStore.statePath
                    color: root.luminaDesign.color.textMuted
                    elide: Text.ElideMiddle
                    font.pixelSize:
                        root.luminaDesign.typography.labelSmall
                }
            }
        }

        Rectangle {
            id: folderButton

            width: parent.width
            height: 32
            radius: root.luminaDesign.shape.large
            color: folderMouse.containsMouse || activeFocus
                ? root.luminaDesign.color.surfaceMuted
                : "transparent"
            activeFocusOnTab: true
            border.width: activeFocus ? 2 : 0
            border.color: root.luminaDesign.color.primary

            Accessible.role: Accessible.Button
            Accessible.name: I18n.tr(
                "settings.sidebar.openConfigFolderAccessible",
                "Open config directory"
            )
            Accessible.description:
                ConfigFileService.configDirectory
            Accessible.onPressAction:
                ConfigFileService.openConfigDirectory()

            Keys.onSpacePressed: event => {
                ConfigFileService.openConfigDirectory()
                event.accepted = true
            }

            Keys.onReturnPressed: event => {
                ConfigFileService.openConfigDirectory()
                event.accepted = true
            }

            Row {
                anchors.centerIn: parent
                spacing: root.luminaDesign.spacing.small

                DashboardIcon {
                    width: 16
                    height: 16
                    iconName: "folder-open-symbolic"
                    fallbackSymbol: "▤"
                    iconColor: root.luminaDesign.color.textMuted
                    iconSize: 15
                }

                Text {
                    visible: !root.compact
                    text: I18n.tr(
                        "settings.sidebar.openConfigFolder",
                        "Open config folder"
                    )
                    color: root.luminaDesign.color.textMuted
                    font.pixelSize:
                        root.luminaDesign.typography.labelSmall
                    font.weight: Font.DemiBold
                }
            }

            MouseArea {
                id: folderMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ConfigFileService.openConfigDirectory()
            }
        }

        Rectangle {
            id: sidebarDivider

            width: parent.width
            height: 1
            color: root.luminaDesign.color.outline
            opacity: 0.5
        }

        ListView {
            id: categoryList

            width: parent.width
            height: Math.max(
                0,
                parent.height
                    - editButton.height
                    - folderButton.height
                    - sidebarDivider.height
                    - parent.spacing * 3
            )
            clip: true
            spacing: root.luminaDesign.spacing.controlItemGap
            model: root.categories
            currentIndex: root.selectedIndex
            boundsBehavior: Flickable.StopAtBounds
            keyNavigationEnabled: true

            onCurrentIndexChanged: {
                if (currentIndex >= 0)
                    positionViewAtIndex(currentIndex, ListView.Contain)
            }

            delegate: SettingsNavigationItem {
                required property var modelData

                width: ListView.view.width
                compact: root.compact
                label: String(modelData.label)
                description: String(modelData.description)
                iconName: String(modelData.iconName)
                symbol: String(modelData.symbol || "")
                selected:
                    ControlCenterStore.settingsCategory
                        === modelData.id
                onActivated:
                    ControlCenterStore.setSettingsCategory(
                        modelData.id
                    )
            }
        }
    }
}

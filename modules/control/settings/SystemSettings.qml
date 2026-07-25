pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.modules.control
import qs.stores.config
import qs.stores.settings

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

        Row {
            width: parent.width
            height: 46

            Column {
                width: parent.width - schemaChip.width
                    - root.luminaDesign.spacing.large
                spacing: 3

                Text {
                    text: "System"
                    color: root.luminaDesign.color.onSurface
                    font.pixelSize: root.luminaDesign.typography.titleLarge
                    font.weight: Font.Bold
                }

                Text {
                    text: "Configuration health and recovery"
                    color: root.luminaDesign.color.textMuted
                    font.pixelSize:
                        root.luminaDesign.typography.labelMedium
                }
            }

            Rectangle {
                id: schemaChip

                width: 112
                height: 32
                radius: root.luminaDesign.shape.full
                color: root.luminaDesign.color.surfaceMuted

                Text {
                    anchors.centerIn: parent
                    text: "Schema " + ConfigStore.schemaVersion
                    color: root.luminaDesign.color.textMuted
                    font.pixelSize:
                        root.luminaDesign.typography.labelSmall
                    font.weight: Font.DemiBold
                }
            }
        }

        DashboardCard {
            width: parent.width
            height: 112
            accessibleName: "Configuration health"

            Row {
                anchors {
                    fill: parent
                    margins: root.luminaDesign.spacing.extraLarge
                }

                spacing: root.luminaDesign.spacing.large

                DashboardIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28
                    height: 28
                    iconName: ConfigStore.recoveredInvalidConfiguration
                        ? "dialog-warning-symbolic"
                        : "emblem-default-symbolic"
                    fallbackSymbol:
                        ConfigStore.recoveredInvalidConfiguration
                            ? "!"
                            : "✓"
                    iconColor:
                        ConfigStore.recoveredInvalidConfiguration
                            ? root.luminaDesign.color.urgent
                            : root.luminaDesign.color.primary
                    iconSize: 20
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 42
                    spacing: 4

                    Text {
                        text: ConfigStore.recoveredInvalidConfiguration
                            ? "Configuration recovered"
                            : "Configuration healthy"
                        color: root.luminaDesign.color.onSurface
                        font.pixelSize:
                            root.luminaDesign.typography.bodyMedium
                        font.weight: Font.DemiBold
                    }

                    Text {
                        width: parent.width
                        text: ConfigStore.recoveredInvalidConfiguration
                            ? ConfigStore.recoveryBackupPath
                            : ConfigStore.statePath
                        color: root.luminaDesign.color.textMuted
                        elide: Text.ElideMiddle
                        font.pixelSize:
                            root.luminaDesign.typography.labelSmall
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 54
            radius: root.luminaDesign.shape.large
            color: SettingsStore.resetConfirmation
                ? Qt.rgba(1, 0.35, 0.32, 0.18)
                : root.luminaDesign.color.surfaceMuted
            border.width: activeFocus ? 2 : 1
            border.color: SettingsStore.resetConfirmation
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.outline
            activeFocusOnTab: true

            function activate() {
                if (SettingsStore.resetConfirmation)
                    SettingsStore.confirmReset()
                else
                    SettingsStore.requestReset()
            }

            Accessible.role: Accessible.Button
            Accessible.name: SettingsStore.resetConfirmation
                ? "Confirm reset settings"
                : "Reset settings"
            Accessible.onPressAction: activate()

            Keys.onSpacePressed: event => {
                activate()
                event.accepted = true
            }

            Keys.onReturnPressed: event => {
                activate()
                event.accepted = true
            }

            Text {
                anchors.centerIn: parent
                text: SettingsStore.resetConfirmation
                    ? "Click again to restore defaults"
                    : "Restore default settings"
                color: SettingsStore.resetConfirmation
                    ? root.luminaDesign.color.urgent
                    : root.luminaDesign.color.onSurface
                font.pixelSize:
                    root.luminaDesign.typography.bodyMedium
                font.weight: Font.DemiBold
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    parent.forceActiveFocus(Qt.MouseFocusReason)
                    parent.activate()
                }
            }
        }

        Text {
            width: parent.width
            text: "Reset uses a two-step confirmation and restores only "
                + "Lumina's persisted configuration."
            color: root.luminaDesign.color.textMuted
            font.pixelSize: root.luminaDesign.typography.labelSmall
            wrapMode: Text.WordWrap
        }
    }
}

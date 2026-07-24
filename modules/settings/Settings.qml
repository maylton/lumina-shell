pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.design
import qs.modules.control
import qs.services.notifications
import qs.services.wallpaper
import qs.stores.config
import qs.stores.settings

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var osdDurations: [
        {
            value: 1200,
            label: "Short"
        },
        {
            value: 1800,
            label: "Normal"
        },
        {
            value: 3000,
            label: "Long"
        }
    ]

    IpcHandler {
        target: "settings"

        function open(outputName: string): void {
            SettingsStore.openFor(outputName)
        }

        function close(): void {
            SettingsStore.close()
        }

        function toggle(outputName: string): void {
            SettingsStore.toggle(outputName)
        }

        function status(): string {
            return JSON.stringify({
                open: SettingsStore.open,
                output: SettingsStore.activeOutputName,
                resetConfirmation: SettingsStore.resetConfirmation
            })
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: settingsWindow

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property bool settingsVisible:
                    SettingsStore.activeOutputName === outputName

                property string directoryDraft:
                    ConfigStore.wallpaperDirectory

                screen: modelData
                visible: settingsVisible
                implicitWidth: root.luminaDesign.size.settingsWidth
                implicitHeight: Math.min(
                    root.luminaDesign.size.settingsHeight,
                    modelData.height - root.luminaDesign.size.barHeight - 24
                )
                color: "transparent"
                focusable: settingsVisible
                exclusiveZone: 0

                anchors {
                    top: true
                    right: true
                }

                margins {
                    top: root.luminaDesign.size.barHeight + 8
                    right: 8
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lumina-settings"
                WlrLayershell.keyboardFocus: settingsVisible
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                onSettingsVisibleChanged: {
                    if (settingsVisible) {
                        directoryDraft =
                            ConfigStore.wallpaperDirectory
                    }
                }

                FocusScope {
                    anchors.fill: parent
                    focus: settingsWindow.settingsVisible

                    Keys.onEscapePressed: event => {
                        if (SettingsStore.resetConfirmation)
                            SettingsStore.cancelReset()
                        else
                            SettingsStore.close()

                        event.accepted = true
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: root.luminaDesign.shape.extraLarge
                    color: root.luminaDesign.color.surfaceContainer
                    border.width: 1
                    border.color: root.luminaDesign.color.outline

                    Column {
                        anchors {
                            fill: parent
                            margins: root.luminaDesign.spacing.extraLarge
                        }

                        spacing: root.luminaDesign.spacing.large

                        Row {
                            width: parent.width
                            height: 44

                            Column {
                                width: parent.width - 42

                                Text {
                                    text: "Lumina settings"
                                    color: root.luminaDesign.color.onSurface
                                    font.pixelSize:
                                        root.luminaDesign.typography.titleLarge
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: "Configuration schema "
                                        + ConfigStore.schemaVersion
                                    color: root.luminaDesign.color.textMuted
                                    font.pixelSize:
                                        root.luminaDesign.typography.labelSmall
                                }
                            }

                            Rectangle {
                                width: 34
                                height: 34
                                radius: root.luminaDesign.shape.full
                                activeFocusOnTab: true
                                color: settingsCloseMouse.containsMouse
                                    ? root.luminaDesign.color.accentContainer
                                    : root.luminaDesign.color.surfaceMuted
                                border.width: activeFocus ? 2 : 0
                                border.color: root.luminaDesign.color.primary

                                Accessible.role: Accessible.Button
                                Accessible.name: "Close settings"
                                Accessible.focusable: true
                                Accessible.focused: activeFocus
                                Accessible.onPressAction:
                                    SettingsStore.close()

                                Keys.onSpacePressed: event => {
                                    SettingsStore.close()
                                    event.accepted = true
                                }

                                Keys.onReturnPressed: event => {
                                    SettingsStore.close()
                                    event.accepted = true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "×"
                                    color: root.luminaDesign.color.onSurface
                                    font.pixelSize: 20
                                }

                                MouseArea {
                                    id: settingsCloseMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        parent.forceActiveFocus(
                                            Qt.MouseFocusReason
                                        )
                                        SettingsStore.close()
                                    }
                                }
                            }
                        }

                        Text {
                            text: "Appearance"
                            color: root.luminaDesign.color.primary
                            font.pixelSize:
                                root.luminaDesign.typography.titleMedium
                            font.weight: Font.DemiBold
                        }

                        Grid {
                            width: parent.width
                            columns: 2
                            columnSpacing: root.luminaDesign.spacing.medium
                            rowSpacing: root.luminaDesign.spacing.medium

                            QuickToggle {
                                width: (
                                    parent.width - parent.columnSpacing
                                ) / 2
                                title: "Dynamic color"
                                detail: ConfigStore.dynamicTheme
                                    ? "Wallpaper palette"
                                    : "Static palette"
                                symbol: "✦"
                                checked: ConfigStore.dynamicTheme
                                onToggled:
                                    WallpaperService.setDynamicTheme(
                                        !ConfigStore.dynamicTheme
                                    )
                            }

                            QuickToggle {
                                width: (
                                    parent.width - parent.columnSpacing
                                ) / 2
                                title: "Bar details"
                                detail: ConfigStore.showStatusDetails
                                    ? "Output and Niri state"
                                    : "Compact status"
                                symbol: "≡"
                                checked: ConfigStore.showStatusDetails
                                onToggled:
                                    ConfigStore.setShowStatusDetails(
                                        !ConfigStore.showStatusDetails
                                    )
                            }

                            QuickToggle {
                                width: (
                                    parent.width - parent.columnSpacing
                                ) / 2
                                title: "On-screen display"
                                detail: ConfigStore.osdEnabled
                                    ? "Volume and brightness"
                                    : "Hidden"
                                symbol: "▰"
                                checked: ConfigStore.osdEnabled
                                onToggled: ConfigStore.setOsdEnabled(
                                    !ConfigStore.osdEnabled
                                )
                            }

                            QuickToggle {
                                width: (
                                    parent.width - parent.columnSpacing
                                ) / 2
                                title: "Do Not Disturb"
                                detail: ConfigStore.doNotDisturb
                                    ? "Popups paused"
                                    : "Popups allowed"
                                symbol: "◐"
                                checked: ConfigStore.doNotDisturb
                                onToggled:
                                    NotificationService.toggleDoNotDisturb()
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: root.luminaDesign.spacing.small

                            Text {
                                text: "OSD duration"
                                color: root.luminaDesign.color.onSurface
                                font.pixelSize:
                                    root.luminaDesign.typography.bodyMedium
                                font.weight: Font.DemiBold
                            }

                            Row {
                                width: parent.width
                                spacing: root.luminaDesign.spacing.small

                                Repeater {
                                    model: root.osdDurations

                                    delegate: Rectangle {
                                        id: durationButton

                                        required property var modelData
                                        readonly property bool selected:
                                            ConfigStore.osdDuration
                                                === modelData.value

                                        width: (
                                            parent.width
                                                - parent.spacing * 2
                                        ) / 3
                                        height: 38
                                        activeFocusOnTab: true
                                        radius: selected
                                            ? root.luminaDesign.shape.full
                                            : root.luminaDesign.shape.medium
                                        color: selected
                                            ? root.luminaDesign.color.accentContainer
                                            : root.luminaDesign.color.surfaceMuted
                                        border.width: activeFocus ? 2 : 0
                                        border.color:
                                            root.luminaDesign.color.primary

                                        Accessible.role: Accessible.RadioButton
                                        Accessible.name:
                                            modelData.label + " OSD duration"
                                        Accessible.checked: selected
                                        Accessible.focusable: true
                                        Accessible.focused: activeFocus
                                        Accessible.onPressAction:
                                            ConfigStore.setOsdDuration(
                                                modelData.value
                                            )

                                        Keys.onSpacePressed: event => {
                                            ConfigStore.setOsdDuration(
                                                modelData.value
                                            )
                                            event.accepted = true
                                        }

                                        Keys.onReturnPressed: event => {
                                            ConfigStore.setOsdDuration(
                                                modelData.value
                                            )
                                            event.accepted = true
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text:
                                                durationButton.modelData.label
                                            color: durationButton.selected
                                                ? root.luminaDesign.color.onAccentContainer
                                                : root.luminaDesign.color.onSurface
                                            font.pixelSize:
                                                root.luminaDesign.typography.labelSmall
                                            font.weight: Font.DemiBold
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                durationButton.forceActiveFocus(
                                                    Qt.MouseFocusReason
                                                )
                                                ConfigStore.setOsdDuration(
                                                    durationButton.modelData.value
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: root.luminaDesign.spacing.small

                            Text {
                                text: "Wallpaper directory"
                                color: root.luminaDesign.color.onSurface
                                font.pixelSize:
                                    root.luminaDesign.typography.bodyMedium
                                font.weight: Font.DemiBold
                            }

                            Row {
                                width: parent.width
                                spacing: root.luminaDesign.spacing.small

                                Rectangle {
                                    width: parent.width - 74
                                    height: 42
                                    radius: root.luminaDesign.shape.medium
                                    color:
                                        root.luminaDesign.color.surfaceMuted
                                    border.width:
                                        directoryInput.activeFocus ? 2 : 1
                                    border.color:
                                        directoryInput.activeFocus
                                            ? root.luminaDesign.color.primary
                                            : root.luminaDesign.color.outline

                                    TextInput {
                                        id: directoryInput

                                        anchors {
                                            fill: parent
                                            margins:
                                                root.luminaDesign.spacing.medium
                                        }

                                        text:
                                            settingsWindow.directoryDraft
                                        color:
                                            root.luminaDesign.color.onSurface
                                        selectionColor:
                                            root.luminaDesign.color.accentContainer
                                        selectedTextColor:
                                            root.luminaDesign.color.onAccentContainer
                                        clip: true
                                        activeFocusOnTab: true
                                        font.pixelSize:
                                            root.luminaDesign.typography.bodyMedium
                                        onTextEdited:
                                            settingsWindow.directoryDraft = text

                                        Accessible.role:
                                            Accessible.EditableText
                                        Accessible.name:
                                            "Wallpaper directory"
                                    }
                                }

                                Rectangle {
                                    width: 66
                                    height: 42
                                    radius: root.luminaDesign.shape.full
                                    activeFocusOnTab: true
                                    color: saveDirectoryMouse.containsMouse
                                        ? root.luminaDesign.color.primary
                                        : root.luminaDesign.color.accentContainer
                                    border.width: activeFocus ? 2 : 0
                                    border.color:
                                        root.luminaDesign.color.primary

                                    Accessible.role: Accessible.Button
                                    Accessible.name:
                                        "Save wallpaper directory"
                                    Accessible.focusable: true
                                    Accessible.focused: activeFocus
                                    Accessible.onPressAction:
                                        WallpaperService.setWallpaperDirectory(
                                            settingsWindow.directoryDraft
                                        )

                                    Keys.onSpacePressed: event => {
                                        WallpaperService.setWallpaperDirectory(
                                            settingsWindow.directoryDraft
                                        )
                                        event.accepted = true
                                    }

                                    Keys.onReturnPressed: event => {
                                        WallpaperService.setWallpaperDirectory(
                                            settingsWindow.directoryDraft
                                        )
                                        event.accepted = true
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Save"
                                        color:
                                            root.luminaDesign.color.onAccentContainer
                                        font.pixelSize:
                                            root.luminaDesign.typography.labelMedium
                                        font.weight: Font.Bold
                                    }

                                    MouseArea {
                                        id: saveDirectoryMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            parent.forceActiveFocus(
                                                Qt.MouseFocusReason
                                            )
                                            WallpaperService.setWallpaperDirectory(
                                                settingsWindow.directoryDraft
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 76
                            radius: root.luminaDesign.shape.large
                            color: ConfigStore.recoveredInvalidConfiguration
                                ? Qt.rgba(1, 0.55, 0.35, 0.15)
                                : root.luminaDesign.color.surfaceMuted
                            border.width:
                                ConfigStore.recoveredInvalidConfiguration
                                    ? 1
                                    : 0
                            border.color: root.luminaDesign.color.urgent

                            Column {
                                anchors {
                                    fill: parent
                                    margins: root.luminaDesign.spacing.medium
                                }

                                spacing: 2

                                Text {
                                    width: parent.width
                                    text:
                                        ConfigStore.recoveredInvalidConfiguration
                                            ? "Configuration recovered"
                                            : "Configuration healthy"
                                    color: root.luminaDesign.color.onSurface
                                    font.pixelSize:
                                        root.luminaDesign.typography.bodyMedium
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    width: parent.width
                                    text:
                                        ConfigStore.recoveredInvalidConfiguration
                                            ? "Backup: "
                                                + ConfigStore.recoveryBackupPath
                                            : ConfigStore.statePath
                                    color: root.luminaDesign.color.textMuted
                                    elide: Text.ElideMiddle
                                    font.pixelSize:
                                        root.luminaDesign.typography.labelSmall
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 52
                            activeFocusOnTab: true
                            radius: SettingsStore.resetConfirmation
                                ? root.luminaDesign.shape.extraLarge
                                : root.luminaDesign.shape.large
                            color: SettingsStore.resetConfirmation
                                ? Qt.rgba(1, 0.35, 0.32, 0.18)
                                : root.luminaDesign.color.surfaceMuted
                            border.width: activeFocus ? 2 : 1
                            border.color: SettingsStore.resetConfirmation
                                ? root.luminaDesign.color.urgent
                                : root.luminaDesign.color.outline

                            Accessible.role: Accessible.Button
                            Accessible.name: SettingsStore.resetConfirmation
                                ? "Confirm reset settings"
                                : "Reset settings"
                            Accessible.focusable: true
                            Accessible.focused: activeFocus
                            Accessible.onPressAction: {
                                if (SettingsStore.resetConfirmation)
                                    SettingsStore.confirmReset()
                                else
                                    SettingsStore.requestReset()
                            }

                            Keys.onSpacePressed: event => {
                                if (SettingsStore.resetConfirmation)
                                    SettingsStore.confirmReset()
                                else
                                    SettingsStore.requestReset()

                                event.accepted = true
                            }

                            Keys.onReturnPressed: event => {
                                if (SettingsStore.resetConfirmation)
                                    SettingsStore.confirmReset()
                                else
                                    SettingsStore.requestReset()

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
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    parent.forceActiveFocus(
                                        Qt.MouseFocusReason
                                    )

                                    if (SettingsStore.resetConfirmation)
                                        SettingsStore.confirmReset()
                                    else
                                        SettingsStore.requestReset()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

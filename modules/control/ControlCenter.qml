pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.design
import qs.services.audio
import qs.services.brightness
import qs.services.connectivity
import qs.services.media
import qs.services.notifications
import qs.services.power
import qs.services.wallpaper
import qs.stores.control
import qs.stores.settings

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var powerProfiles: [
        {
            id: "power-saver",
            label: "Saver"
        },
        {
            id: "balanced",
            label: "Balanced"
        },
        {
            id: "performance",
            label: "Performance"
        }
    ]

    IpcHandler {
        target: "control"

        function open(outputName: string): void {
            ControlCenterStore.openFor(outputName)
        }

        function close(): void {
            ControlCenterStore.close()
        }

        function toggle(outputName: string): void {
            ControlCenterStore.toggle(outputName)
        }

        function status(): string {
            return JSON.stringify({
                open: ControlCenterStore.open,
                output: ControlCenterStore.activeOutputName
            })
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: controlWindow

                required property var modelData
                readonly property string outputName: modelData && modelData.name
                    ? String(modelData.name)
                    : ""
                readonly property bool centerVisible:
                    ControlCenterStore.activeOutputName === outputName

                screen: modelData
                visible: centerVisible
                implicitWidth: root.luminaDesign.size.controlCenterWidth
                implicitHeight: Math.min(
                    root.luminaDesign.size.controlCenterHeight,
                    modelData.height - root.luminaDesign.size.barHeight - 24
                )
                color: "transparent"
                focusable: centerVisible
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
                WlrLayershell.namespace: "lumina-control-center"
                WlrLayershell.keyboardFocus: centerVisible
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                FocusScope {
                    anchors.fill: parent
                    focus: controlWindow.centerVisible

                    Keys.onEscapePressed: event => {
                        ControlCenterStore.close()
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

                        spacing: root.luminaDesign.spacing.medium

                        Row {
                            width: parent.width
                            height: 38

                            Column {
                                width: parent.width - 42

                                Text {
                                    text: "Quick settings"
                                    color: root.luminaDesign.color.onSurface
                                    font.pixelSize:
                                        root.luminaDesign.typography.titleLarge
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: ConnectivityService.networkSummary
                                        + " · "
                                        + PowerService.profileName
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
                                color: closeMouse.containsMouse
                                    ? root.luminaDesign.color.accentContainer
                                    : root.luminaDesign.color.surfaceMuted
                                border.width: activeFocus ? 2 : 0
                                border.color: root.luminaDesign.color.primary

                                Accessible.role: Accessible.Button
                                Accessible.name: "Close quick settings"
                                Accessible.focusable: true
                                Accessible.focused: activeFocus
                                Accessible.onPressAction:
                                    ControlCenterStore.close()

                                Keys.onSpacePressed: event => {
                                    ControlCenterStore.close()
                                    event.accepted = true
                                }

                                Keys.onReturnPressed: event => {
                                    ControlCenterStore.close()
                                    event.accepted = true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "×"
                                    color: root.luminaDesign.color.onSurface
                                    font.pixelSize: 20
                                }

                                MouseArea {
                                    id: closeMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        parent.forceActiveFocus(
                                            Qt.MouseFocusReason
                                        )
                                        ControlCenterStore.close()
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 94
                            radius: root.luminaDesign.shape.large
                            color: root.luminaDesign.color.surfaceMuted

                            Row {
                                anchors {
                                    fill: parent
                                    margins: root.luminaDesign.spacing.large
                                }

                                spacing: root.luminaDesign.spacing.medium

                                Rectangle {
                                    width: 62
                                    height: 62
                                    radius: root.luminaDesign.shape.large
                                    color: root.luminaDesign.color.accentContainer

                                    Image {
                                        anchors.fill: parent
                                        source: MediaService.artUrl
                                        fillMode: Image.PreserveAspectCrop
                                        visible: MediaService.artUrl.length > 0
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: !MediaService.artUrl
                                        text: "♪"
                                        color: root.luminaDesign.color.onAccentContainer
                                        font.pixelSize: 28
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 162
                                    spacing: 2

                                    Text {
                                        width: parent.width
                                        text: MediaService.available
                                            ? MediaService.title
                                            : "Nothing playing"
                                        color: root.luminaDesign.color.onSurface
                                        elide: Text.ElideRight
                                        font.pixelSize:
                                            root.luminaDesign.typography.bodyMedium
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        width: parent.width
                                        text: MediaService.available
                                            ? MediaService.artist
                                                || MediaService.identity
                                            : "MPRIS players appear here"
                                        color: root.luminaDesign.color.textMuted
                                        elide: Text.ElideRight
                                        font.pixelSize:
                                            root.luminaDesign.typography.labelSmall
                                    }
                                }

                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4

                                    Repeater {
                                        model: [
                                            {
                                                symbol: "‹",
                                                action: "previous",
                                                enabled: MediaService.available
                                                    && MediaService.activePlayer
                                                    && MediaService.activePlayer.canGoPrevious
                                            },
                                            {
                                                symbol: MediaService.playing
                                                    ? "Ⅱ"
                                                    : "▶",
                                                action: "toggle",
                                                enabled: MediaService.available
                                                    && MediaService.activePlayer
                                                    && MediaService.activePlayer.canTogglePlaying
                                            },
                                            {
                                                symbol: "›",
                                                action: "next",
                                                enabled: MediaService.available
                                                    && MediaService.activePlayer
                                                    && MediaService.activePlayer.canGoNext
                                            }
                                        ]

                                        delegate: Rectangle {
                                            id: mediaAction

                                            required property var modelData

                                            width: 28
                                            height: 28
                                            activeFocusOnTab:
                                                modelData.enabled
                                            radius: root.luminaDesign.shape.full
                                            opacity: modelData.enabled ? 1 : 0.4
                                            color: mediaMouse.containsMouse
                                                ? root.luminaDesign.color.accentContainer
                                                : "transparent"
                                            border.width: activeFocus ? 2 : 0
                                            border.color:
                                                root.luminaDesign.color.primary

                                            Accessible.role: Accessible.Button
                                            Accessible.name:
                                                "Media " + modelData.action
                                            Accessible.focusable:
                                                modelData.enabled
                                            Accessible.focused: activeFocus
                                            Accessible.onPressAction:
                                                mediaAction.invoke()

                                            function invoke() {
                                                switch (modelData.action) {
                                                case "previous":
                                                    MediaService.previous()
                                                    break
                                                case "next":
                                                    MediaService.next()
                                                    break
                                                default:
                                                    MediaService.toggle()
                                                    break
                                                }
                                            }

                                            Keys.onSpacePressed: event => {
                                                mediaAction.invoke()
                                                event.accepted = true
                                            }

                                            Keys.onReturnPressed: event => {
                                                mediaAction.invoke()
                                                event.accepted = true
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                text: mediaAction.modelData.symbol
                                                color:
                                                    root.luminaDesign.color.onSurface
                                                font.pixelSize: 16
                                                font.weight: Font.Bold
                                            }

                                            MouseArea {
                                                id: mediaMouse

                                                anchors.fill: parent
                                                enabled:
                                                    mediaAction.modelData.enabled
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    mediaAction.forceActiveFocus(
                                                        Qt.MouseFocusReason
                                                    )
                                                    mediaAction.invoke()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        ControlSlider {
                            width: parent.width
                            title: AudioService.outputMuted
                                ? "Output muted"
                                : "Output volume"
                            symbol: AudioService.outputMuted ? "×" : "♪"
                            detail: AudioService.outputAvailable
                                ? Math.round(
                                    AudioService.outputVolume * 100
                                ) + "%"
                                : "Unavailable"
                            value: AudioService.outputVolume
                            available: AudioService.outputAvailable
                            onValueRequested: value =>
                                AudioService.setOutputVolume(value)
                        }

                        ControlSlider {
                            width: parent.width
                            title: AudioService.inputMuted
                                ? "Microphone muted"
                                : "Microphone"
                            symbol: AudioService.inputMuted ? "×" : "●"
                            detail: AudioService.inputAvailable
                                ? Math.round(
                                    AudioService.inputVolume * 100
                                ) + "%"
                                : "Unavailable"
                            value: AudioService.inputVolume
                            available: AudioService.inputAvailable
                            onValueRequested: value =>
                                AudioService.setInputVolume(value)
                        }

                        ControlSlider {
                            width: parent.width
                            title: "Brightness"
                            symbol: "☀"
                            detail: BrightnessService.available
                                ? BrightnessService.percentage + "%"
                                : "No backlight"
                            value: BrightnessService.percentage / 100
                            available: BrightnessService.available
                            onValueRequested: value =>
                                BrightnessService.setPercentage(value * 100)
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
                                title: "Wi-Fi"
                                detail: ConnectivityService.wifiName
                                symbol: "◉"
                                checked: ConnectivityService.wifiEnabled
                                available: ConnectivityService.wifiAvailable
                                onToggled:
                                    ConnectivityService.toggleWifi()
                            }

                            QuickToggle {
                                width: (
                                    parent.width - parent.columnSpacing
                                ) / 2
                                title: "Bluetooth"
                                detail:
                                    ConnectivityService.bluetoothSummary
                                symbol: "ᛒ"
                                checked:
                                    ConnectivityService.bluetoothEnabled
                                available:
                                    ConnectivityService.bluetoothAvailable
                                onToggled:
                                    ConnectivityService.toggleBluetooth()
                            }

                            QuickToggle {
                                width: (
                                    parent.width - parent.columnSpacing
                                ) / 2
                                title: "Do Not Disturb"
                                detail: NotificationService.doNotDisturb
                                    ? "Popups paused"
                                    : "Popups allowed"
                                symbol: "◐"
                                checked:
                                    NotificationService.doNotDisturb
                                onToggled:
                                    NotificationService.toggleDoNotDisturb()
                            }

                            QuickToggle {
                                width: (
                                    parent.width - parent.columnSpacing
                                ) / 2
                                title: "Dynamic color"
                                detail: WallpaperService.dynamicThemeEnabled
                                    ? "Wallpaper palette"
                                    : "Lumina palette"
                                symbol: "✦"
                                checked: WallpaperService.dynamicThemeEnabled
                                onToggled:
                                    WallpaperService.setDynamicTheme(
                                        !WallpaperService.dynamicThemeEnabled
                                    )
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: root.luminaDesign.spacing.small

                            Row {
                                width: parent.width

                                Text {
                                    width: parent.width / 2
                                    text: "Power profile"
                                    color: root.luminaDesign.color.onSurface
                                    font.pixelSize:
                                        root.luminaDesign.typography.bodyMedium
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    width: parent.width / 2
                                    horizontalAlignment: Text.AlignRight
                                    text: PowerService.batteryAvailable
                                        ? PowerService.batteryPercentage + "%"
                                            + " · "
                                            + PowerService.batteryState
                                        : "AC power"
                                    color: root.luminaDesign.color.textMuted
                                    font.pixelSize:
                                        root.luminaDesign.typography.labelSmall
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: root.luminaDesign.spacing.small

                                Repeater {
                                    model: root.powerProfiles

                                    delegate: Rectangle {
                                        id: profileButton

                                        required property var modelData
                                        readonly property bool selected:
                                            PowerService.profileName
                                                === modelData.id
                                        readonly property bool available:
                                            modelData.id !== "performance"
                                                || PowerService.performanceAvailable

                                        width: (
                                            parent.width
                                                - parent.spacing * 2
                                        ) / 3
                                        height: 38
                                        activeFocusOnTab: available
                                        radius: selected
                                            ? root.luminaDesign.shape.full
                                            : root.luminaDesign.shape.medium
                                        opacity: available ? 1 : 0.45
                                        color: selected
                                            ? root.luminaDesign.color.accentContainer
                                            : root.luminaDesign.color.surfaceMuted
                                        border.width: activeFocus ? 2 : 0
                                        border.color:
                                            root.luminaDesign.color.primary

                                        Accessible.role: Accessible.RadioButton
                                        Accessible.name:
                                            modelData.label + " power profile"
                                        Accessible.checked: selected
                                        Accessible.focusable: available
                                        Accessible.focused: activeFocus
                                        Accessible.onPressAction:
                                            PowerService.setProfile(
                                                modelData.id
                                            )

                                        Keys.onSpacePressed: event => {
                                            PowerService.setProfile(modelData.id)
                                            event.accepted = true
                                        }

                                        Keys.onReturnPressed: event => {
                                            PowerService.setProfile(modelData.id)
                                            event.accepted = true
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text:
                                                profileButton.modelData.label
                                            color: profileButton.selected
                                                ? root.luminaDesign.color.onAccentContainer
                                                : root.luminaDesign.color.onSurface
                                            font.pixelSize:
                                                root.luminaDesign.typography.labelSmall
                                            font.weight: Font.DemiBold
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            enabled: profileButton.available
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                profileButton.forceActiveFocus(
                                                    Qt.MouseFocusReason
                                                )
                                                PowerService.setProfile(
                                                    profileButton.modelData.id
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 42
                            radius: root.luminaDesign.shape.full
                            activeFocusOnTab: true
                            color: settingsMouse.containsMouse
                                ? root.luminaDesign.color.primary
                                : root.luminaDesign.color.accentContainer
                            border.width: activeFocus ? 2 : 0
                            border.color: root.luminaDesign.color.primary

                            Accessible.role: Accessible.Button
                            Accessible.name: "Open Lumina settings"
                            Accessible.focusable: true
                            Accessible.focused: activeFocus
                            Accessible.onPressAction: SettingsStore.openFor(
                                controlWindow.outputName
                            )

                            Keys.onSpacePressed: event => {
                                SettingsStore.openFor(
                                    controlWindow.outputName
                                )
                                event.accepted = true
                            }

                            Keys.onReturnPressed: event => {
                                SettingsStore.openFor(
                                    controlWindow.outputName
                                )
                                event.accepted = true
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "Open Lumina settings"
                                color:
                                    root.luminaDesign.color.onAccentContainer
                                font.pixelSize:
                                    root.luminaDesign.typography.labelMedium
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                id: settingsMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    parent.forceActiveFocus(
                                        Qt.MouseFocusReason
                                    )
                                    SettingsStore.openFor(
                                        controlWindow.outputName
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

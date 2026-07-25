pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.modules.control.settings
import qs.services.i18n
import qs.services.wallpaper
import qs.stores.config

SettingsPage {
    id: root

    required property string outputName

    readonly property string currentWallpaper:
        WallpaperService.wallpaperFor(outputName)
    readonly property var paletteOptions: [
        { value: "auto", label: "Auto" },
        { value: "content", label: "Content" },
        { value: "expressive", label: "Expressive" },
        { value: "fidelity", label: "Fidelity" },
        { value: "fruit-salad", label: "Fruit Salad" },
        { value: "monochrome", label: "Monochrome" },
        { value: "neutral", label: "Neutral" },
        { value: "rainbow", label: "Rainbow" },
        { value: "tonal-spot", label: "Tonal Spot" }
    ]

    function wallpaperFileName(path) {
        const value = String(path || "")
        const separator = value.lastIndexOf("/")

        return separator >= 0 ? value.slice(separator + 1) : value
    }

    function paletteLabel(value) {
        for (var index = 0; index < paletteOptions.length; ++index) {
            if (paletteOptions[index].value === value)
                return paletteOptions[index].label
        }

        return "Auto"
    }

    title: I18n.tr(
        "settings.category.appearance.label",
        "Appearance"
    )
    description: I18n.tr(
        "settings.page.appearance.description",
        "Colors, wallpaper, and the visual language of Lumina"
    )

    SettingsSection {
        title: "Theme mode"
        groupedRows: false
        description: ConfigStore.themeMode === "auto"
            ? "Auto uses Lumina's predictable dark fallback on this runtime"
            : "Choose Lumina's complete light or dark tonal scheme"

        Row {
            width: parent.width
            height: 154
            spacing: root.luminaDesign.spacing.medium

            ThemePreviewCard {
                width: (parent.width - parent.spacing) / 2
                height: parent.height
                label: "Light"
                mode: "light"
                selected: ConfigStore.themeMode === "light"
                onActivated: ConfigStore.setThemeMode("light")
            }

            ThemePreviewCard {
                width: (parent.width - parent.spacing) / 2
                height: parent.height
                label: "Dark"
                mode: "dark"
                selected: ConfigStore.themeMode === "dark"
                onActivated: ConfigStore.setThemeMode("dark")
            }
        }

        SettingsSegmentedControl {
            width: parent.width
            height: 40
            options: [
                { value: "auto", label: "Auto" },
                { value: "light", label: "Light" },
                { value: "dark", label: "Dark" }
            ]
            currentValue: ConfigStore.themeMode
            onSelected: value => ConfigStore.setThemeMode(value)
        }
    }

    SettingsSection {
        title: "Material palette"
        groupedRows: false
        description: Theme.dynamicPaletteActive
            ? root.paletteLabel(ConfigStore.paletteStyle)
                + " accents and tonal surfaces from the active wallpaper"
            : "Lumina's default semantic accent colors are active"

        SettingsSwitchRow {
            width: parent.width
            title: "Wallpaper palette"
            description: checked
                ? "Dynamic Material colors enabled"
                : "Lumina default palette"
            iconName: "applications-graphics-symbolic"
            symbol: "✦"
            checked: ConfigStore.dynamicTheme
            onToggled: value =>
                WallpaperService.setDynamicTheme(value)
        }

        Grid {
            id: paletteGrid

            readonly property real cellWidth: (
                width - spacing * Math.max(0, columns - 1)
            ) / columns

            width: parent.width
            height: Math.ceil(root.paletteOptions.length / columns) * 58
                + Math.max(0, Math.ceil(
                    root.paletteOptions.length / columns
                ) - 1) * spacing
            columns: width < 760 ? 2 : 3
            spacing: root.luminaDesign.spacing.small
            opacity: ConfigStore.dynamicTheme ? 1 : 0.5
            enabled: ConfigStore.dynamicTheme

            Repeater {
                model: root.paletteOptions

                delegate: Rectangle {
                    id: paletteOption

                    required property var modelData
                    readonly property bool selected:
                        String(modelData.value)
                            === ConfigStore.paletteStyle

                    width: paletteGrid.cellWidth
                    height: 58
                    radius: selected
                        ? root.luminaDesign.shape.full
                        : root.luminaDesign.shape.large
                    color: selected
                        ? root.luminaDesign.color.accentContainer
                        : root.luminaDesign.color.surfaceMuted
                    border.width: activeFocus ? 2 : 1
                    border.color: activeFocus || selected
                        ? root.luminaDesign.color.primary
                        : root.luminaDesign.color.outline
                    activeFocusOnTab: enabled

                    Behavior on radius {
                        NumberAnimation {
                            duration:
                                root.luminaDesign.motion.spatialDefault
                            easing.type:
                                root.luminaDesign.motion.spatialEasing
                            easing.overshoot:
                                root.luminaDesign.motion.spatialOvershoot
                        }
                    }

                    Accessible.role: Accessible.RadioButton
                    Accessible.name: String(modelData.label)
                        + " palette"
                    Accessible.checked: selected
                    Accessible.focusable: enabled
                    Accessible.focused: activeFocus
                    Accessible.onPressAction:
                        WallpaperService.setPaletteStyle(
                            String(modelData.value)
                        )

                    Keys.onSpacePressed: event => {
                        WallpaperService.setPaletteStyle(
                            String(modelData.value)
                        )
                        event.accepted = true
                    }

                    Keys.onReturnPressed: event => {
                        WallpaperService.setPaletteStyle(
                            String(modelData.value)
                        )
                        event.accepted = true
                    }

                    Row {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: root.luminaDesign.spacing.medium
                        }
                        spacing: root.luminaDesign.spacing.medium

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 62
                            spacing: 2

                            Repeater {
                                model: WallpaperService.previewColors(
                                    String(paletteOption.modelData.value)
                                )

                                delegate: Rectangle {
                                    required property var modelData

                                    width: 14
                                    height: 22
                                    radius: 7
                                    color: modelData
                                    border.width: 1
                                    border.color:
                                        root.luminaDesign.color.outline
                                }
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                                - 62
                                - parent.spacing
                            text: String(paletteOption.modelData.label)
                            color: paletteOption.selected
                                ? root.luminaDesign.color.onAccentContainer
                                : root.luminaDesign.color.onSurface
                            elide: Text.ElideRight
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            paletteOption.forceActiveFocus(
                                Qt.MouseFocusReason
                            )
                            WallpaperService.setPaletteStyle(
                                String(paletteOption.modelData.value)
                            )
                        }
                    }
                }
            }
        }
    }

    SettingsSection {
        title: "Wallpaper"
        groupedRows: false
        description: "Current image and source directory for " + root.outputName

        Row {
            width: parent.width
            height: 168
            spacing: root.luminaDesign.spacing.extraLarge

            Rectangle {
                id: wallpaperPreview

                width: Math.min(360, Math.round(parent.width * 0.38))
                height: parent.height
                radius: root.luminaDesign.shape.extraLarge
                color: root.luminaDesign.color.surfaceMuted
                clip: true

                Image {
                    anchors.fill: parent
                    source: WallpaperService.urlForPath(
                        root.currentWallpaper
                    )
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: 38
                    color: root.luminaDesign.color.scrim

                    Text {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: root.luminaDesign.spacing.medium
                        }
                        text: root.outputName + " · "
                            + root.wallpaperFileName(
                                root.currentWallpaper
                            )
                        color: "#FFFFFF"
                        elide: Text.ElideMiddle
                        font.pixelSize:
                            root.luminaDesign.typography.labelSmall
                        font.weight: Font.DemiBold
                    }
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                    - wallpaperPreview.width
                    - parent.spacing
                spacing: root.luminaDesign.spacing.medium

                Column {
                    width: parent.width
                    spacing: 4

                    Text {
                        width: parent.width
                        text: "Current wallpaper"
                        color: root.luminaDesign.color.onSurface
                        font.pixelSize:
                            root.luminaDesign.typography.bodyMedium
                        font.weight: Font.DemiBold
                    }

                    Text {
                        width: parent.width
                        text: root.currentWallpaper
                        color: root.luminaDesign.color.textMuted
                        elide: Text.ElideMiddle
                        font.pixelSize:
                            root.luminaDesign.typography.labelSmall
                    }
                }

                SettingsActionRow {
                    width: parent.width
                    height: 72
                    title: "Wallpaper for " + root.outputName
                    description: "Open the image picker for this output"
                    iconName: "preferences-desktop-wallpaper-symbolic"
                    symbol: "▧"
                    actionLabel: "Choose"
                    onActivated:
                        WallpaperService.openPicker(root.outputName)
                }
            }
        }

        SettingsRow {
            width: parent.width
            title: "Wallpaper directory"
            description: ConfigStore.wallpaperDirectory
            iconName: "folder-pictures-symbolic"
            symbol: "▤"
            controlWidth: Math.min(320, width * 0.42)

            Rectangle {
                anchors.fill: parent
                radius: root.luminaDesign.shape.medium
                color: root.luminaDesign.color.surfaceMuted
                border.width: directoryInput.activeFocus ? 2 : 1
                border.color: directoryInput.activeFocus
                    ? root.luminaDesign.color.primary
                    : root.luminaDesign.color.outline

                TextInput {
                    id: directoryInput

                    anchors {
                        fill: parent
                        margins: root.luminaDesign.spacing.medium
                    }
                    text: ConfigStore.wallpaperDirectory
                    color: root.luminaDesign.color.onSurface
                    selectionColor:
                        root.luminaDesign.color.accentContainer
                    selectedTextColor:
                        root.luminaDesign.color.onAccentContainer
                    activeFocusOnTab: true
                    clip: true
                    font.pixelSize:
                        root.luminaDesign.typography.labelMedium
                    onEditingFinished:
                        WallpaperService.setWallpaperDirectory(text)

                    Accessible.role: Accessible.EditableText
                    Accessible.name: "Wallpaper directory"
                }
            }
        }
    }

    SettingsSection {
        title: "Shell style"
        description: "Changes apply immediately to Lumina surfaces"

        SettingsSwitchRow {
            width: parent.width
            title: "Transparency"
            description: checked
                ? "Semantic surfaces use configured opacity"
                : "Surfaces are fully opaque"
            checked: ConfigStore.transparencyEnabled
            onToggled: value =>
                ConfigStore.setAppearanceValue(
                    "transparencyEnabled",
                    value
                )
        }

        SettingsSliderRow {
            width: parent.width
            title: "Surface opacity"
            description: "Minimum is limited for readable contrast"
            available: ConfigStore.transparencyEnabled
            availabilityText: "Enable transparency first"
            from: 0.72
            to: 1
            stepSize: 0.02
            value: ConfigStore.surfaceOpacity
            valueLabel: Math.round(value * 100) + "%"
            onValueEdited: value =>
                ConfigStore.setAppearanceValue(
                    "surfaceOpacity",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Animations"
            description: checked
                ? "Material transitions are enabled"
                : "Transitions are nearly instant"
            checked: ConfigStore.animationsEnabled
            onToggled: value =>
                ConfigStore.setAppearanceValue(
                    "animationsEnabled",
                    value
                )
        }

        SettingsSliderRow {
            width: parent.width
            title: "Animation scale"
            description: "Adjust the duration of shell transitions"
            available: ConfigStore.animationsEnabled
            availabilityText: "Animations are disabled"
            from: 0.5
            to: 2
            stepSize: 0.25
            value: ConfigStore.animationScale
            valueLabel: value.toFixed(2) + "×"
            onValueEdited: value =>
                ConfigStore.setAppearanceValue(
                    "animationScale",
                    value
                )
        }

        SettingsSliderRow {
            width: parent.width
            title: "Corner radius"
            description: "Scale Material Expressive shell shapes"
            from: 0.6
            to: 1.5
            stepSize: 0.1
            value: ConfigStore.cornerRadiusScale
            valueLabel: value.toFixed(1) + "×"
            onValueEdited: value =>
                ConfigStore.setAppearanceValue(
                    "cornerRadiusScale",
                    value
                )
        }

        SettingsSwitchRow {
            width: parent.width
            title: "Compact mode"
            description: "Reduce spacing without shrinking text"
            checked: ConfigStore.compactMode
            onToggled: value =>
                ConfigStore.setAppearanceValue(
                    "compactMode",
                    value
                )
        }
    }
}

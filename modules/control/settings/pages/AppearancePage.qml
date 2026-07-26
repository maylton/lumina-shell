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
        { value: "auto", label: I18n.tr("settings.appearance.palette.auto", "Auto") },
        { value: "content", label: I18n.tr("settings.appearance.palette.content", "Content") },
        { value: "expressive", label: I18n.tr("settings.appearance.palette.expressive", "Expressive") },
        { value: "fidelity", label: I18n.tr("settings.appearance.palette.fidelity", "Fidelity") },
        { value: "fruit-salad", label: I18n.tr("settings.appearance.palette.fruitSalad", "Fruit Salad") },
        { value: "monochrome", label: I18n.tr("settings.appearance.palette.monochrome", "Monochrome") },
        { value: "neutral", label: I18n.tr("settings.appearance.palette.neutral", "Neutral") },
        { value: "rainbow", label: I18n.tr("settings.appearance.palette.rainbow", "Rainbow") },
        { value: "tonal-spot", label: I18n.tr("settings.appearance.palette.tonalSpot", "Tonal Spot") }
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
        return I18n.tr("settings.appearance.palette.auto", "Auto")
    }

    title: I18n.tr("settings.category.appearance.label", "Appearance")
    description: I18n.tr(
        "settings.page.appearance.description",
        "Colors, wallpaper, and the visual language of Lumina"
    )

    SettingsSection {
        title: I18n.tr("settings.appearance.theme.section", "Theme mode")
        groupedRows: false
        description: ConfigStore.themeMode === "auto"
            ? I18n.tr(
                "settings.appearance.theme.autoDescription",
                "Auto uses Lumina's predictable dark fallback on this runtime"
            )
            : I18n.tr(
                "settings.appearance.theme.description",
                "Choose Lumina's complete light or dark tonal scheme"
            )

        Row {
            width: parent.width
            height: 154
            spacing: root.luminaDesign.spacing.medium

            ThemePreviewCard {
                width: (parent.width - parent.spacing) / 2
                height: parent.height
                label: I18n.tr("settings.appearance.theme.light", "Light")
                mode: "light"
                selected: ConfigStore.themeMode === "light"
                onActivated: ConfigStore.setThemeMode("light")
            }

            ThemePreviewCard {
                width: (parent.width - parent.spacing) / 2
                height: parent.height
                label: I18n.tr("settings.appearance.theme.dark", "Dark")
                mode: "dark"
                selected: ConfigStore.themeMode === "dark"
                onActivated: ConfigStore.setThemeMode("dark")
            }
        }

        SettingsSegmentedControl {
            width: parent.width
            height: 40
            options: [
                { value: "auto", label: I18n.tr("settings.appearance.theme.auto", "Auto") },
                { value: "light", label: I18n.tr("settings.appearance.theme.light", "Light") },
                { value: "dark", label: I18n.tr("settings.appearance.theme.dark", "Dark") }
            ]
            currentValue: ConfigStore.themeMode
            onSelected: value => ConfigStore.setThemeMode(value)
        }
    }

    SettingsSection {
        title: I18n.tr("settings.appearance.material.section", "Material palette")
        groupedRows: false
        description: Theme.dynamicPaletteActive
            ? I18n.tr(
                "settings.appearance.material.activeDescription",
                "%1 accents and tonal surfaces from the active wallpaper",
                [root.paletteLabel(ConfigStore.paletteStyle)]
            )
            : I18n.tr(
                "settings.appearance.material.defaultDescription",
                "Lumina's default semantic accent colors are active"
            )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.appearance.material.wallpaperPalette",
                "Wallpaper palette"
            )
            description: checked
                ? I18n.tr(
                    "settings.appearance.material.dynamicEnabled",
                    "Dynamic Material colors enabled"
                )
                : I18n.tr(
                    "settings.appearance.material.defaultPalette",
                    "Lumina default palette"
                )
            iconName: "applications-graphics-symbolic"
            symbol: "✦"
            checked: ConfigStore.dynamicTheme
            onToggled: value => WallpaperService.setDynamicTheme(value)
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
                        String(modelData.value) === ConfigStore.paletteStyle

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
                            duration: root.luminaDesign.motion.spatialDefault
                            easing.type: root.luminaDesign.motion.spatialEasing
                            easing.overshoot:
                                root.luminaDesign.motion.spatialOvershoot
                        }
                    }

                    Accessible.role: Accessible.RadioButton
                    Accessible.name: I18n.tr(
                        "settings.appearance.material.paletteAccessible",
                        "%1 palette",
                        [String(modelData.label)]
                    )
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
                                    border.color: root.luminaDesign.color.outline
                                }
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 62 - parent.spacing
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
                            paletteOption.forceActiveFocus()
                            paletteOption.focus = false
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
        title: I18n.tr("settings.appearance.wallpaper.section", "Wallpaper")
        groupedRows: false
        description: I18n.tr(
            "settings.appearance.wallpaper.sectionDescription",
            "Current image and source directory for %1",
            [root.outputName]
        )

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
                    source: WallpaperService.urlForPath(root.currentWallpaper)
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
                            + root.wallpaperFileName(root.currentWallpaper)
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
                width: parent.width - wallpaperPreview.width - parent.spacing
                spacing: root.luminaDesign.spacing.medium

                Column {
                    width: parent.width
                    spacing: 4

                    Text {
                        width: parent.width
                        text: I18n.tr(
                            "settings.appearance.wallpaper.current",
                            "Current wallpaper"
                        )
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
                    title: I18n.tr(
                        "settings.appearance.wallpaper.forOutput",
                        "Wallpaper for %1",
                        [root.outputName]
                    )
                    description: I18n.tr(
                        "settings.appearance.wallpaper.pickerDescription",
                        "Open the image picker for this output"
                    )
                    iconName: "preferences-desktop-wallpaper-symbolic"
                    symbol: "▧"
                    actionLabel: I18n.tr(
                        "settings.appearance.wallpaper.choose",
                        "Choose"
                    )
                    onActivated: WallpaperService.openPicker(root.outputName)
                }
            }
        }

        SettingsRow {
            width: parent.width
            title: I18n.tr(
                "settings.appearance.wallpaper.directory",
                "Wallpaper directory"
            )
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
                    selectionColor: root.luminaDesign.color.accentContainer
                    selectedTextColor:
                        root.luminaDesign.color.onAccentContainer
                    activeFocusOnTab: true
                    clip: true
                    font.pixelSize:
                        root.luminaDesign.typography.labelMedium
                    onEditingFinished:
                        WallpaperService.setWallpaperDirectory(text)

                    Accessible.role: Accessible.EditableText
                    Accessible.name: I18n.tr(
                        "settings.appearance.wallpaper.directory",
                        "Wallpaper directory"
                    )
                }
            }
        }
    }

    SettingsSection {
        title: I18n.tr("settings.appearance.shell.section", "Shell style")
        description: I18n.tr(
            "settings.appearance.shell.sectionDescription",
            "Changes apply immediately to Lumina surfaces"
        )

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.appearance.shell.surfaceStyle",
                "Surface style"
            )
            description: ConfigStore.shellBackgroundMode === "solid"
                ? I18n.tr(
                    "settings.appearance.shell.solidDescription",
                    "Opaque tonal shell surfaces"
                )
                : ConfigStore.shellBackgroundMode === "blur"
                    ? I18n.tr(
                        "settings.appearance.shell.blurDescription",
                        "Android-inspired bounded live blur"
                    )
                    : I18n.tr(
                        "settings.appearance.shell.frostedDescription",
                        "Blur with richer tint, highlight, and subtle texture"
                    )
            options: [
                { value: "solid", label: I18n.tr("settings.appearance.shell.solid", "Solid") },
                { value: "blur", label: I18n.tr("settings.appearance.shell.blur", "Blur") },
                { value: "frosted", label: I18n.tr("settings.appearance.shell.frosted", "Frosted glass") }
            ]
            currentValue: ConfigStore.shellBackgroundMode
            onSelected: value => ConfigStore.setAppearanceValue(
                "shellBackgroundMode",
                value
            )
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr(
                "settings.appearance.shell.tintOpacity",
                "Tint opacity"
            )
            description: I18n.tr(
                "settings.appearance.shell.tintOpacityDescription",
                "Controls the tonal protection above live blur"
            )
            available: ConfigStore.shellBackgroundMode !== "solid"
            availabilityText: I18n.tr(
                "settings.appearance.shell.tintOpacityUnavailable",
                "Solid surfaces are fully opaque"
            )
            from: 0.55
            to: 0.95
            stepSize: 0.02
            value: ConfigStore.shellSurfaceOpacity
            valueLabel: Math.round(value * 100) + "%"
            onValueEdited: value => ConfigStore.setAppearanceValue(
                "shellSurfaceOpacity",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.appearance.shell.animations",
                "Animations"
            )
            description: checked
                ? I18n.tr(
                    "settings.appearance.shell.animationsEnabled",
                    "Material transitions are enabled"
                )
                : I18n.tr(
                    "settings.appearance.shell.animationsDisabledDescription",
                    "Transitions are nearly instant"
                )
            checked: ConfigStore.animationsEnabled
            onToggled: value => ConfigStore.setAppearanceValue(
                "animationsEnabled",
                value
            )
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr(
                "settings.appearance.shell.animationScale",
                "Animation scale"
            )
            description: I18n.tr(
                "settings.appearance.shell.animationScaleDescription",
                "Adjust the duration of shell transitions"
            )
            available: ConfigStore.animationsEnabled
            availabilityText: I18n.tr(
                "settings.appearance.shell.animationsUnavailable",
                "Animations are disabled"
            )
            from: 0.5
            to: 2
            stepSize: 0.25
            value: ConfigStore.animationScale
            valueLabel: value.toFixed(2) + "×"
            onValueEdited: value => ConfigStore.setAppearanceValue(
                "animationScale",
                value
            )
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr(
                "settings.appearance.shell.cornerRadius",
                "Corner radius"
            )
            description: I18n.tr(
                "settings.appearance.shell.cornerRadiusDescription",
                "Scale Material Expressive shell shapes"
            )
            from: 0.6
            to: 1.5
            stepSize: 0.1
            value: ConfigStore.cornerRadiusScale
            valueLabel: value.toFixed(1) + "×"
            onValueEdited: value => ConfigStore.setAppearanceValue(
                "cornerRadiusScale",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.appearance.shell.compactMode",
                "Compact mode"
            )
            description: I18n.tr(
                "settings.appearance.shell.compactModeDescription",
                "Reduce spacing without shrinking text"
            )
            checked: ConfigStore.compactMode
            onToggled: value => ConfigStore.setAppearanceValue(
                "compactMode",
                value
            )
        }
    }
}

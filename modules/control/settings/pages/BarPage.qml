pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.modules.control.settings.bar
import qs.services.i18n
import qs.stores.config
import "../../../bar/BarScalePolicy.js" as BarScalePolicy
import "../bar/BarWidgetCatalog.js" as BarWidgetCatalog
import "../bar/BarWidgetState.js" as BarWidgetState

SettingsPage {
    id: root

    readonly property real effectiveBarContentScale:
        BarScalePolicy.effectiveScale(
            ConfigStore.barHeight,
            ConfigStore.barAutoScaleContents,
            ConfigStore.barContentScale,
            ConfigStore.compactMode
        )

    function togglePerformanceWidgetDialog() {
        if (widgetDialog.opened)
            widgetDialog.close()
        else
            widgetDialog.openFor("launcher", null)
    }
    readonly property string backgroundModeDescription: {
        switch (ConfigStore.barBackgroundMode) {
        case "translucent":
            return I18n.tr(
                "settings.bar.surface.mode.translucent.description",
                "Transparent tonal surface without blur"
            )
        case "blur":
            return I18n.tr(
                "settings.bar.surface.mode.blur.description",
                "Clean live background blur with a tonal protection layer"
            )
        case "frosted":
            return I18n.tr(
                "settings.bar.surface.mode.frosted.description",
                "Blur with a richer tint, highlight, and subtle texture"
            )
        case "transparent":
            return I18n.tr(
                "settings.bar.surface.mode.transparent.description",
                "No bar background"
            )
        default:
            return I18n.tr(
                "settings.bar.surface.mode.solid.description",
                "Opaque tonal background"
            )
        }
    }

    title: I18n.tr("settings.category.bar.label", "Bar")
    description: I18n.tr(
        "settings.page.bar.description",
        "Surface and active widgets per output"
    )

    function activeEntries(side) {
        const ids = ConfigStore.activeBarWidgets(side)
        const result = []

        for (var index = 0; index < ids.length; ++index) {
            const entry = BarWidgetCatalog.find(ids[index])

            if (entry)
                result.push(localizedEntry(entry))
        }

        return result
    }

    function removedEntries(side) {
        const activeIds = ConfigStore.activeBarWidgets(side)
        const removedIds = BarWidgetState.removedIds(
            BarWidgetCatalog.idsForSide(side),
            activeIds
        )
        const result = []

        for (var index = 0; index < removedIds.length; ++index) {
            const entry = BarWidgetCatalog.find(removedIds[index])

            if (entry && entry.available)
                result.push(localizedEntry(entry))
        }

        return result
    }

    function localizedEntry(entry) {
        const id = String(entry.id)
        const titleKey = [
            "settings", "bar", "catalog", id, "title"
        ].join(".")
        const descriptionKey = [
            "settings", "bar", "catalog", id, "description"
        ].join(".")
        entry.title = I18n.tr(
            titleKey,
            String(entry.title)
        )
        entry.description = I18n.tr(
            descriptionKey,
            String(entry.description)
        )
        return entry
    }

    SettingsSection {
        title: I18n.tr(
            "settings.bar.surface.title",
            "Surface"
        )
        description: I18n.tr(
            "settings.bar.surface.description",
            "Background and responsive bar geometry"
        )

        SettingsRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.surface.background",
                "Background"
            )
            description: root.backgroundModeDescription
            controlWidth: 560

            SettingsSegmentedControl {
                width: parent.width
                height: 44
                options: [
                    {
                        value: "solid",
                        label: I18n.tr(
                            "settings.bar.surface.mode.solid.label",
                            "Solid"
                        )
                    },
                    {
                        value: "translucent",
                        label: I18n.tr(
                            "settings.bar.surface.mode.translucent.label",
                            "Translucent"
                        )
                    },
                    {
                        value: "blur",
                        label: I18n.tr(
                            "settings.bar.surface.mode.blur.label",
                            "Blur"
                        )
                    },
                    {
                        value: "frosted",
                        label: I18n.tr(
                            "settings.bar.surface.mode.frosted.label",
                            "Frosted glass"
                        )
                    },
                    {
                        value: "transparent",
                        label: I18n.tr(
                            "settings.bar.surface.mode.transparent.label",
                            "Transparent"
                        )
                    }
                ]
                currentValue: ConfigStore.barBackgroundMode
                onSelected: value => ConfigStore.setBarValue(
                    "barBackgroundMode",
                    value
                )
            }
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.surface.opacity",
                "Background tint opacity"
            )
            description: I18n.tr(
                "settings.bar.surface.opacityDescription",
                "Controls the client tint; the compositor controls blur intensity"
            )
            available: [
                "translucent",
                "blur",
                "frosted"
            ].indexOf(ConfigStore.barBackgroundMode) >= 0
            availabilityText: I18n.tr(
                "settings.bar.surface.opacityUnavailable",
                "Choose Translucent, Blur, or Frosted glass first"
            )
            from: 0
            to: 1
            stepSize: 0.02
            value: ConfigStore.barSurfaceOpacity
            valueLabel: Math.round(value * 100) + "%"
            onValueEdited: value => ConfigStore.setBarValue(
                "barSurfaceOpacity",
                value
            )
        }

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.surface.position",
                "Position"
            )
            description: I18n.tr(
                "settings.bar.surface.positionDescription",
                "Anchor the bar to the screen edge"
            )
            options: [
                {
                    value: "top",
                    label: I18n.tr(
                        "settings.bar.surface.position.top",
                        "Top"
                    )
                },
                {
                    value: "bottom",
                    label: I18n.tr(
                        "settings.bar.surface.position.bottom",
                        "Bottom"
                    )
                }
            ]
            currentValue: ConfigStore.barPosition
            onSelected: value => ConfigStore.setBarValue(
                "barPosition",
                value
            )
        }

        SettingsRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.surface.geometry",
                "Surface geometry"
            )
            description: ConfigStore.barSurfaceMode === "edge-to-edge"
                ? I18n.tr(
                    "settings.bar.surface.geometry.edgeDescription",
                    "Fill the screen edge"
                )
                : I18n.tr(
                    "settings.bar.surface.geometry.floatingDescription",
                    "Reserve space around the visible surface"
                )
            controlWidth: 340

            SettingsSegmentedControl {
                width: parent.width
                height: 44
                options: [
                    {
                        value: "edge-to-edge",
                        label: I18n.tr(
                            "settings.bar.surface.geometry.edge",
                            "Edge-to-edge"
                        )
                    },
                    {
                        value: "floating",
                        label: I18n.tr(
                            "settings.bar.surface.geometry.floating",
                            "Floating"
                        )
                    }
                ]
                currentValue: ConfigStore.barSurfaceMode
                onSelected: value => ConfigStore.setBarValue(
                    "barSurfaceMode",
                    value
                )
            }
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.surface.height",
                "Bar height"
            )
            description: I18n.tr(
                "settings.bar.surface.heightDescription",
                "Expressive surface height, excluding margins"
            )
            from: 40
            to: 80
            stepSize: 2
            value: ConfigStore.barHeight
            valueLabel: Math.round(value) + " px"
            onValueEdited: value => ConfigStore.setBarValue(
                "barHeight",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.surface.autoScale",
                "Scale contents automatically"
            )
            description: I18n.tr(
                "settings.bar.surface.autoScaleDescription",
                "Match icons, text, padding, and targets to height"
            )
            checked: ConfigStore.barAutoScaleContents
            onToggled: value => ConfigStore.setBarValue(
                "barAutoScaleContents",
                value
            )
        }

        SettingsSliderRow {
            width: parent.width
            title: ConfigStore.barAutoScaleContents
                ? I18n.tr(
                    "settings.bar.surface.effectiveScale",
                    "Effective content scale"
                )
                : I18n.tr(
                    "settings.bar.surface.contentScale",
                    "Content scale"
                )
            description: ConfigStore.barAutoScaleContents
                ? I18n.tr(
                    "settings.bar.surface.effectiveScaleDescription",
                    "Calculated from the selected bar height"
                )
                : I18n.tr(
                    "settings.bar.surface.contentScaleDescription",
                    "Manual scale for bar contents"
                )
            available: !ConfigStore.barAutoScaleContents
            availabilityText: I18n.tr(
                "settings.bar.surface.autoScaleValue",
                "Calculated automatically from %1 px bar height",
                [ConfigStore.barHeight]
            )
            from: ConfigStore.barAutoScaleContents
                ? BarScalePolicy.effectiveScale(
                    40, true, 1, ConfigStore.compactMode
                )
                : 0.8
            to: ConfigStore.barAutoScaleContents
                ? BarScalePolicy.effectiveScale(
                    80, true, 1, ConfigStore.compactMode
                )
                : 1.4
            stepSize: 0.05
            value: ConfigStore.barAutoScaleContents
                ? root.effectiveBarContentScale
                : ConfigStore.barContentScale
            valueLabel: Math.round(value * 100) + "%"
            onValueEdited: value => ConfigStore.setBarValue(
                "barContentScale",
                value
            )
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.surface.margin",
                "Outer margin"
            )
            description: I18n.tr(
                "settings.bar.surface.marginDescription",
                "Space around a floating bar"
            )
            available: ConfigStore.barSurfaceMode === "floating"
            availabilityText: I18n.tr(
                "settings.bar.surface.marginUnavailable",
                "Edge-to-edge mode does not use an outer margin"
            )
            from: 0
            to: 18
            stepSize: 1
            value: ConfigStore.barMargin
            valueLabel: Math.round(value) + " px"
            onValueEdited: value => ConfigStore.setBarValue(
                "barMargin",
                value
            )
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.surface.panelGap",
                "Panel distance"
            )
            description: I18n.tr(
                "settings.bar.surface.panelGapDescription",
                "Vertical space between the bar and widget panels"
            )
            from: 0
            to: 48
            stepSize: 1
            value: ConfigStore.barPanelGap
            valueLabel: Math.round(value) + " px"
            onValueEdited: value => ConfigStore.setBarValue(
                "barPanelGap",
                value
            )
        }

        SettingsSliderRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.surface.spacing",
                "Widget spacing"
            )
            description: I18n.tr(
                "settings.bar.surface.spacingDescription",
                "Horizontal distance between clusters"
            )
            from: 2
            to: 24
            stepSize: 1
            value: ConfigStore.barWidgetSpacing
            valueLabel: Math.round(value) + " px"
            onValueEdited: value => ConfigStore.setBarValue(
                "barWidgetSpacing",
                value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.bar.surface.compact",
                "Compact mode"
            )
            description: I18n.tr(
                "settings.bar.surface.compactDescription",
                "Reduce density without ignoring height or scale"
            )
            checked: ConfigStore.compactMode
            onToggled: value => ConfigStore.setAppearanceValue(
                "compactMode",
                value
            )
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.bar.widgets.left",
            "Left widgets"
        )
        description: I18n.tr(
            "settings.bar.widgets.leftDescription",
            "Launcher, navigation, and time"
        )
        groupedRows: false

        Repeater {
            model: root.activeEntries("left")

            delegate: ActiveBarWidgetRow {
                required property var modelData
                required property int index

                width: parent.width
                widget: modelData
                canMoveUp: index > 0
                canMoveDown:
                    index < root.activeEntries("left").length - 1
                onConfigure: sourceItem =>
                    widgetDialog.openFor(modelData.id, sourceItem)
                onMoveUp: ConfigStore.moveActiveBarWidget(
                    "left", modelData.id, -1
                )
                onMoveDown: ConfigStore.moveActiveBarWidget(
                    "left", modelData.id, 1
                )
                onRemove:
                    ConfigStore.removeBarWidget(modelData.id)
            }
        }

        AddBarWidgetRow {
            width: parent.width
            widgets: root.removedEntries("left")
            onAddWidget: widgetId =>
                ConfigStore.addBarWidget("left", widgetId)
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.bar.widgets.center",
            "Center widget"
        )
        description: I18n.tr(
            "settings.bar.widgets.centerDescription",
            "Context stays centered without overlapping side clusters"
        )
        groupedRows: false

        Repeater {
            model: root.activeEntries("center")

            delegate: ActiveBarWidgetRow {
                required property var modelData

                width: parent.width
                widget: modelData
                onConfigure: sourceItem =>
                    widgetDialog.openFor(modelData.id, sourceItem)
                onRemove:
                    ConfigStore.removeBarWidget(modelData.id)
            }
        }

        AddBarWidgetRow {
            width: parent.width
            widgets: root.removedEntries("center")
            onAddWidget: widgetId =>
                ConfigStore.addBarWidget("center", widgetId)
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.bar.widgets.right",
            "Right widgets"
        )
        description: I18n.tr(
            "settings.bar.widgets.rightDescription",
            "Status, notifications, and personal actions"
        )
        groupedRows: false

        Repeater {
            model: root.activeEntries("right")

            delegate: ActiveBarWidgetRow {
                required property var modelData
                required property int index

                width: parent.width
                widget: modelData
                canMoveUp: index > 0
                canMoveDown:
                    index < root.activeEntries("right").length - 1
                onConfigure: sourceItem =>
                    widgetDialog.openFor(modelData.id, sourceItem)
                onMoveUp: ConfigStore.moveActiveBarWidget(
                    "right", modelData.id, -1
                )
                onMoveDown: ConfigStore.moveActiveBarWidget(
                    "right", modelData.id, 1
                )
                onRemove:
                    ConfigStore.removeBarWidget(modelData.id)
            }
        }

        AddBarWidgetRow {
            width: parent.width
            widgets: root.removedEntries("right")
            onAddWidget: widgetId =>
                ConfigStore.addBarWidget("right", widgetId)
        }
    }

    BarWidgetSettingsDialog {
        id: widgetDialog
    }
}

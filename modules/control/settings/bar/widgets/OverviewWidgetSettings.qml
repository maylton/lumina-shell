import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.stores.config

Column {
    width: parent ? parent.width : 0
    SettingsSection {
        title: I18n.tr(
            "settings.widget.common.presentation",
            "Presentation"
        )
        description: I18n.tr(
            "settings.widget.overview.description",
            "Overview appearance on the bar"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.common.background",
                "Background"
            )
            description: I18n.tr(
                "settings.widget.common.backgroundResting",
                "Show a resting tonal surface"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "overview", "showBackground", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "overview", "showBackground", value
            )
        }

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.widget.common.label",
                "Label"
            )
            description: I18n.tr(
                "settings.widget.overview.labelDescription",
                "Show Overview beside the icon"
            )
            checked: Boolean(ConfigStore.widgetSetting(
                "overview", "showLabel", false
            ))
            onToggled: value => ConfigStore.setBarWidgetSetting(
                "overview", "showLabel", value
            )
        }
    }
}

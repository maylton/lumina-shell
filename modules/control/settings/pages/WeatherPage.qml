pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.i18n
import qs.services.weather
import qs.stores.config
import qs.stores.weather

SettingsPage {
    id: root

    readonly property string statusDescription: WeatherService.loading
        ? I18n.tr(
            "settings.weather.status.updating",
            "Updating location and forecast"
        )
        : WeatherService.available
            ? WeatherService.locationName
                + " · "
                + WeatherService.temperatureLabel
            : WeatherService.lastError
                || I18n.tr(
                    "settings.weather.status.unavailable",
                    "Forecast unavailable"
                )

    title: I18n.tr(
        "settings.category.weather.label",
        "Weather"
    )
    description: I18n.tr(
        "settings.page.weather.description",
        "Forecast visibility, location, and refresh behavior"
    )

    SettingsSection {
        title: I18n.tr(
            "settings.weather.section.forecast",
            "Forecast"
        )
        description: I18n.tr(
            "settings.weather.section.forecastDescription",
            "Disabling weather stops location and forecast requests"
        )

        SettingsSwitchRow {
            width: parent.width
            title: I18n.tr(
                "settings.weather.enabled",
                "Show weather"
            )
            description: I18n.tr(
                "settings.weather.enabledDescription",
                "Display current conditions below the Dashboard clock"
            )
            iconName: "weather-clear-symbolic"
            symbol: "☀"
            checked: ConfigStore.dashboardShowWeather
            onToggled: value => ConfigStore.setDashboardValue(
                "dashboardShowWeather",
                value
            )
        }

        SettingsActionRow {
            width: parent.width
            title: I18n.tr(
                "settings.weather.status",
                "Current forecast"
            )
            description: root.statusDescription
            iconName: WeatherService.iconName
            symbol: "☁"
            actionLabel: WeatherService.loading
                ? I18n.tr(
                    "settings.weather.refreshing",
                    "Updating"
                )
                : I18n.tr(
                    "settings.weather.refresh",
                    "Refresh"
                )
            available: ConfigStore.dashboardShowWeather
                && !WeatherService.loading
            availabilityText: I18n.tr(
                "settings.weather.disabledHint",
                "Enable weather first"
            )
            onActivated: WeatherService.refresh(true)
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.weather.section.location",
            "Location"
        )
        description: I18n.tr(
            "settings.weather.section.locationDescription",
            "Automatic mode estimates your city from the public IP address"
        )

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.weather.locationMode",
                "Location source"
            )
            description: WeatherPreferences.locationMode === "automatic-ip"
                ? I18n.tr(
                    "settings.weather.locationMode.automaticDescription",
                    "VPNs and mobile networks may report a nearby or exit city"
                )
                : I18n.tr(
                    "settings.weather.locationMode.manualDescription",
                    "Use the city entered below"
                )
            options: [
                {
                    value: "automatic-ip",
                    label: I18n.tr(
                        "settings.weather.locationMode.automatic",
                        "Automatic by IP"
                    )
                },
                {
                    value: "manual",
                    label: I18n.tr(
                        "settings.weather.locationMode.manual",
                        "Manual city"
                    )
                }
            ]
            currentValue: WeatherPreferences.locationMode
            available: ConfigStore.dashboardShowWeather
            onSelected: value =>
                WeatherPreferences.setLocationMode(value)
        }

        SettingsTextFieldRow {
            width: parent.width
            title: I18n.tr(
                "settings.weather.manualCity",
                "City"
            )
            description: I18n.tr(
                "settings.weather.manualCityDescription",
                "Examples: João Pessoa, Recife, Lisbon"
            )
            iconName: "find-location-symbolic"
            symbol: "⌖"
            text: WeatherPreferences.manualCity
            placeholderText: I18n.tr(
                "settings.weather.manualCityPlaceholder",
                "Type a city"
            )
            available: ConfigStore.dashboardShowWeather
                && WeatherPreferences.locationMode === "manual"
            availabilityText: I18n.tr(
                "settings.weather.manualCityUnavailable",
                "Choose Manual city first"
            )
            onAccepted: value => {
                WeatherPreferences.setManualCity(value)
                WeatherService.refresh(true)
            }
        }
    }

    SettingsSection {
        title: I18n.tr(
            "settings.weather.section.updates",
            "Updates"
        )

        SettingsComboRow {
            width: parent.width
            title: I18n.tr(
                "settings.weather.refreshInterval",
                "Refresh interval"
            )
            description: I18n.tr(
                "settings.weather.refreshIntervalDescription",
                "How often the current forecast is refreshed"
            )
            options: [
                {
                    value: "15",
                    label: I18n.tr(
                        "settings.weather.interval.15",
                        "15 minutes"
                    )
                },
                {
                    value: "30",
                    label: I18n.tr(
                        "settings.weather.interval.30",
                        "30 minutes"
                    )
                },
                {
                    value: "60",
                    label: I18n.tr(
                        "settings.weather.interval.60",
                        "1 hour"
                    )
                },
                {
                    value: "120",
                    label: I18n.tr(
                        "settings.weather.interval.120",
                        "2 hours"
                    )
                }
            ]
            currentValue: String(WeatherPreferences.refreshInterval)
            available: ConfigStore.dashboardShowWeather
            onSelected: value =>
                WeatherPreferences.setRefreshInterval(Number(value))
        }
    }
}

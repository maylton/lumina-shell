pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.i18n
import qs.services.weather
import qs.stores.system
import qs.stores.time

Item {
    id: root

    property bool showWeather: true
    readonly property var luminaDesign: Theme.luminaTokens
    readonly property string weatherUpdating: I18n.tr(
        "dashboard.weather.updating",
        "Updating weather"
    )
    readonly property string weatherUnavailable: I18n.tr(
        "dashboard.weather.unavailable",
        "Weather unavailable"
    )
    readonly property string weatherCondition:
        translatedWeatherCondition(WeatherService.weatherCode)
    readonly property string weatherRangeLabel: WeatherService.available
        ? I18n.tr(
            "dashboard.weather.range",
            "H %1° · L %2°",
            [
                Math.round(WeatherService.maximumTemperature),
                Math.round(WeatherService.minimumTemperature)
            ]
        )
        : ""

    function translatedWeatherCondition(code) {
        const value = Number(code || 0)

        if (value === 0) {
            return I18n.tr(
                "dashboard.weather.condition.clear",
                "Clear"
            )
        }

        if ([1, 2].indexOf(value) >= 0) {
            return I18n.tr(
                "dashboard.weather.condition.partlyCloudy",
                "Partly cloudy"
            )
        }

        if (value === 3) {
            return I18n.tr(
                "dashboard.weather.condition.overcast",
                "Overcast"
            )
        }

        if ([45, 48].indexOf(value) >= 0) {
            return I18n.tr(
                "dashboard.weather.condition.fog",
                "Fog"
            )
        }

        if (value >= 51 && value <= 57) {
            return I18n.tr(
                "dashboard.weather.condition.drizzle",
                "Drizzle"
            )
        }

        if (value >= 61 && value <= 67) {
            return I18n.tr(
                "dashboard.weather.condition.rain",
                "Rain"
            )
        }

        if (value >= 71 && value <= 77) {
            return I18n.tr(
                "dashboard.weather.condition.snow",
                "Snow"
            )
        }

        if (value >= 80 && value <= 82) {
            return I18n.tr(
                "dashboard.weather.condition.rainShowers",
                "Rain showers"
            )
        }

        if ([85, 86].indexOf(value) >= 0) {
            return I18n.tr(
                "dashboard.weather.condition.snowShowers",
                "Snow showers"
            )
        }

        if (value >= 95) {
            return I18n.tr(
                "dashboard.weather.condition.thunderstorm",
                "Thunderstorm"
            )
        }

        return I18n.tr(
            "dashboard.weather.condition.current",
            "Current conditions"
        )
    }

    DashboardCard {
        id: welcomeCard

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: 152
        accessibleName: I18n.tr(
            "dashboard.welcome.accessibleName",
            "Welcome"
        )
        emphasized: true

        Column {
            anchors.centerIn: parent
            width: parent.width
                - root.luminaDesign.spacing.controlContentInset * 2
            spacing: root.luminaDesign.spacing.controlItemGap

            UserAvatar {
                anchors.horizontalCenter: parent.horizontalCenter
                avatarSize: 58
                borderWidth: 2
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: I18n.tr(
                    "dashboard.welcome.greeting",
                    "Welcome, %1!",
                    [SystemInfoStore.displayName]
                )
                color: root.luminaDesign.color.onSurface
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.titleLarge
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: SystemInfoStore.distributionName
                color: root.luminaDesign.color.textMuted
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.labelMedium
            }
        }
    }

    DashboardCard {
        anchors {
            left: parent.left
            right: parent.right
            top: welcomeCard.bottom
            bottom: parent.bottom
            topMargin: root.luminaDesign.spacing.controlCardGap
        }

        accessibleName: I18n.tr(
            "dashboard.dateWeather.accessibleName",
            "Date and weather"
        )

        Column {
            anchors.centerIn: parent
            width: parent.width
                - root.luminaDesign.spacing.controlContentInset * 2
            spacing: root.luminaDesign.spacing.controlItemGap

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: CalendarStore.formattedTime
                color: root.luminaDesign.color.primary
                font.pixelSize: 48
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: Qt.locale(I18n.locale).toString(
                    CalendarStore.currentDate,
                    "dddd, d MMMM yyyy"
                )
                color: root.luminaDesign.color.onSurface
                wrapMode: Text.Wrap
                font.pixelSize: root.luminaDesign.typography.titleMedium
                font.weight: Font.DemiBold
            }

            Item {
                width: parent.width
                height: root.showWeather ? 42 : 0
                visible: root.showWeather

                Accessible.role: Accessible.Pane
                Accessible.name: WeatherService.available
                    ? root.weatherCondition
                        + ", "
                        + WeatherService.temperatureLabel
                        + ", "
                        + WeatherService.locationName
                    : WeatherService.loading
                        ? root.weatherUpdating
                        : root.weatherUnavailable

                Row {
                    anchors {
                        fill: parent
                        margins: root.luminaDesign.spacing.medium
                    }

                    spacing: root.luminaDesign.spacing.medium

                    DashboardIcon {
                        id: weatherIcon

                        anchors.verticalCenter: parent.verticalCenter
                        width: 22
                        height: 22
                        iconName: WeatherService.available
                            ? WeatherService.iconName
                            : "weather-severe-alert-symbolic"
                        fallbackSymbol: WeatherService.available ? "☁" : "!"
                        iconColor: WeatherService.available
                            ? root.luminaDesign.color.primary
                            : root.luminaDesign.color.textMuted
                        iconSize: 20
                    }

                    Text {
                        id: weatherTemperature

                        anchors.verticalCenter: parent.verticalCenter
                        text: WeatherService.available
                            ? WeatherService.temperatureLabel
                            : WeatherService.loading
                                ? "…"
                                : "—"
                        color: root.luminaDesign.color.onSurface
                        font.pixelSize:
                            root.luminaDesign.typography.titleLarge
                        font.weight: Font.Bold
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                            - weatherIcon.width
                            - weatherTemperature.width
                            - weatherRange.width
                            - parent.spacing * 3
                        spacing: 0

                        Text {
                            width: parent.width
                            text: WeatherService.available
                                ? root.weatherCondition
                                : WeatherService.loading
                                    ? root.weatherUpdating
                                    : root.weatherUnavailable
                            color: root.luminaDesign.color.onSurface
                            elide: Text.ElideRight
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width
                            text: WeatherService.available
                                ? WeatherService.locationName
                                : WeatherService.lastError
                            color: root.luminaDesign.color.textMuted
                            elide: Text.ElideRight
                            font.pixelSize:
                                root.luminaDesign.typography.labelSmall
                        }
                    }

                    Text {
                        id: weatherRange

                        anchors.verticalCenter: parent.verticalCenter
                        text: root.weatherRangeLabel
                        color: root.luminaDesign.color.textMuted
                        font.pixelSize:
                            root.luminaDesign.typography.labelSmall
                        font.weight: Font.DemiBold
                    }
                }
            }
        }
    }
}

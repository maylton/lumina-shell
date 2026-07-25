pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.weather
import qs.stores.system
import qs.stores.time

Item {
    id: root

    property bool showWeather: true
    readonly property var luminaDesign: Theme.luminaTokens

    DashboardCard {
        id: welcomeCard

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: 152
        accessibleName: "Welcome"
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
                text: "Welcome, "
                    + SystemInfoStore.displayName
                    + "!"
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

        accessibleName: "Date and weather"

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
                text: Qt.formatDate(
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
                    ? WeatherService.condition
                        + ", "
                        + WeatherService.temperatureLabel
                        + ", "
                        + WeatherService.locationName
                    : WeatherService.loading
                        ? "Updating weather"
                        : "Weather unavailable"

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
                                ? WeatherService.condition
                                : WeatherService.loading
                                    ? "Updating weather"
                                    : "Weather unavailable"
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
                                    + " · Open-Meteo"
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
                        text: WeatherService.rangeLabel
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

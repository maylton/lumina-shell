pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.services.niri
import qs.services.weather
import qs.stores.niri
import qs.stores.time

Item {
    id: root

    required property string outputName

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var activeWorkspace:
        WorkspaceStore.activeForOutput(outputName)
    readonly property var output: OutputStore.byName(outputName)

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
            width: parent.width - root.luminaDesign.spacing.extraLarge * 2
            spacing: root.luminaDesign.spacing.small

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 58
                height: 58
                radius: root.luminaDesign.shape.full
                color: root.luminaDesign.color.accentContainer
                border.width: 2
                border.color: root.luminaDesign.color.primary

                Text {
                    anchors.centerIn: parent
                    text: String(
                        Quickshell.env("USER") || "L"
                    ).charAt(0).toLocaleUpperCase()
                    color: root.luminaDesign.color.onAccentContainer
                    font.pixelSize: 26
                    font.weight: Font.Bold
                }
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Welcome, "
                    + String(Quickshell.env("USER") || "Lumina")
                    + "!"
                color: root.luminaDesign.color.onSurface
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.titleLarge
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: activeWorkspace
                    ? "Workspace "
                        + WorkspaceStore.labelFor(activeWorkspace)
                    : outputName
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
            topMargin: root.luminaDesign.spacing.medium
        }

        accessibleName: "Date, weather, and output"

        Column {
            anchors.centerIn: parent
            width: parent.width - root.luminaDesign.spacing.extraLarge * 2
            spacing: root.luminaDesign.spacing.small

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

            Rectangle {
                width: parent.width
                height: 42
                radius: root.luminaDesign.shape.large
                color: root.luminaDesign.color.surfaceMuted

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

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width, outputSummary.implicitWidth + 28)
                height: 30
                radius: root.luminaDesign.shape.full
                color: root.luminaDesign.color.surfaceMuted

                Text {
                    id: outputSummary

                    anchors.centerIn: parent
                    text: root.output
                        ? root.outputName
                            + " · "
                            + OutputStore.resolutionLabel(root.output)
                            + " · "
                            + OutputStore.scaleLabel(root.output)
                        : NiriService.demoMode
                            ? "Demo output"
                            : root.outputName
                    color: root.luminaDesign.color.textMuted
                    font.pixelSize: root.luminaDesign.typography.labelSmall
                    font.weight: Font.DemiBold
                }
            }
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string requestedLocation:
        String(Quickshell.env("LUMINA_WEATHER_LOCATION") || "").trim()
    readonly property bool loading: timezoneProcess.running
        || geocodingProcess.running
        || forecastProcess.running
    readonly property string iconName: iconForCode(weatherCode)
    readonly property string temperatureLabel: available
        ? Math.round(temperature) + "°"
        : ""
    readonly property string rangeLabel: available
        ? "H " + Math.round(maximumTemperature)
            + "° · L " + Math.round(minimumTemperature) + "°"
        : ""

    property bool available: false
    property string locationName: ""
    property string condition: ""
    property int weatherCode: 0
    property real temperature: 0
    property real apparentTemperature: 0
    property real maximumTemperature: 0
    property real minimumTemperature: 0
    property real latitude: NaN
    property real longitude: NaN
    property double lastUpdated: 0
    property string lastError: ""
    property var forecast: []

    function geocodingUrl(locationQuery) {
        return "https://geocoding-api.open-meteo.com/v1/search"
            + "?name=" + encodeURIComponent(locationQuery)
            + "&count=1&language=en&format=json"
    }

    function forecastUrl() {
        return "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + latitude
            + "&longitude=" + longitude
            + "&current=temperature_2m,apparent_temperature,weather_code"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min"
            + "&temperature_unit=celsius"
            + "&timezone=auto"
            + "&forecast_days=3"
    }

    function timezoneCity(rawTimezone) {
        const timezone = String(rawTimezone || "").trim()
        const parts = timezone.split("/")
        const city = parts.length > 1 ? parts[parts.length - 1] : timezone

        return city.replace(/_/g, " ").trim()
    }

    function resolveLocation() {
        if (loading)
            return

        if (requestedLocation.length > 0) {
            requestGeocoding(requestedLocation)
            return
        }

        timezoneProcess.exec([
            "timedatectl",
            "show",
            "--property=Timezone",
            "--value"
        ])
    }

    function requestGeocoding(locationQuery) {
        const query = String(locationQuery || "").trim()

        if (!query) {
            lastError = "Weather location is not configured"
            return
        }

        geocodingProcess.exec([
            "curl",
            "--fail",
            "--silent",
            "--show-error",
            "--location",
            "--max-time",
            "10",
            "--user-agent",
            "Lumina-Shell/0.1",
            geocodingUrl(query)
        ])
    }

    function parseGeocoding(rawText) {
        let payload

        try {
            payload = JSON.parse(String(rawText || ""))
        } catch (error) {
            lastError = "Weather location response was not valid JSON"
            return false
        }

        if (!payload.results || payload.results.length === 0) {
            lastError = "Weather location was not found"
            return false
        }

        const result = payload.results[0]
        const area = String(result.name || requestedLocation)
        const region = String(result.admin1 || "")

        latitude = Number(result.latitude)
        longitude = Number(result.longitude)
        locationName = region.length > 0 && region !== area
            ? area + ", " + region
            : area

        if (!isFinite(latitude) || !isFinite(longitude)) {
            lastError = "Weather location coordinates were invalid"
            return false
        }

        return true
    }

    function parseForecast(rawText) {
        let payload

        try {
            payload = JSON.parse(String(rawText || ""))
        } catch (error) {
            lastError = "Weather response was not valid JSON"
            return false
        }

        const current = payload.current
        const daily = payload.daily

        if (!current
            || !daily
            || !daily.time
            || daily.time.length === 0) {
            lastError = "Weather response was incomplete"
            return false
        }

        const nextForecast = []

        for (var index = 0;
             index < Math.min(3, daily.time.length);
             ++index) {
            const code = Number(daily.weather_code[index] || 0)

            nextForecast.push({
                date: String(daily.time[index] || ""),
                minimum: Number(daily.temperature_2m_min[index] || 0),
                maximum: Number(daily.temperature_2m_max[index] || 0),
                weatherCode: code,
                condition: conditionForCode(code),
                iconName: iconForCode(code)
            })
        }

        weatherCode = Number(current.weather_code || 0)
        temperature = Number(current.temperature_2m || 0)
        apparentTemperature = Number(
            current.apparent_temperature || temperature
        )
        minimumTemperature = Number(
            daily.temperature_2m_min[0] || temperature
        )
        maximumTemperature = Number(
            daily.temperature_2m_max[0] || temperature
        )
        condition = conditionForCode(weatherCode)
        forecast = nextForecast
        available = true
        lastUpdated = Date.now()
        lastError = ""
        return true
    }

    function conditionForCode(code) {
        const value = Number(code || 0)

        if (value === 0)
            return "Clear"

        if ([1, 2].indexOf(value) >= 0)
            return "Partly cloudy"

        if (value === 3)
            return "Overcast"

        if ([45, 48].indexOf(value) >= 0)
            return "Fog"

        if (value >= 51 && value <= 57)
            return "Drizzle"

        if (value >= 61 && value <= 67)
            return "Rain"

        if (value >= 71 && value <= 77)
            return "Snow"

        if (value >= 80 && value <= 82)
            return "Rain showers"

        if ([85, 86].indexOf(value) >= 0)
            return "Snow showers"

        if (value >= 95)
            return "Thunderstorm"

        return "Current conditions"
    }

    function iconForCode(code) {
        const value = Number(code || 0)

        if (value === 0)
            return "weather-clear-symbolic"

        if ([1, 2].indexOf(value) >= 0)
            return "weather-few-clouds-symbolic"

        if (value === 3)
            return "weather-overcast-symbolic"

        if ([45, 48].indexOf(value) >= 0)
            return "weather-fog-symbolic"

        if ((value >= 71 && value <= 77)
            || [85, 86].indexOf(value) >= 0) {
            return "weather-snow-symbolic"
        }

        if (value >= 95)
            return "weather-storm-symbolic"

        if ((value >= 51 && value <= 67)
            || (value >= 80 && value <= 82)) {
            return "weather-showers-symbolic"
        }

        return "weather-severe-alert-symbolic"
    }

    function requestForecast() {
        if (!isFinite(latitude)
            || !isFinite(longitude)
            || forecastProcess.running) {
            return
        }

        forecastProcess.exec([
            "curl",
            "--fail",
            "--silent",
            "--show-error",
            "--location",
            "--max-time",
            "10",
            "--user-agent",
            "Lumina-Shell/0.1",
            forecastUrl()
        ])
    }

    function refresh() {
        if (loading)
            return

        if (isFinite(latitude) && isFinite(longitude))
            requestForecast()
        else
            resolveLocation()
    }

    Component.onCompleted: resolveLocation()

    Process {
        id: timezoneProcess

        stdout: StdioCollector {
            id: timezoneOutput
        }

        stderr: StdioCollector {
            id: timezoneError
        }

        onExited: (exitCode, exitStatus) => {
            const city = exitCode === 0
                ? root.timezoneCity(timezoneOutput.text)
                : ""

            if (city.length > 0) {
                root.requestGeocoding(city)
            } else {
                root.lastError = String(timezoneError.text || "").trim()
                    || "Could not derive weather location from timezone"
            }
        }
    }

    Process {
        id: geocodingProcess

        stdout: StdioCollector {
            id: geocodingOutput
        }

        stderr: StdioCollector {
            id: geocodingError
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0
                && root.parseGeocoding(geocodingOutput.text)) {
                root.requestForecast()
                return
            }

            root.lastError = String(geocodingError.text || "").trim()
                || root.lastError
                || "Weather geocoding unavailable"
        }
    }

    Process {
        id: forecastProcess

        stdout: StdioCollector {
            id: forecastOutput
        }

        stderr: StdioCollector {
            id: forecastError
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0
                && root.parseForecast(forecastOutput.text)) {
                return
            }

            root.lastError = String(forecastError.text || "").trim()
                || root.lastError
                || "Weather service unavailable"
        }
    }

    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    IpcHandler {
        target: "weather"

        function refresh(): void {
            root.refresh()
        }

        function status(): string {
            return JSON.stringify({
                available: root.available,
                loading: root.loading,
                location: root.locationName,
                coordinates: {
                    latitude: root.latitude,
                    longitude: root.longitude
                },
                condition: root.condition,
                weatherCode: root.weatherCode,
                temperature: root.temperature,
                apparentTemperature: root.apparentTemperature,
                minimum: root.minimumTemperature,
                maximum: root.maximumTemperature,
                forecast: root.forecast,
                updatedAt: root.lastUpdated,
                provider: "Open-Meteo",
                error: root.lastError
            })
        }
    }
}

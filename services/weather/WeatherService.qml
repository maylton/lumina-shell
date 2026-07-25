pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.i18n
import qs.stores.config
import qs.stores.weather

Singleton {
    id: root

    readonly property bool enabled: ConfigStore.dashboardShowWeather
    readonly property string overrideLocation:
        String(Quickshell.env("LUMINA_WEATHER_LOCATION") || "").trim()
    readonly property string locationMode: overrideLocation.length > 0
        ? "manual"
        : WeatherPreferences.locationMode
    readonly property string manualCity: overrideLocation.length > 0
        ? overrideLocation
        : WeatherPreferences.manualCity
    readonly property bool loading: geoIpProcess.running
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
    readonly property string cachePath:
        Quickshell.cacheDir + "/lumina-weather-location.json"
    readonly property double cacheLifetime: 24 * 60 * 60 * 1000

    property bool available: false
    property bool cacheLoaded: false
    property string locationName: ""
    property string condition: ""
    property string locationSource: ""
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

    function languageCode() {
        const value = String(I18n.locale || "en-US")
        return value.split("-")[0] || "en"
    }

    function geocodingUrl(locationQuery) {
        return "https://geocoding-api.open-meteo.com/v1/search"
            + "?name=" + encodeURIComponent(locationQuery)
            + "&count=1&language=" + encodeURIComponent(languageCode())
            + "&format=json"
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

    function cacheIsFresh() {
        return cacheLoaded
            && Number(cacheAdapter.updatedAt) > 0
            && Date.now() - Number(cacheAdapter.updatedAt) < cacheLifetime
            && isFinite(Number(cacheAdapter.latitude))
            && isFinite(Number(cacheAdapter.longitude))
            && String(cacheAdapter.city || "").length > 0
    }

    function applyLocation(city, region, nextLatitude, nextLongitude, source) {
        const area = String(city || "").trim()
        const regionName = String(region || "").trim()
        const lat = Number(nextLatitude)
        const lon = Number(nextLongitude)

        if (!area || !isFinite(lat) || !isFinite(lon))
            return false

        latitude = lat
        longitude = lon
        locationName = regionName && regionName !== area
            ? area + ", " + regionName
            : area
        locationSource = String(source || "")
        return true
    }

    function applyCachedLocation() {
        if (!cacheIsFresh())
            return false

        return applyLocation(
            cacheAdapter.city,
            cacheAdapter.region,
            cacheAdapter.latitude,
            cacheAdapter.longitude,
            "automatic-ip-cache"
        )
    }

    function writeLocationCache(city, region, lat, lon) {
        cacheAdapter.city = String(city || "")
        cacheAdapter.region = String(region || "")
        cacheAdapter.latitude = Number(lat)
        cacheAdapter.longitude = Number(lon)
        cacheAdapter.updatedAt = Date.now()
        cacheFile.writeAdapter()
    }

    function clearForecast() {
        available = false
        condition = ""
        weatherCode = 0
        temperature = 0
        apparentTemperature = 0
        maximumTemperature = 0
        minimumTemperature = 0
        forecast = []
        lastUpdated = 0
    }

    function resolveLocation(forceAutomaticLookup) {
        if (!enabled || loading || !WeatherPreferences.initialized)
            return

        lastError = ""

        if (locationMode === "manual") {
            if (!manualCity) {
                clearForecast()
                lastError = "Weather city is not configured"
                return
            }

            requestGeocoding(manualCity)
            return
        }

        if (!forceAutomaticLookup && applyCachedLocation()) {
            requestForecast()
            return
        }

        geoIpProcess.exec([
            "curl",
            "--fail",
            "--silent",
            "--show-error",
            "--location",
            "--max-time",
            "10",
            "--user-agent",
            "Lumina-Shell/0.1",
            "https://ipapi.co/json/"
        ])
    }

    function requestGeocoding(locationQuery) {
        const query = String(locationQuery || "").trim()

        if (!query || geocodingProcess.running)
            return

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

    function parseGeoIp(rawText) {
        let payload

        try {
            payload = JSON.parse(String(rawText || ""))
        } catch (error) {
            lastError = "Automatic weather location response was not valid JSON"
            return false
        }

        if (payload.error) {
            lastError = String(payload.reason || "Automatic location unavailable")
            return false
        }

        const city = String(payload.city || "")
        const region = String(payload.region || "")
        const lat = Number(payload.latitude)
        const lon = Number(payload.longitude)

        if (!applyLocation(city, region, lat, lon, "automatic-ip")) {
            lastError = "Automatic weather location was incomplete"
            return false
        }

        writeLocationCache(city, region, lat, lon)
        return true
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
        const area = String(result.name || manualCity)
        const region = String(result.admin1 || "")

        if (!applyLocation(
            area,
            region,
            result.latitude,
            result.longitude,
            "manual"
        )) {
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
        if (!enabled
            || !isFinite(latitude)
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

    function refresh(forceLocation) {
        if (!enabled) {
            clearForecast()
            return
        }

        if (Boolean(forceLocation)) {
            latitude = NaN
            longitude = NaN
            resolveLocation(true)
        } else if (isFinite(latitude) && isFinite(longitude)) {
            requestForecast()
        } else {
            resolveLocation(false)
        }
    }

    function reconfigure() {
        clearForecast()
        latitude = NaN
        longitude = NaN
        locationName = ""
        locationSource = ""
        lastError = ""

        if (enabled)
            Qt.callLater(function() { root.resolveLocation(false) })
    }

    Component.onCompleted: {
        if (WeatherPreferences.initialized)
            reconfigure()
    }

    Connections {
        target: ConfigStore

        function onDashboardShowWeatherChanged() {
            root.reconfigure()
        }
    }

    Connections {
        target: WeatherPreferences

        function onInitializedChanged() {
            if (WeatherPreferences.initialized)
                root.reconfigure()
        }

        function onLocationModeChanged() {
            root.reconfigure()
        }

        function onManualCityChanged() {
            if (WeatherPreferences.locationMode === "manual")
                root.reconfigure()
        }

        function onRefreshIntervalChanged() {
            refreshTimer.restart()
        }
    }

    FileView {
        id: cacheFile

        path: root.cachePath
        preload: true
        atomicWrites: true
        watchChanges: false
        printErrors: false

        adapter: JsonAdapter {
            id: cacheAdapter

            property string city: ""
            property string region: ""
            property real latitude: NaN
            property real longitude: NaN
            property double updatedAt: 0
        }

        onLoaded: {
            root.cacheLoaded = true
            if (root.enabled && WeatherPreferences.initialized)
                root.resolveLocation(false)
        }

        onLoadFailed: error => {
            root.cacheLoaded = true
            if (root.enabled && WeatherPreferences.initialized)
                root.resolveLocation(false)
        }
    }

    Process {
        id: geoIpProcess

        stdout: StdioCollector { id: geoIpOutput }
        stderr: StdioCollector { id: geoIpError }

        onExited: (exitCode, exitStatus) => {
            if (!root.enabled)
                return

            if (exitCode === 0 && root.parseGeoIp(geoIpOutput.text)) {
                root.requestForecast()
                return
            }

            if (root.applyCachedLocation()) {
                root.requestForecast()
                return
            }

            root.lastError = String(geoIpError.text || "").trim()
                || root.lastError
                || "Automatic weather location unavailable"
        }
    }

    Process {
        id: geocodingProcess

        stdout: StdioCollector { id: geocodingOutput }
        stderr: StdioCollector { id: geocodingError }

        onExited: (exitCode, exitStatus) => {
            if (!root.enabled)
                return

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

        stdout: StdioCollector { id: forecastOutput }
        stderr: StdioCollector { id: forecastError }

        onExited: (exitCode, exitStatus) => {
            if (!root.enabled)
                return

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
        id: refreshTimer

        interval: Math.max(15, WeatherPreferences.refreshInterval)
            * 60 * 1000
        running: root.enabled && WeatherPreferences.initialized
        repeat: true
        onTriggered: root.refresh(false)
    }

    IpcHandler {
        target: "weather"

        function refresh(): void {
            root.refresh(true)
        }

        function status(): string {
            return JSON.stringify({
                enabled: root.enabled,
                loading: root.loading,
                available: root.available,
                locationMode: root.locationMode,
                locationSource: root.locationSource,
                location: root.locationName,
                manualCity: root.manualCity,
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
                refreshInterval: WeatherPreferences.refreshInterval,
                updatedAt: root.lastUpdated,
                provider: "Open-Meteo",
                automaticLocationProvider: "ipapi.co",
                error: root.lastError
            })
        }
    }
}

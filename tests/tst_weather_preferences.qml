import QtQuick
import QtTest
import "../stores/weather/WeatherPreferences.js" as WeatherLogic

TestCase {
    name: "WeatherPreferences"

    function test_defaultsUseAutomaticIp() {
        const state = WeatherLogic.defaults()

        compare(state.schemaVersion, 1)
        compare(state.locationMode, "automatic-ip")
        compare(state.manualCity, "")
        compare(state.refreshInterval, 30)
    }

    function test_normalizesInvalidValues() {
        const state = WeatherLogic.normalize({
            locationMode: "satellite",
            manualCity: "  João Pessoa  ",
            refreshInterval: 17
        })

        compare(state.locationMode, "automatic-ip")
        compare(state.manualCity, "João Pessoa")
        compare(state.refreshInterval, 30)
    }

    function test_acceptsSupportedManualSettings() {
        const state = WeatherLogic.normalize({
            locationMode: "manual",
            manualCity: "Recife",
            refreshInterval: 120
        })

        compare(state.locationMode, "manual")
        compare(state.manualCity, "Recife")
        compare(state.refreshInterval, 120)
    }
}

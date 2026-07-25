import QtQuick
import Quickshell
import qs.services.audio
import qs.services.brightness
import qs.services.connectivity
import qs.services.config
import qs.services.media
import qs.services.power
import qs.services.weather

Scope {
    readonly property var audioService: AudioService
    readonly property var brightnessService: BrightnessService
    readonly property var connectivityService: ConnectivityService
    readonly property var configFileService: ConfigFileService
    readonly property var mediaService: MediaService
    readonly property var powerService: PowerService
    readonly property var weatherService: WeatherService
}

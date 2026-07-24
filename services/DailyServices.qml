import QtQuick
import Quickshell
import qs.services.audio
import qs.services.brightness
import qs.services.media
import qs.services.power

Scope {
    readonly property var audioService: AudioService
    readonly property var brightnessService: BrightnessService
    readonly property var mediaService: MediaService
    readonly property var powerService: PowerService
}

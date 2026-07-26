import QtQuick
import QtTest
import "../services/audio/AudioNodePolicy.js" as AudioNodePolicy

TestCase {
    name: "AudioNodePolicy"

    function node(mediaClass, overrides) {
        const result = {
            name: "",
            description: "",
            nickname: "",
            properties: {
                "media.class": mediaClass
            }
        }
        const source = overrides || {}

        for (const key in source) {
            if (key === "properties") {
                for (const propertyName in source.properties)
                    result.properties[propertyName] =
                        source.properties[propertyName]
            } else {
                result[key] = source[key]
            }
        }

        return result
    }

    function test_classifiesDevicesAndApplicationStreams() {
        const output = node("Audio/Sink")
        const input = node("Audio/Source")
        const playback = node("Stream/Output/Audio")
        const capture = node("Stream/Input/Audio")

        verify(AudioNodePolicy.isOutputDevice(output))
        verify(AudioNodePolicy.isInputDevice(input))
        verify(AudioNodePolicy.isPlaybackStream(playback))
        verify(AudioNodePolicy.isCaptureStream(capture))
        verify(AudioNodePolicy.isApplicationStream(playback))
        verify(AudioNodePolicy.isApplicationStream(capture))
        verify(!AudioNodePolicy.isApplicationStream(output))
    }

    function test_applicationLabelPrefersApplicationIdentity() {
        const stream = node("Stream/Output/Audio", {
            name: "chromium-output",
            description: "Chromium stream",
            properties: {
                "application.name": "Chromium",
                "media.name": "Video playback"
            }
        })

        compare(AudioNodePolicy.label(stream), "Chromium")
        compare(AudioNodePolicy.detail(stream), "Video playback")
    }

    function test_deviceLabelUsesDescriptionAndFallbacks() {
        const described = node("Audio/Sink", {
            name: "alsa_output.test",
            description: "USB Speakers"
        })
        const named = node("Audio/Source", {
            name: "alsa_input.test"
        })

        compare(AudioNodePolicy.label(described), "USB Speakers")
        compare(AudioNodePolicy.label(named), "alsa_input.test")
    }

    function test_iconUsesApplicationThenAudioKind() {
        const application = node("Stream/Output/Audio", {
            properties: {
                "application.icon-name": "firefox"
            }
        })
        const input = node("Audio/Source")
        const playback = node("Stream/Output/Audio")

        compare(AudioNodePolicy.iconName(application), "firefox")
        compare(
            AudioNodePolicy.iconName(input),
            "audio-input-microphone-symbolic"
        )
        compare(
            AudioNodePolicy.iconName(playback),
            "audio-volume-high-symbolic"
        )
    }
}

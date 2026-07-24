pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool open: activeOutputName.length > 0

    property string activeOutputName: ""

    function defaultOutputName() {
        const screens = Quickshell.screens || []

        return screens.length > 0 ? String(screens[0].name || "") : ""
    }

    function resolvedOutputName(outputName) {
        const requested = String(outputName || "")
        const screens = Quickshell.screens || []

        for (var i = 0; i < screens.length; ++i) {
            if (String(screens[i].name || "") === requested)
                return requested
        }

        return defaultOutputName()
    }

    function openFor(outputName) {
        activeOutputName = resolvedOutputName(outputName)
    }

    function close() {
        activeOutputName = ""
    }

    function toggle(outputName) {
        const targetOutput = resolvedOutputName(outputName)

        if (activeOutputName === targetOutput)
            close()
        else
            openFor(targetOutput)
    }
}

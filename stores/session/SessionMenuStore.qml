pragma Singleton

import QtQuick
import Quickshell
import qs.stores.shell

Singleton {
    id: root

    readonly property bool open: activeOutputName.length > 0
    readonly property string activeOutputName:
        OverlayStore.activeSurface === "session"
            ? OverlayStore.activeOutputName
            : ""

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
        OverlayStore.openFor("session", resolvedOutputName(outputName))
    }

    function close() {
        OverlayStore.close("session")
    }

    function toggle(outputName) {
        const targetOutput = resolvedOutputName(outputName)

        if (activeOutputName === targetOutput)
            close()
        else
            openFor(targetOutput)
    }
}

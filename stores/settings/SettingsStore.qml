pragma Singleton

import QtQuick
import Quickshell
import qs.stores.config
import qs.stores.shell

Singleton {
    id: root

    readonly property bool open: activeOutputName.length > 0
    readonly property string activeOutputName:
        OverlayStore.activeSurface === "settings"
            ? OverlayStore.activeOutputName
            : ""

    property bool resetConfirmation: false

    function openFor(outputName) {
        resetConfirmation = false
        OverlayStore.openFor("settings", outputName)
    }

    function close() {
        resetConfirmation = false
        OverlayStore.close("settings")
    }

    function toggle(outputName) {
        if (OverlayStore.isOpenFor("settings", outputName)) {
            close()
        } else {
            openFor(outputName)
        }
    }

    function requestReset() {
        resetConfirmation = true
    }

    function cancelReset() {
        resetConfirmation = false
    }

    function confirmReset() {
        if (!resetConfirmation)
            return

        ConfigStore.reset()
        resetConfirmation = false
    }

    Connections {
        target: OverlayStore

        function onActiveSurfaceChanged() {
            if (OverlayStore.activeSurface !== "settings")
                root.resetConfirmation = false
        }
    }
}

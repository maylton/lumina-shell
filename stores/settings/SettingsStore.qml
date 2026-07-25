pragma Singleton

import QtQuick
import Quickshell
import qs.stores.config
import qs.stores.control
import qs.stores.shell

Singleton {
    id: root

    readonly property bool open: ControlCenterStore.open
        && ControlCenterStore.activePage === "settings"
    readonly property string activeOutputName:
        open
            ? ControlCenterStore.activeOutputName
            : ""
    readonly property string activeCategory:
        ControlCenterStore.settingsCategory

    property bool resetConfirmation: false

    function openFor(outputName) {
        resetConfirmation = false
        ControlCenterStore.openFor(outputName, "settings")
    }

    function openCategory(categoryName, outputName) {
        resetConfirmation = false
        ControlCenterStore.openFor(
            outputName,
            "settings",
            categoryName
        )
    }

    function setCategory(categoryName) {
        ControlCenterStore.setSettingsCategory(categoryName)
    }

    function close() {
        resetConfirmation = false

        if (open)
            ControlCenterStore.close()
    }

    function toggle(outputName) {
        if (open && activeOutputName === String(outputName || "")) {
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
        target: ControlCenterStore

        function onActivePageChanged() {
            if (ControlCenterStore.activePage !== "settings")
                root.resetConfirmation = false
        }
    }

    Connections {
        target: OverlayStore

        function onActiveSurfaceChanged() {
            if (OverlayStore.activeSurface !== "control")
                root.resetConfirmation = false
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell
import qs.stores.shell

Singleton {
    id: root

    readonly property bool open: activeOutputName.length > 0
    readonly property string activeOutputName:
        OverlayStore.activeSurface === "control"
            ? OverlayStore.activeOutputName
            : ""

    function openFor(outputName) {
        OverlayStore.openFor("control", outputName)
    }

    function close() {
        OverlayStore.close("control")
    }

    function toggle(outputName) {
        OverlayStore.toggle("control", outputName)
    }
}

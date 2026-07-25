import QtQuick

Item {
    // noctalia-qs 0.0.12 does not provide a reliable capture/camera usage
    // source here. Microphone mute state is intentionally not treated as use.
    readonly property bool sourceAvailable: false

    visible: false
    implicitWidth: 0
    implicitHeight: 0
}

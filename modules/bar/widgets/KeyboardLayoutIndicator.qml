import QtQuick

Item {
    // Niri 26.04 does not expose a stable keyboard-layout event through the
    // service used by Lumina. Keep the placement contract without presenting
    // inferred or polled data.
    readonly property bool sourceAvailable: false

    visible: false
    implicitWidth: 0
    implicitHeight: 0
}

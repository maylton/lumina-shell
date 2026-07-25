import QtQuick
import qs.design
import qs.stores.config

Rectangle {
    id: root

    required property string activeWindowTitle
    required property string activeWindowAppId
    required property string columnLabel
    required property string workspaceLabel
    required property bool showActionError
    required property string actionError
    property real availableWidth: 0

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property string contextText: {
        if (showActionError && actionError.length > 0)
            return "Niri action failed · " + actionError

        const parts = []

        if (ConfigStore.barShowWindowTitle
            && activeWindowTitle.length > 0)
            parts.push(activeWindowTitle)
        else if (activeWindowAppId.length > 0)
            parts.push(activeWindowAppId)
        else if (workspaceLabel.length > 0)
            parts.push(workspaceLabel)
        else
            parts.push("Desktop")

        if (ConfigStore.barShowAppId
            && activeWindowAppId.length > 0
            && activeWindowAppId !== activeWindowTitle)
            parts.push(activeWindowAppId)

        if (ConfigStore.barShowColumnIndicator
            && columnLabel.length > 0)
            parts.push(columnLabel)

        return parts.join(" · ")
    }
    readonly property string changeSignature: [
        activeWindowTitle,
        activeWindowAppId,
        columnLabel,
        workspaceLabel,
        showActionError,
        actionError
    ].join("\u001f")
    readonly property bool hasContext: contextText.length > 0
    readonly property bool shouldShow:
        ConfigStore.barContextMode === "always"
        || ConfigStore.barContextMode === "contextual"
            && revealContext
    readonly property real targetWidth: shouldShow && hasContext
        ? Math.max(
            0,
            Math.min(
                contextLabel.implicitWidth + 28,
                availableWidth
            )
        )
        : 0

    property bool revealContext: false

    width: targetWidth
    height: luminaDesign.size.barTouchTarget
    radius: shouldShow
        ? luminaDesign.shape.full
        : luminaDesign.shape.small
    color: showActionError
        ? Qt.rgba(
            luminaDesign.color.urgent.r,
            luminaDesign.color.urgent.g,
            luminaDesign.color.urgent.b,
            0.14
        )
        : luminaDesign.color.surfaceMuted
    opacity: shouldShow && targetWidth >= 72 ? 1 : 0
    visible: ConfigStore.barContextMode !== "hidden"
        && (opacity > 0 || width > 0)
    clip: true

    Accessible.role: Accessible.StaticText
    Accessible.name: contextText

    function reveal() {
        if (ConfigStore.barContextMode !== "contextual"
            || !hasContext)
            return

        revealContext = true
        hideTimer.restart()
    }

    onChangeSignatureChanged: reveal()

    Component.onCompleted: reveal()

    Connections {
        target: ConfigStore

        function onBarContextModeChanged() {
            if (ConfigStore.barContextMode === "contextual")
                root.reveal()
            else
                hideTimer.stop()
        }

        function onBarContextTimeoutChanged() {
            if (root.revealContext)
                hideTimer.restart()
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: root.luminaDesign.motion.medium
            easing.type: Easing.OutCubic
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.luminaDesign.motion.medium
            easing.type: Easing.OutCubic
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: root.luminaDesign.motion.fast
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.fast
        }
    }

    Text {
        id: contextLabel

        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 14
        }
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: root.contextText
        color: root.showActionError
            ? root.luminaDesign.color.urgent
            : root.luminaDesign.color.onSurface
        elide: Text.ElideRight
        font.pixelSize: root.luminaDesign.typography.bodyMedium
        font.weight: Font.DemiBold
    }

    Timer {
        id: hideTimer

        interval: ConfigStore.barContextTimeout
        repeat: false
        onTriggered: root.revealContext = false
    }
}

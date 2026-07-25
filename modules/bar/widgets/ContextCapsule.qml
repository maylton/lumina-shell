import QtQuick
import QtQuick.Layouts
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
    readonly property string displayMode: String(
        ConfigStore.widgetSetting(
            "context",
            "mode",
            "contextual"
        )
    )
    readonly property bool showBackground: Boolean(
        ConfigStore.widgetSetting(
            "context",
            "showBackground",
            true
        )
    )
    readonly property bool showWindowTitle: Boolean(
        ConfigStore.widgetSetting(
            "context",
            "showWindowTitle",
            true
        )
    )
    readonly property bool showWorkspace: Boolean(
        ConfigStore.widgetSetting(
            "context",
            "showWorkspace",
            true
        )
    )
    readonly property bool showApplicationId: Boolean(
        ConfigStore.widgetSetting(
            "context",
            "showApplicationId",
            true
        )
    )
    readonly property bool showColumn: Boolean(
        ConfigStore.widgetSetting(
            "context",
            "showColumn",
            true
        )
    )
    readonly property int displayTimeout: Number(
        ConfigStore.widgetSetting(
            "context",
            "timeout",
            3500
        )
    )
    readonly property string primaryText: {
        if (showActionError && actionError.length > 0)
            return "Niri action failed"

        if (showWindowTitle
            && activeWindowTitle.length > 0)
            return activeWindowTitle

        if (showApplicationId && activeWindowAppId.length > 0)
            return activeWindowAppId

        if (showWorkspace && workspaceLabel.length > 0)
            return workspaceLabel

        return "Desktop"
    }
    readonly property string secondaryText: {
        if (showActionError && actionError.length > 0)
            return actionError

        const parts = []

        if (showWorkspace
            && workspaceLabel.length > 0
            && workspaceLabel !== primaryText)
            parts.push(workspaceLabel)

        if (showApplicationId
            && activeWindowAppId.length > 0
            && activeWindowAppId !== primaryText)
            parts.push(activeWindowAppId)

        if (showColumn
            && columnLabel.length > 0)
            parts.push(columnLabel)

        return parts.join(" · ")
    }
    readonly property real scaledWidthReference:
        luminaDesign.size.barContentScale
    readonly property real secondaryWidthThreshold:
        Math.round(280 * scaledWidthReference)
    readonly property real visibleWidthThreshold:
        Math.round(72 * scaledWidthReference)
    readonly property bool showSecondary:
        secondaryText.length > 0
        && availableWidth >= secondaryWidthThreshold
    readonly property string contextText: showSecondary
        ? primaryText + " · " + secondaryText
        : primaryText
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
        displayMode === "always"
        || (
            displayMode === "contextual"
            && revealContext
        )
    readonly property real contentImplicitWidth:
        primaryLabel.implicitWidth
        + (
            showSecondary
                ? secondaryLabel.implicitWidth
                    + contextRow.spacing * 2
                    + contextDivider.width
                : 0
        )
    readonly property real targetWidth: shouldShow && hasContext
        ? Math.max(
            0,
            Math.min(
                contentImplicitWidth
                    + (
                        luminaDesign.spacing.barHorizontalPadding
                        * 2
                    ),
                availableWidth
            )
        )
        : 0

    property bool revealContext: false

    width: targetWidth
    height: luminaDesign.size.barTouchTarget
    radius: shouldShow
        ? luminaDesign.shape.full
        : luminaDesign.shape.barSmall
    color: showActionError
        ? Qt.rgba(
            luminaDesign.color.urgent.r,
            luminaDesign.color.urgent.g,
            luminaDesign.color.urgent.b,
            0.14
        )
        : showBackground
            ? luminaDesign.color.surfaceMuted
            : "transparent"
    opacity: shouldShow
        && targetWidth >= visibleWidthThreshold
            ? 1
            : 0
    visible: displayMode !== "hidden"
        && (opacity > 0 || width > 0)
    clip: true

    Accessible.role: Accessible.StaticText
    Accessible.name: contextText

    function reveal() {
        if (displayMode !== "contextual"
            || !hasContext)
            return

        revealContext = true
        hideTimer.restart()
    }

    onChangeSignatureChanged: reveal()

    Component.onCompleted: reveal()

    Connections {
        target: ConfigStore

        function onBarWidgetSettingsChanged() {
            if (root.displayMode === "contextual")
                root.reveal()
            else
                hideTimer.stop()
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: root.shouldShow
                ? root.luminaDesign.motion.spatialDefault
                : root.luminaDesign.motion.spatialFast
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.shouldShow
                ? root.luminaDesign.motion.spatialDefault
                : root.luminaDesign.motion.spatialFast
            easing.type: root.luminaDesign.motion.spatialEasing
            easing.overshoot:
                root.luminaDesign.motion.spatialOvershoot
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: root.shouldShow
                ? root.luminaDesign.motion.effectsDefault
                : root.luminaDesign.motion.effectsFast
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: root.luminaDesign.motion.effectsDefault
            easing.type: root.luminaDesign.motion.effectsEasing
        }
    }

    RowLayout {
        id: contextRow

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        width: Math.max(
            0,
            root.width
                - (
                    root.luminaDesign.spacing.barHorizontalPadding
                    * 2
                )
        )
        height: parent.height
        spacing: root.luminaDesign.spacing.barItemGap

        Text {
            id: primaryLabel

            Layout.fillWidth: true
            Layout.minimumWidth: Math.min(
                Math.round(
                    72 * root.scaledWidthReference
                ),
                implicitWidth
            )
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: root.showSecondary
                ? Text.AlignLeft
                : Text.AlignHCenter
            text: root.primaryText
            color: root.showActionError
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize:
                root.luminaDesign.typography.barContextPrimary
            font.weight: Font.DemiBold
        }

        Rectangle {
            id: contextDivider

            Layout.alignment: Qt.AlignVCenter
            visible: root.showSecondary
            width: root.luminaDesign.size.barDividerDot
            height: width
            radius: width / 2
            color: root.showActionError
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.outline
        }

        Text {
            id: secondaryLabel

            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: contextRow.width * 0.56
            visible: root.showSecondary
            text: root.secondaryText
            color: root.showActionError
                ? root.luminaDesign.color.urgent
                : root.luminaDesign.color.textMuted
            elide: Text.ElideRight
            font.pixelSize:
                root.luminaDesign.typography.barContextSecondary
            font.weight: Font.Medium
        }
    }

    Timer {
        id: hideTimer

        interval: root.displayTimeout
        repeat: false
        onTriggered: root.revealContext = false
    }
}

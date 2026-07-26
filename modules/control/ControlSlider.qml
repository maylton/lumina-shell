pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.stores.shell

Rectangle {
    id: root

    required property string title
    property string iconName: ""
    property string symbol: ""
    property string detail: ""
    property real value: 0
    property bool available: true
    property double benchmarkRequestedAt: 0

    signal valueRequested(real value)

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real clampedValue: Math.max(
        0,
        Math.min(1, Number(value) || 0)
    )

    function adjustBy(delta) {
        if (!available)
            return

        valueRequested(Math.max(
            0,
            Math.min(1, clampedValue + delta)
        ))
    }

    function benchmarkValue(candidate) {
        if (!available)
            return

        const normalized = Math.max(
            0,
            Math.min(1, Number(candidate))
        )
        benchmarkRequestedAt = Date.now()
        PerformanceTrace.recordInstant(
            "slider",
            title,
            "requested",
            { normalized: normalized }
        )
        valueRequested(normalized)
        benchmarkSettleTimer.restart()
    }

    implicitHeight: 72
    radius: luminaDesign.shape.large
    color: luminaDesign.color.surfaceMuted
    opacity: available ? 1 : 0.55
    activeFocusOnTab: available
    border.width: activeFocus ? 2 : 0
    border.color: luminaDesign.color.primary

    Accessible.role: Accessible.Slider
    Accessible.name: title
    Accessible.description: detail
    Accessible.focusable: available
    Accessible.focused: activeFocus
    Accessible.onIncreaseAction: root.adjustBy(0.05)
    Accessible.onDecreaseAction: root.adjustBy(-0.05)

    Keys.onLeftPressed: event => {
        root.adjustBy(-0.05)
        event.accepted = true
    }

    Keys.onRightPressed: event => {
        root.adjustBy(0.05)
        event.accepted = true
    }

    Timer {
        id: benchmarkSettleTimer

        interval: root.luminaDesign.motion.effectsFast
        repeat: false
        onTriggered: {
            PerformanceTrace.record(
                "slider",
                root.title,
                "settled",
                Math.max(
                    0,
                    Date.now()
                        - root.benchmarkRequestedAt
                        - interval
                ),
                {
                    value: root.value,
                    expectedDurationMs: interval,
                    totalDurationMs:
                        Date.now() - root.benchmarkRequestedAt
                }
            )
        }
    }

    Row {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: root.luminaDesign.spacing.large
            rightMargin: root.luminaDesign.spacing.large
            topMargin: root.luminaDesign.spacing.small
        }

        DashboardIcon {
            width: 28
            height: 18
            iconName: root.iconName
            fallbackSymbol: root.symbol
            iconColor: root.available
                ? root.luminaDesign.color.primary
                : root.luminaDesign.color.textMuted
            iconSize: 16
        }

        Text {
            width: parent.width - 88
            text: root.title
            color: root.luminaDesign.color.onSurface
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.bodyMedium
            font.weight: Font.DemiBold
        }

        Text {
            width: 60
            horizontalAlignment: Text.AlignRight
            text: root.detail
            color: root.luminaDesign.color.textMuted
            elide: Text.ElideRight
            font.pixelSize: root.luminaDesign.typography.labelSmall
        }
    }

    MaterialSlider {
        id: sliderTrack

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: root.luminaDesign.spacing.large
            rightMargin: root.luminaDesign.spacing.large
            bottom: parent.bottom
            bottomMargin: root.luminaDesign.spacing.small
        }

        height: implicitHeight
        value: root.clampedValue
        available: root.available
        activeColor: root.available
            ? root.luminaDesign.color.primary
            : root.luminaDesign.color.outline
        inactiveColor: root.luminaDesign.color.surfaceBase
        handleColor: root.available
            ? root.luminaDesign.color.primary
            : root.luminaDesign.color.outline

        onInteractionStarted:
            root.forceActiveFocus(Qt.MouseFocusReason)
        onValueRequested: value => root.valueRequested(value)
    }
}

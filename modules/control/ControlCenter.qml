pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.design
import qs.services.notifications
import qs.stores.config
import qs.stores.control
import qs.stores.settings
import qs.stores.time
import qs.stores.shell
import "ShellSurfacePolicy.js" as ShellSurfacePolicy
import "../../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

Scope {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    property var controlWindows: ({})

    function registerControlWindow(outputName, windowObject) {
        const output = String(outputName || "")
        if (!output || !windowObject)
            return

        const windows = Object.assign({}, controlWindows)
        windows[output] = windowObject
        controlWindows = windows
    }

    function unregisterControlWindow(outputName, windowObject) {
        const output = String(outputName || "")
        if (!output || controlWindows[output] !== windowObject)
            return

        const windows = Object.assign({}, controlWindows)
        delete windows[output]
        controlWindows = windows
    }

    function controlWindowFor(outputName) {
        return controlWindows[String(outputName || "")] || null
    }

    IpcHandler {
        target: "control"

        function open(outputName: string): void {
            ControlCenterStore.openFor(outputName, "dashboard")
        }

        function close(): void {
            ControlCenterStore.close()
        }

        function toggle(outputName: string): void {
            ControlCenterStore.toggle(outputName)
        }

        function page(pageName: string): void {
            ControlCenterStore.setPage(pageName)
        }

        function tab(tabName: string): void {
            ControlCenterStore.setPage(tabName)
        }

        function status(): string {
            return JSON.stringify({
                open: ControlCenterStore.open,
                output: ControlCenterStore.activeOutputName,
                page: ControlCenterStore.activePage,
                tab: ControlCenterStore.activePage,
                settingsCategory:
                    ControlCenterStore.settingsCategory
            })
        }

        function performanceStatus(outputName: string): string {
            const windowObject = root.controlWindowFor(outputName)
            return JSON.stringify(
                windowObject
                    ? windowObject.performanceStatus()
                    : { error: "output-not-found" }
            )
        }

        function performanceDropdown(
            outputName: string,
            index: int
        ): void {
            const windowObject = root.controlWindowFor(outputName)
            if (windowObject)
                windowObject.togglePerformanceDropdown(index)
        }

        function performanceSettingsSlider(
            outputName: string,
            index: int,
            normalized: real
        ): void {
            const windowObject = root.controlWindowFor(outputName)
            if (windowObject) {
                windowObject.setPerformanceSettingsSlider(
                    index,
                    normalized
                )
            }
        }

        function performanceDashboardSlider(
            outputName: string,
            index: int,
            normalized: real
        ): void {
            const windowObject = root.controlWindowFor(outputName)
            if (windowObject) {
                windowObject.setPerformanceDashboardSlider(
                    index,
                    normalized
                )
            }
        }

        function performancePopup(
            outputName: string,
            index: int
        ): void {
            const windowObject = root.controlWindowFor(outputName)
            if (windowObject)
                windowObject.togglePerformancePopup(index)
        }

        function performanceDialog(outputName: string): void {
            const windowObject = root.controlWindowFor(outputName)
            if (windowObject)
                windowObject.togglePerformanceDialog()
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: controlWindow

                required property var modelData
                readonly property string outputName:
                    modelData && modelData.name
                        ? String(modelData.name)
                        : ""
                readonly property bool centerVisible:
                    ControlCenterStore.activeOutputName === outputName
                readonly property real safeMargin:
                    root.luminaDesign.spacing.extraLarge
                readonly property real barWindowHeight:
                    SurfacePlacementPolicy.barWindowHeight(
                        ConfigStore.barHeight,
                        ConfigStore.barSurfaceMode,
                        ConfigStore.barMargin
                    )
                readonly property real panelScale:
                    ControlCenterStore.activePage === "settings"
                    ? 1
                    : Math.min(
                        1,
                        dashboardArea.width
                            / root.luminaDesign.size.controlDashboardMinimumWidth,
                        dashboardArea.height
                            / root.luminaDesign.size.controlDashboardMinimumHeight
                    )
                property double visibilityRequestedAt: 0
                property double hidingRequestedAt: 0
                property double settleRequestedAt: 0
                property double pageTransitionRequestedAt: 0
                property string pageTransitionTarget: ""

                function performanceStatus() {
                    return {
                        output: outputName,
                        page: ControlCenterStore.activePage,
                        settings: settingsView.performanceStatus(),
                        dashboard: dashboardView.performanceStatus()
                    }
                }

                function togglePerformanceDropdown(index) {
                    settingsView.togglePerformanceDropdown(index)
                }

                function setPerformanceSettingsSlider(index, normalized) {
                    settingsView.setPerformanceSlider(index, normalized)
                }

                function setPerformanceDashboardSlider(index, normalized) {
                    dashboardView.setPerformanceSlider(index, normalized)
                }

                function togglePerformancePopup(index) {
                    settingsView.togglePerformancePopup(index)
                }

                function togglePerformanceDialog() {
                    settingsView.togglePerformanceDialog()
                }

                Component.onCompleted:
                    root.registerControlWindow(outputName, controlWindow)

                Component.onDestruction:
                    root.unregisterControlWindow(outputName, controlWindow)

                screen: modelData
                visible: centerVisible
                color: "transparent"
                surfaceFormat.opaque: false
                focusable: centerVisible
                exclusiveZone: 0

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lumina-control-center"
                WlrLayershell.keyboardFocus: centerVisible
	          ? WlrKeyboardFocus.Exclusive
	          : WlrKeyboardFocus.None

                onBackingWindowVisibleChanged: {
                    if (backingWindowVisible
                        && visibilityRequestedAt > 0) {
                        settleRequestedAt = visibilityRequestedAt
                        PerformanceTrace.record(
                            "panel",
                            "dashboard",
                            "visible",
                            Date.now() - visibilityRequestedAt,
                            {
                                output: outputName,
                                page: ControlCenterStore.activePage
                            }
                        )
                        visibilityRequestedAt = 0
                        Qt.callLater(function() {
                            if (!controlWindow.centerVisible
                                || controlWindow.settleRequestedAt <= 0) {
                                return
                            }

                            PerformanceTrace.record(
                                "panel",
                                "dashboard",
                                "settled",
                                Date.now()
                                    - controlWindow.settleRequestedAt,
                                {
                                    output: controlWindow.outputName,
                                    page: ControlCenterStore.activePage
                                }
                            )
                            controlWindow.settleRequestedAt = 0
                        })
                    } else if (!backingWindowVisible
                        && hidingRequestedAt > 0) {
                        PerformanceTrace.record(
                            "panel",
                            "dashboard",
                            "hidden",
                            Date.now() - hidingRequestedAt,
                            {
                                output: outputName,
                                page: ControlCenterStore.activePage
                            }
                        )
                        hidingRequestedAt = 0
                        settleRequestedAt = 0
                    }

                    BarPanelCoordinator
                        .reportPanelWindowVisibility(
                            "dashboard",
                            outputName,
                            backingWindowVisible
                        )

                    if (backingWindowVisible) {
                        Qt.callLater(function() {
                            if (!controlWindow.centerVisible)
                                return

                            NotificationService.markAllRead()
                            CalendarStore.goToToday()
                        })
                    }
                }

	      BackgroundEffect.blurRegion:
          ShellSurfacePolicy.requestsBackdropBlur(
              ConfigStore.shellBackgroundMode
          )
              ? shellBlurRegion
              : null

      Region {
          id: shellBlurRegion

          Region {
              x: dashboardSurface.x
              y: dashboardSurface.y
              width: dashboardSurface.width
              height: dashboardSurface.height
              radius: dashboardSurface.radius
          }
      }

                onCenterVisibleChanged: {
                    if (centerVisible) {
                        visibilityRequestedAt = Date.now()
                        PerformanceTrace.recordInstant(
                            "panel",
                            "dashboard",
                            "requested",
                            {
                                output: outputName,
                                page: ControlCenterStore.activePage
                            }
                        )
                    } else {
                        hidingRequestedAt = Date.now()
                    }
                }

                Connections {
                    target: ControlCenterStore

                    function onActivePageChanged() {
                        if (!controlWindow.centerVisible)
                            return

                        controlWindow.pageTransitionRequestedAt =
                            Date.now()
                        controlWindow.pageTransitionTarget =
                            ControlCenterStore.activePage
                        PerformanceTrace.recordInstant(
                            "transition",
                            "control-page",
                            "requested",
                            {
                                target:
                                    controlWindow.pageTransitionTarget
                            }
                        )
                        pageTransitionTimer.restart()
                    }
                }

                Timer {
                    id: pageTransitionTimer

                    interval: Math.max(
                        root.luminaDesign.motion.pageTransition,
                        root.luminaDesign.motion.effectsDefault
                    )
                    repeat: false
                    onTriggered: {
                        if (!controlWindow.centerVisible
                            || controlWindow.pageTransitionTarget
                                !== ControlCenterStore.activePage) {
                            return
                        }

                        PerformanceTrace.record(
                            "transition",
                            "control-page",
                            "settled",
                            Math.max(
                                0,
                                Date.now()
                                    - controlWindow
                                        .pageTransitionRequestedAt
                                    - interval
                            ),
                            {
                                target:
                                    controlWindow.pageTransitionTarget,
                                expectedDurationMs: interval,
                                totalDurationMs:
                                    Date.now()
                                        - controlWindow
                                            .pageTransitionRequestedAt
                            }
                        )
                    }
                }

                FocusScope {
                    anchors.fill: parent
                    focus: controlWindow.centerVisible

                    Keys.onEscapePressed: event => {
                        if (SettingsStore.resetConfirmation)
                            SettingsStore.cancelReset()
                        else
                            ControlCenterStore.close()

                        event.accepted = true
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: root.luminaDesign.color.scrim

                    MouseArea {
                        anchors.fill: parent
                        enabled: ConfigStore.behaviorCloseOnOutside
                        onClicked: ControlCenterStore.close()
                    }
                }

                Item {
                    id: availableArea

                    anchors {
                        fill: parent
                        topMargin:
                            ConfigStore.barPosition === "top"
                                ? controlWindow.barWindowHeight
                                    + ConfigStore.barPanelGap
                                : controlWindow.safeMargin
                        bottomMargin:
                            ConfigStore.barPosition === "bottom"
                                ? controlWindow.barWindowHeight
                                    + ConfigStore.barPanelGap
                                : controlWindow.safeMargin
                        leftMargin: controlWindow.safeMargin
                        rightMargin: controlWindow.safeMargin
                    }
                }

                ShellSurface {
          id: dashboardSurface

                    x: SurfacePlacementPolicy.horizontalX(
                        OverlayStore.activePlacement,
                        OverlayStore.activeAnchorX,
                        width,
                        controlWindow.width,
                        controlWindow.safeMargin
                    )
                    y: SurfacePlacementPolicy.verticalY(
                        OverlayStore.activePlacement,
                        ConfigStore.barPosition,
                        height,
                        controlWindow.height,
                        controlWindow.barWindowHeight,
                        ConfigStore.barPanelGap,
                        controlWindow.safeMargin,
                        OverlayStore.activeAnchorTop,
                        OverlayStore.activeAnchorBottom
                    )
                    width: Math.min(
                        root.luminaDesign.size.controlCenterWidth,
                        availableArea.width
                    )
                    height: Math.min(
                        root.luminaDesign.size.controlCenterHeight,
                        availableArea.height
                    )
                    radius: root.luminaDesign.shape.extraLarge
          clip: true

                    MouseArea {
                        anchors.fill: parent
                    }

                    Column {
                        anchors {
                            fill: parent
                            margins:
                                root.luminaDesign.spacing.controlContentInset
                        }

                        spacing: root.luminaDesign.spacing.controlItemGap

                        DashboardHeader {
                            width: parent.width
                            height: 52
                            outputName: controlWindow.outputName
                        }

                        ControlTabBar {
                            width: parent.width
                        }

                        Item {
                            id: dashboardArea

                            width: parent.width
                            height: parent.height
                                - 52
                                - 44
                                - parent.spacing * 2
                            clip: true

                            Item {
                                id: scaledContent

                                anchors.centerIn: parent
                                width: parent.width
                                    / controlWindow.panelScale
                                height: parent.height
                                    / controlWindow.panelScale
                                scale: controlWindow.panelScale

                                DashboardView {
                                    id: dashboardView

                                    readonly property bool pageActive:
                                        ControlCenterStore.activePage
                                            === "dashboard"

                                    width: parent.width
                                    height: parent.height
                                    x: pageActive
                                        ? 0
                                        : -Math.min(
                                            48,
                                            Math.round(width * 0.04)
                                        )
                                    opacity: pageActive ? 1 : 0
                                    visible: pageActive || opacity > 0.01
                                    enabled: pageActive
                                    active: pageActive
                                    outputName:
                                        controlWindow.outputName

                                    Behavior on x {
                                        enabled:
                                            controlWindow.backingWindowVisible

                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.pageTransition
                                            easing.type:
                                                root.luminaDesign.motion.spatialEasing
                                            easing.overshoot:
                                                root.luminaDesign.motion.spatialOvershoot
                                        }
                                    }

                                    Behavior on opacity {
                                        enabled:
                                            controlWindow.backingWindowVisible

                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.effectsDefault
                                            easing.type:
                                                root.luminaDesign.motion.effectsEasing
                                        }
                                    }
                                }

                                ShellSettingsView {
                                    id: settingsView

                                    readonly property bool pageActive:
                                        ControlCenterStore.activePage
                                            === "settings"

                                    width: parent.width
                                    height: parent.height
                                    x: pageActive
                                        ? 0
                                        : Math.min(
                                            48,
                                            Math.round(width * 0.04)
                                        )
                                    opacity: pageActive ? 1 : 0
                                    visible: pageActive || opacity > 0.01
                                    enabled: pageActive
                                    active: pageActive
                                    outputName:
                                        controlWindow.outputName

                                    Behavior on x {
                                        enabled:
                                            controlWindow.backingWindowVisible

                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.pageTransition
                                            easing.type:
                                                root.luminaDesign.motion.spatialEasing
                                            easing.overshoot:
                                                root.luminaDesign.motion.spatialOvershoot
                                        }
                                    }

                                    Behavior on opacity {
                                        enabled:
                                            controlWindow.backingWindowVisible

                                        NumberAnimation {
                                            duration:
                                                root.luminaDesign.motion.effectsDefault
                                            easing.type:
                                                root.luminaDesign.motion.effectsEasing
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

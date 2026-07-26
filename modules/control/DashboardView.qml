pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.stores.config

FocusScope {
    id: root

    required property string outputName
    property bool active: false

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property real overviewControlsShare: 0.425

    focus: active

    function sliderControls(item, result) {
        const controls = result || []

        if (!item)
            return controls

        if (typeof item.benchmarkValue === "function")
            controls.push(item)

        const descendants = item.children || []
        for (var index = 0; index < descendants.length; ++index)
            sliderControls(descendants[index], controls)

        return controls
    }

    function performanceStatus() {
        return {
            sliders: sliderControls(root, []).map(function(control) {
                return {
                    title: String(control.title || ""),
                    available: Boolean(control.available),
                    value: Number(control.value)
                }
            })
        }
    }

    function setPerformanceSlider(index, normalized) {
        const controls = sliderControls(root, [])
        const requested = Number(index)

        if (requested >= 0 && requested < controls.length)
            controls[requested].benchmarkValue(Number(normalized))
    }

    Item {
        id: leftColumn

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        readonly property bool hasContent:
            ConfigStore.dashboardShowOverview
            || ConfigStore.dashboardShowControls

        width: hasContent
            ? (parent.width
                - root.luminaDesign.spacing.controlCardGap * 2)
                * 0.27
            : 0
        visible: hasContent

        DashboardOverview {
            id: overview

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            visible: ConfigStore.dashboardShowOverview
            showWeather: ConfigStore.dashboardShowWeather
            height: !visible
                ? 0
                : ConfigStore.dashboardShowControls
                    ? parent.height * root.overviewControlsShare
                    : parent.height
        }

        DashboardControls {
            visible: ConfigStore.dashboardShowControls
            anchors {
                left: parent.left
                right: parent.right
                top: overview.bottom
                bottom: parent.bottom
                topMargin: overview.visible
                    ? root.luminaDesign.spacing.controlCardGap
                    : 0
            }
        }
    }

    DashboardNotifications {
        id: homeNotifications

        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: leftColumn.visible
                ? root.luminaDesign.spacing.controlCardGap
                : 0
        }

        visible: ConfigStore.dashboardShowNotifications
        width: visible
            ? (parent.width
                - root.luminaDesign.spacing.controlCardGap * 2)
                * 0.41
            : 0
        compact: true
    }

    Item {
        id: rightColumn

        readonly property int visibleCardCount:
            (ConfigStore.dashboardShowMedia ? 1 : 0)
            + (ConfigStore.dashboardShowSystem ? 1 : 0)
            + (ConfigStore.dashboardShowCalendar ? 1 : 0)

        anchors {
            left: homeNotifications.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: homeNotifications.visible
                || leftColumn.visible
                    ? root.luminaDesign.spacing.controlCardGap
                    : 0
        }

        DashboardMedia {
            id: mediaCard

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            visible: ConfigStore.dashboardShowMedia
            height: visible
                ? (parent.height
                    - root.luminaDesign.spacing.controlCardGap
                        * (rightColumn.visibleCardCount - 1))
                    / Math.max(1, rightColumn.visibleCardCount)
                : 0
        }

        DashboardStatus {
            id: statusCard

            anchors {
                left: parent.left
                right: parent.right
                top: mediaCard.bottom
                topMargin: mediaCard.visible
                    ? root.luminaDesign.spacing.controlCardGap
                    : 0
            }

            visible: ConfigStore.dashboardShowSystem
            height: visible
                ? (parent.height
                    - root.luminaDesign.spacing.controlCardGap
                        * (rightColumn.visibleCardCount - 1))
                    / Math.max(1, rightColumn.visibleCardCount)
                : 0
        }

        DashboardCalendar {
            anchors {
                left: parent.left
                right: parent.right
                top: statusCard.bottom
                bottom: parent.bottom
                topMargin: statusCard.visible || mediaCard.visible
                    ? root.luminaDesign.spacing.controlCardGap
                    : 0
            }

            visible: ConfigStore.dashboardShowCalendar
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import qs.design

FocusScope {
    id: root

    required property string outputName
    property bool active: false

    readonly property var luminaDesign: Theme.luminaTokens

    focus: active

    Item {
        id: leftColumn

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        width: (
            parent.width - root.luminaDesign.spacing.medium * 2
        ) * 0.27

        DashboardOverview {
            id: overview

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            height: parent.height * 0.45
        }

        DashboardControls {
            anchors {
                left: parent.left
                right: parent.right
                top: overview.bottom
                bottom: parent.bottom
                topMargin: root.luminaDesign.spacing.medium
            }
        }
    }

    DashboardNotifications {
        id: homeNotifications

        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: root.luminaDesign.spacing.medium
        }

        width: (
            parent.width - root.luminaDesign.spacing.medium * 2
        ) * 0.41
        compact: true
    }

    Item {
        anchors {
            left: homeNotifications.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: root.luminaDesign.spacing.medium
        }

        DashboardMedia {
            id: mediaCard

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            height: parent.height * 0.24
        }

        DashboardStatus {
            id: statusCard

            anchors {
                left: parent.left
                right: parent.right
                top: mediaCard.bottom
                topMargin: root.luminaDesign.spacing.medium
            }

            height: parent.height * 0.29
        }

        DashboardCalendar {
            anchors {
                left: parent.left
                right: parent.right
                top: statusCard.bottom
                bottom: parent.bottom
                topMargin: root.luminaDesign.spacing.medium
            }
        }
    }
}

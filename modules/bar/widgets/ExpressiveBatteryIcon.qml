import QtQuick
import QtQuick.Shapes
import qs.design
import "ExpressiveBatteryGeometry.js" as BatteryGeometry

Item {
    id: root

    property real percentage: 0
    property bool charging: false
    property real iconSize: luminaDesign.size.barStatusIcon
    property color iconColor: luminaDesign.color.onSurface

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool lowBattery:
        BatteryGeometry.isLowBattery(percentage, charging)
    readonly property color levelColor: lowBattery
        ? luminaDesign.color.urgent
        : charging
            ? luminaDesign.color.primary
            : iconColor
    readonly property real bodyHeight:
        Math.max(8, Math.round(iconSize * 0.72))
    readonly property real bodyWidth:
        Math.max(15, Math.round(iconSize * 1.24))
    readonly property real terminalWidth:
        Math.max(2, Math.round(iconSize * 0.14))
    readonly property real terminalGap:
        Math.max(1, Math.round(iconSize * 0.06))
    readonly property real boltWidth:
        charging ? Math.max(5, Math.round(iconSize * 0.34)) : 0
    readonly property real boltGap:
        charging ? Math.max(1, Math.round(iconSize * 0.08)) : 0

    implicitWidth: bodyWidth
        + terminalGap
        + terminalWidth
        + boltGap
        + boltWidth
    implicitHeight: Math.max(iconSize, bodyHeight)

    Rectangle {
        id: batteryBody

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.bodyWidth
        height: root.bodyHeight
        radius: height / 2
        color: Qt.rgba(
            root.iconColor.r,
            root.iconColor.g,
            root.iconColor.b,
            0.18
        )
        border.width: Math.max(1, Math.round(root.iconSize * 0.08))
        border.color: root.levelColor
        clip: true

        Rectangle {
            id: batteryLevel

            readonly property real inset:
                Math.max(2, batteryBody.border.width + 1)
            readonly property real availableWidth:
                Math.max(0, batteryBody.width - inset * 2)

            anchors.left: parent.left
            anchors.leftMargin: inset
            anchors.verticalCenter: parent.verticalCenter
            width: BatteryGeometry.fillWidth(
                availableWidth,
                root.percentage,
                Math.max(2, Math.round(height * 0.22))
            )
            height: Math.max(
                2,
                batteryBody.height - inset * 2
            )
            radius: height / 2
            color: root.levelColor

            Behavior on width {
                NumberAnimation {
                    duration: root.luminaDesign.motion.spatialDefault
                    easing.type:
                        root.luminaDesign.motion.spatialEasing
                    easing.overshoot:
                        root.luminaDesign.motion.spatialOvershoot
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration:
                        root.luminaDesign.motion.effectsDefault
                    easing.type:
                        root.luminaDesign.motion.effectsEasing
                }
            }
        }
    }

    Rectangle {
        anchors.left: batteryBody.right
        anchors.leftMargin: root.terminalGap
        anchors.verticalCenter: parent.verticalCenter
        width: root.terminalWidth
        height: Math.max(4, Math.round(root.bodyHeight * 0.42))
        radius: width / 2
        color: root.levelColor
    }

    Shape {
        id: chargingBolt

        visible: root.charging
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.boltWidth
        height: Math.max(10, Math.round(root.iconSize * 0.82))

        ShapePath {
            fillColor: root.luminaDesign.color.primary
            strokeColor: "transparent"

            PathMove {
                x: chargingBolt.width * 0.58
                y: 0
            }
            PathLine {
                x: chargingBolt.width * 0.08
                y: chargingBolt.height * 0.56
            }
            PathLine {
                x: chargingBolt.width * 0.46
                y: chargingBolt.height * 0.56
            }
            PathLine {
                x: chargingBolt.width * 0.30
                y: chargingBolt.height
            }
            PathLine {
                x: chargingBolt.width * 0.94
                y: chargingBolt.height * 0.38
            }
            PathLine {
                x: chargingBolt.width * 0.56
                y: chargingBolt.height * 0.38
            }
            PathLine {
                x: chargingBolt.width * 0.58
                y: 0
            }
        }
    }
}

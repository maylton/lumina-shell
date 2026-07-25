pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.modules.control.settings
import qs.services.connectivity
import qs.services.i18n
import qs.stores.control
import "connectivity" as ConnectivityViews

SettingsPage {
    id: root

    property string activeSection: "wifi"
    property var pendingNetwork: null

    readonly property bool managementActive:
        ControlCenterStore.open
        && ControlCenterStore.activePage === "settings"
        && ControlCenterStore.settingsCategory === "connectivity"

    title: I18n.tr(
        "settings.category.connectivity.label",
        "Connectivity"
    )
    description: I18n.tr(
        "settings.page.connectivity.description",
        "Wi-Fi, wired networking, and Bluetooth devices"
    )

    function updateManagerSection() {
        ConnectivityManagerService.setActiveSection(
            managementActive ? activeSection : ""
        )
    }

    function openPassword(network) {
        pendingNetwork = network
        passwordInput.text = ""
        passwordPopup.open()
        Qt.callLater(function() {
            passwordInput.forceActiveFocus(Qt.PopupFocusReason)
        })
    }

    onManagementActiveChanged: updateManagerSection()
    onActiveSectionChanged: updateManagerSection()
    Component.onCompleted: updateManagerSection()
    Component.onDestruction:
        ConnectivityManagerService.setActiveSection("")

    SettingsSegmentedControl {
        width: parent.width
        height: 44
        options: [
            {
                value: "wifi",
                label: I18n.tr(
                    "settings.connectivity.wifi.section",
                    "Wi-Fi"
                )
            },
            {
                value: "wired",
                label: I18n.tr(
                    "settings.connectivity.wired.section",
                    "Wired network"
                )
            },
            {
                value: "bluetooth",
                label: I18n.tr(
                    "settings.connectivity.bluetooth.section",
                    "Bluetooth"
                )
            }
        ]
        currentValue: root.activeSection
        onSelected: value => root.activeSection = value
    }

    Loader {
        width: parent.width
        implicitHeight: item ? item.implicitHeight : 0
        sourceComponent: root.activeSection === "wifi"
            ? wifiComponent
            : root.activeSection === "wired"
                ? wiredComponent
                : bluetoothComponent
    }

    Component {
        id: wifiComponent

        ConnectivityViews.WifiPage {
            width: root.width
            onPasswordRequested: network => root.openPassword(network)
        }
    }

    Component {
        id: wiredComponent

        ConnectivityViews.WiredPage {
            width: root.width
        }
    }

    Component {
        id: bluetoothComponent

        ConnectivityViews.BluetoothPage {
            width: root.width
        }
    }

    Controls.Popup {
        id: passwordPopup

        parent: root
        x: Math.max(0, (root.width - width) / 2)
        y: Math.max(0, (root.height - height) / 2)
        width: Math.min(420, root.width - 40)
        height: 220
        padding: 0
        modal: true
        focus: true
        closePolicy: Controls.Popup.CloseOnEscape
            | Controls.Popup.CloseOnPressOutside

        onClosed: {
            passwordInput.text = ""
            root.pendingNetwork = null
        }

        background: Rectangle {
            radius: root.luminaDesign.shape.extraLarge
            color: root.luminaDesign.color.surfaceContainer
            border.width: 1
            border.color: root.luminaDesign.color.outline
        }

        contentItem: Column {
            spacing: root.luminaDesign.spacing.large

            Text {
                width: parent.width
                    - root.luminaDesign.spacing.extraLarge * 2
                x: root.luminaDesign.spacing.extraLarge
                text: I18n.tr(
                    "settings.connectivity.wifi.passwordFor",
                    "Password for %1",
                    [root.pendingNetwork
                        ? root.pendingNetwork.ssid
                        : ""]
                )
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.titleMedium
                font.weight: Font.Bold
            }

            Rectangle {
                width: parent.width
                    - root.luminaDesign.spacing.extraLarge * 2
                height: 44
                x: root.luminaDesign.spacing.extraLarge
                radius: root.luminaDesign.shape.full
                color: root.luminaDesign.color.surfaceMuted
                border.width: passwordInput.activeFocus ? 2 : 1
                border.color: passwordInput.activeFocus
                    ? root.luminaDesign.color.primary
                    : root.luminaDesign.color.outline

                TextInput {
                    id: passwordInput

                    anchors {
                        fill: parent
                        leftMargin: root.luminaDesign.spacing.large
                        rightMargin: root.luminaDesign.spacing.large
                    }
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    selectByMouse: true
                    color: root.luminaDesign.color.onSurface
                    font.pixelSize:
                        root.luminaDesign.typography.bodyMedium
                    Keys.onReturnPressed: event => {
                        connectPasswordButton.activate()
                        event.accepted = true
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: root.luminaDesign.spacing.medium

                Rectangle {
                    width: 120
                    height: 40
                    radius: root.luminaDesign.shape.full
                    color: root.luminaDesign.color.surfaceMuted

                    Text {
                        anchors.centerIn: parent
                        text: I18n.tr(
                            "settings.connectivity.cancel",
                            "Cancel"
                        )
                        color: root.luminaDesign.color.onSurface
                        font.pixelSize:
                            root.luminaDesign.typography.labelMedium
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: passwordPopup.close()
                    }
                }

                Rectangle {
                    id: connectPasswordButton

                    width: 120
                    height: 40
                    radius: root.luminaDesign.shape.full
                    color: root.luminaDesign.color.accentContainer

                    function activate() {
                        if (!root.pendingNetwork || !passwordInput.text)
                            return

                        ConnectivityManagerService.connectWifi(
                            root.pendingNetwork.ssid,
                            root.pendingNetwork.security,
                            passwordInput.text
                        )
                        passwordPopup.close()
                    }

                    Text {
                        anchors.centerIn: parent
                        text: I18n.tr(
                            "settings.connectivity.connect",
                            "Connect"
                        )
                        color:
                            root.luminaDesign.color.onAccentContainer
                        font.pixelSize:
                            root.luminaDesign.typography.labelMedium
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: connectPasswordButton.activate()
                    }
                }
            }
        }
    }
}

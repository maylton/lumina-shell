pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.control.settings
import qs.services.connectivity
import qs.services.i18n
import qs.stores.control
import "connectivity" as ConnectivityViews

SettingsPage {
    id: root

    property string activeSection: "wifi"

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
        const legacySection = managementActive
            && activeSection !== "bluetooth"
            ? activeSection
            : ""

        ConnectivityManagerService.setActiveSection(legacySection)

        if (managementActive && activeSection === "bluetooth") {
            BluetoothManagerService.setActive(true)
            BluetoothManagerService.refresh()
        }
    }

    function openPassword(network) {
        passwordPopup.openFor(network)
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
        height: item ? item.implicitHeight : 0
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

    ConnectivityViews.WifiPasswordDialog {
        id: passwordPopup

        parent: root
        availableWidth: root.width
        availableHeight: root.height
        onSubmitted: password => {
            if (!passwordPopup.network)
                return

            ConnectivityManagerService.connectWifi(
                passwordPopup.network.ssid,
                passwordPopup.network.security,
                password
            )
        }
    }
}

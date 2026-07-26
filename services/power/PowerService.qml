pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property bool batteryAvailable: battery
        && battery.ready
        && battery.isPresent
        && battery.isLaptopBattery
    readonly property int batteryPercentage: batteryAvailable
        ? Math.round(battery.percentage)
        : 0
    readonly property bool onBattery: UPower.onBattery
    readonly property string batteryState: batteryAvailable
        ? UPowerDeviceState.toString(battery.state)
        : "Unavailable"
    readonly property string batteryIcon: batteryAvailable
        ? String(battery.iconName || "")
        : ""
    readonly property int activeProfile: PowerProfiles.profile
    readonly property string profileName: nameForProfile(activeProfile)
    readonly property bool performanceAvailable:
        PowerProfiles.hasPerformanceProfile

    signal profileAdjusted(string profileName)

    function nameForProfile(profile) {
        switch (profile) {
        case PowerProfile.PowerSaver:
            return "power-saver"
        case PowerProfile.Performance:
            return "performance"
        default:
            return "balanced"
        }
    }

    function profileForName(profileName) {
        switch (String(profileName || "").toLowerCase()) {
        case "power-saver":
        case "powersaver":
        case "saving":
            return PowerProfile.PowerSaver
        case "performance":
            return PowerProfile.Performance
        case "balanced":
            return PowerProfile.Balanced
        default:
            return -1
        }
    }

    function setProfile(profileName) {
        const profile = profileForName(profileName)

        if (profile < 0)
            return

        if (profile === PowerProfile.Performance
            && !performanceAvailable) {
            return
        }

        PowerProfiles.profile = profile
        profileAdjusted(nameForProfile(profile))
    }

    function cycleProfile() {
        if (activeProfile === PowerProfile.PowerSaver) {
            setProfile("balanced")
        } else if (activeProfile === PowerProfile.Balanced
            && performanceAvailable) {
            setProfile("performance")
        } else {
            setProfile("power-saver")
        }
    }

    IpcHandler {
        target: "power"

        function profile(profileName: string): void {
            root.setProfile(profileName)
        }

        function cycle(): void {
            root.cycleProfile()
        }

        function status(): string {
            return JSON.stringify({
                profile: root.profileName,
                performanceAvailable: root.performanceAvailable,
                onBattery: root.onBattery,
                battery: {
                    available: root.batteryAvailable,
                    percentage: root.batteryPercentage,
                    state: root.batteryState,
                    icon: root.batteryIcon
                }
            })
        }
    }
}

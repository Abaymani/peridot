pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root
    property bool available: UPower.displayDevice.isLaptopBattery
    property var chargeState: UPower.displayDevice.state
    property bool isCharging: chargeState == UPowerDeviceState.Charging
    property bool isPluggedIn: isCharging || chargeState == UPowerDeviceState.PendingCharge
    property real percentage: UPower.displayDevice?.percentage ?? 1
    readonly property bool allowAutomaticSuspend: true

    property bool isLow: available && (percentage <= 15/100)
    property bool isCritical: available && (percentage <= 5/100)
    property bool isSuspending: available && (percentage <= 3/100)
    property bool isFull: available && (percentage >= 101/100)

    property bool isLowAndNotCharging: isLow && !isCharging
    property bool isCriticalAndNotCharging: isCritical && !isCharging
    property bool isSuspendingAndNotCharging: allowAutomaticSuspend && isSuspending && !isCharging
    property bool isFullAndCharging: isFull && isCharging

    property real energyRate: UPower.displayDevice.changeRate
    property real timeToEmpty: UPower.displayDevice.timeToEmpty
    property real timeToFull: UPower.displayDevice.timeToFull

    property real health: (function() {
        const devList = UPower.devices.values;
        for (let i = 0; i < devList.length; ++i) {
            const dev = devList[i];
            if (dev.isLaptopBattery && dev.healthSupported) {
                const health = dev.healthPercentage;
                if (health === 0) {
                    return 0.01;
                } else if (health < 1) {
                    return health * 100;
                } else {
                    return health;
                }
            }
        }
        return 0;
    })()

    onIsChargingChanged: {
        if (root.isCharging)
            Quickshell.execDetached([
                "notify-send", 
                "Charger connected", 
                "Device is charging", 
                "-u", "critical",
                "-i", "/home/armin/.local/share/icons/YAMIS/status/scalable/battery-full-charging-symbolic.svg",
                "-a", "Shell",
                "--hint=int:transient:1",
            ]);
        else if (!root.isFull)
            Quickshell.execDetached([
                "notify-send", 
                "Charger disconnected", 
                "Battery is not full! Consider reconnecting charger.", 
                "-u", "critical",
                "-i", "/home/armin/.local/share/icons/YAMIS/status/scalable/battery-caution.svg",
                "-a", "Shell",
                "--hint=int:transient:1",
            ]);
    }

    onIsLowAndNotChargingChanged: {
        if (!root.available || !isLowAndNotCharging) return;
        Quickshell.execDetached([
            "notify-send", 
            "Low battery", 
            "Consider plugging in your device", 
            "-u", "critical",
            "-a", "Shell",
            "--hint=int:transient:1",
        ])
    }

    onIsCriticalAndNotChargingChanged: {
        if (!root.available || !isCriticalAndNotCharging) return;
        Quickshell.execDetached([
            "notify-send", 
            "Critically low battery", 
            "Please charge!\nAutomatic suspend triggers at 3%", 
            "-u", "critical",
            "-a", "Shell",
            "--hint=int:transient:1",
        ]);
    }

    onIsSuspendingAndNotChargingChanged: {
        if (root.available && isSuspendingAndNotCharging) {
            Quickshell.execDetached(["bash", "-c", `systemctl suspend || loginctl suspend`]);
        }
    }

    onIsFullAndChargingChanged: {
        if (!root.available || !isFullAndCharging) return;
        Quickshell.execDetached([
            "notify-send",
            "Battery full",
            "Please unplug the charger",
            "-a", "Shell",
            "--hint=int:transient:1",
        ]);
    }
}
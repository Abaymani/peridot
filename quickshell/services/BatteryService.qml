pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root
    property UPowerDevice _device: UPower.displayDevice
    property bool hasBattery: _device.ready && _device.isLaptopBattery

    property real _percentage: _device.percentage
    property string percentage: _device.ready ? Math.round(_device.percentage*100) + "%" : "0%"

    property bool isCharging: _device.ready && _device.state === UPowerDeviceState.Charging
    property bool isFull: _device.ready && _device.state === UPowerDeviceState.FullyCharged

    property bool _notifiedLowBattery: false

    property string icon: {
        // Fallback if the device isn't ready yet
        if (!_device.ready) return "󰂑"; // Unknown/Empty icon

        if (isFull) return "󰁹";
        if (isCharging) return "󰂄";

        // Since it evaluates top-to-bottom, we check the lowest percentages first
        if (_percentage < 0.15) return "󰂃";
        if (_percentage < 0.2) return "󰁻";
        if (_percentage < 0.3) return "󰁼";
        if (_percentage < 0.4) return "󰁽";
        if (_percentage < 0.5) return "󰁾";
        if (_percentage < 0.6) return "󰁿";
        if (_percentage < 0.7) return "󰂀";
        if (_percentage < 0.8) return "󰂁";
        if (_percentage < 0.9) return "󰂂";

        return "󰁹";
    }

    // This listens DIRECTLY to the underlying hardware device's events
    Connections {
        target: root._device

        function onPercentageChanged() {
            checkBatteryLevels();
        }

        // plugging/unplugging the charger
        function onStateChanged() {
            checkBatteryLevels();
        }
    }

    function checkBatteryLevels() {
        if (!root._device.ready) return;

        // If we drop to 15% or below, aren't charging, and haven't notified yet
        if (root._percentage <= 0.15 && !root.isCharging && !root._notifiedLowBattery) {
            
            Quickshell.execDetached([
                "notify-send", 
                "-u", "critical", 
                "-i", "battery-empty", 
                "Battery Low", 
                `Your battery is at ${root.percentage}%. Please plug in.`
            ]);
            
            root._notifiedLowBattery = true;
            
        } 
        // Reset the flag if the battery goes back above 15% or we plug it in
        else if (root.percentage > 0.15 || root.isCharging) {
            root._notifiedLowBattery = false;
        }
    }
}
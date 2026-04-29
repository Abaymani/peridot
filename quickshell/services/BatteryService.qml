pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root
    property UPowerDevice _device: UPower.displayDevice
    property bool hasBattery: _device.ready && _device.isLaptopBattery

    property real _percentage: _device.percentage
    property string percentage: _device.ready ? Math.round(_device.percentage*100) + "%" : "0%"

    property bool isCharging: false 
    property bool isFull: _device.ready && _device.state === UPowerDeviceState.FullyCharged

    property bool _notifiedLowBattery: false

    property string icon: " "

    // This listens DIRECTLY to the underlying hardware device's events
    Connections {
        target: root._device

        function onPercentageChanged() {
            checkBatteryLevels();
        }
    }

    //Changed from connection to process, since it was not updating correctly.
    Process {
        id: statusProc
        command: ["cat", "/sys/class/power_supply/BAT1/status"]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                const stat = text.trim();
                root.isCharging = (stat === "Charging");
                
                checkBatteryLevels();
                updateIcon();
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            statusProc.running = true
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

    function updateIcon() {
        if (root.isFull) {
            root.icon = "󰁹";
            return;
        }
        if (root.isCharging) {
            root.icon = "󰂄";
            return;
        }

        // Evaluates lowest to highest using whole numbers (0-100)
        if (root.percentage < 0.15) root.icon = "󰂃";
        else if (root._percentage < 0.20) root.icon = "󰁻";
        else if (root._percentage < 0.30) root.icon = "󰁼";
        else if (root._percentage < 0.40) root.icon = "󰁽";
        else if (root._percentage < 0.50) root.icon = "󰁾";
        else if (root._percentage < 0.60) root.icon = "󰁿";
        else if (root._percentage < 0.70) root.icon = "󰂀";
        else if (root._percentage < 0.80) root.icon = "󰂁";
        else if (root._percentage < 0.90) root.icon = "󰂂";
        else root.icon = "󰁹";
    }
}
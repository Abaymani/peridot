// Public network service. Thin facade over Nmcli (the nmcli-CLI backed
// implementation) - UI code should talk to this singleton, not Nmcli
// directly, so the backend can change without touching every consumer.

pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  signal connectionFailed(string ssid)

  // --- Wi-Fi / network state ---
  readonly property var networks: Nmcli.networks
  readonly property var active: Nmcli.active
  readonly property bool wifiEnabled: Nmcli.wifiEnabled
  readonly property bool scanning: Nmcli.scanning
  readonly property var pendingConnection: Nmcli.pendingConnection
  readonly property var wirelessDeviceDetails: Nmcli.wirelessDeviceDetails

  // --- VPN state ---
  readonly property bool vpnActive: Nmcli.vpnActive
  readonly property var activeVpnConnections: Nmcli.activeVpnConnections

  // --- Saved connections ---
  readonly property var savedConnections: Nmcli.savedConnections
  readonly property var savedConnectionSsids: Nmcli.savedConnectionSsids

  // --- Ethernet state ---
  readonly property var ethernetDevices: Nmcli.ethernetDevices
  readonly property var activeEthernet: Nmcli.activeEthernet
  readonly property int ethernetDeviceCount: ethernetDevices.length
  readonly property var ethernetDeviceDetails: Nmcli.ethernetDeviceDetails
  property bool ethernetProcessRunning: false

  // --- Wi-Fi actions ---
  function enableWifi(enabled: bool): void {
    Nmcli.enableWifi(enabled, result => {
      if (result.success)
        Nmcli.getNetworks();
    });
  }

  function toggleWifi(): void {
    Nmcli.toggleWifi(result => {
      if (result.success)
        Nmcli.getNetworks();
    });
  }

  function rescanWifi(): void {
    Nmcli.rescanWifi();
  }

  function getWifiStatus(callback: var): void {
    Nmcli.getWifiStatus(callback);
  }

  // --- Connecting / disconnecting ---
  function connectToNetwork(ssid: string, password: string, bssid: string, callback: var): void {
    Nmcli.connectToNetwork(ssid, password, bssid, callback);
  }

  function connectToNetworkWithPasswordCheck(ssid: string, isSecure: bool, callback: var, bssid: string): void {
    Nmcli.connectToNetworkWithPasswordCheck(ssid, isSecure, callback, bssid);
  }

  function disconnectFromNetwork(): void {
    Nmcli.disconnectFromNetwork();
  }

  function forgetNetwork(ssid: string, callback: var): void {
    Nmcli.forgetNetwork(ssid, callback);
  }

  function hasSavedProfile(ssid: string): bool {
    return Nmcli.hasSavedProfile(ssid);
  }

  // --- Ethernet ---
  function getEthernetDevices(): void {
    root.ethernetProcessRunning = true;
    Nmcli.getEthernetInterfaces(() => {
      root.ethernetProcessRunning = false;
    });
  }

  function connectEthernet(connectionName: string, interfaceName: string, callback: var): void {
    Nmcli.connectEthernet(connectionName, interfaceName, callback);
  }

  function disconnectEthernet(connectionName: string, callback: var): void {
    Nmcli.disconnectEthernet(connectionName, callback);
  }

  function updateEthernetDeviceDetails(interfaceName: string, callback: var): void {
    Nmcli.getEthernetDeviceDetails(interfaceName, callback);
  }

  // --- Wireless details ---
  function updateWirelessDeviceDetails(callback: var): void {
    Nmcli.getWirelessDeviceDetails("", callback);
  }

  // --- Utility ---
  function cidrToSubnetMask(cidr: string): string {
    return Nmcli.cidrToSubnetMask(cidr);
  }

  Connections {
    target: Nmcli

    function onConnectionFailed(ssid) {
      root.connectionFailed(ssid);
    }
  }
}

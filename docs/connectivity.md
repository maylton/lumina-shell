# Connectivity settings

Lumina exposes network and Bluetooth management under **Settings →
Connectivity**. Visual QML components do not execute system commands; the page
submits typed requests to `ConnectivityManagerService`.

## Wi-Fi

The page can:

- enable or disable Wi-Fi through the existing native connectivity service;
- scan and list nearby access points;
- display active state, signal strength, and security type;
- connect to open and password-protected networks;
- disconnect the active Wi-Fi device;
- manage NetworkManager autoconnect for saved Wi-Fi profiles;
- forget inactive saved profiles.

Passwords are never stored in `ConfigStore`, the translation catalogs, or the
connectivity status object. For a protected first-time connection, Lumina
writes the secret to a temporary cache file, changes it to mode `0600`, passes
it to NetworkManager with `passwd-file`, and clears/removes it after the
attempt. The secret is not included in process arguments or logs.

The first implementation targets personal WPA-PSK networks. Enterprise 802.1X,
certificate enrollment, hotspot creation, and VPN editing remain outside this
page's initial scope.

## Wired network

Lumina lists NetworkManager Ethernet profiles and managed Ethernet interfaces.
Existing profiles can be connected, disconnected, and configured for automatic
connection. Advanced IPv4/IPv6, DNS, route, VLAN, bridge, bond, and MTU editing
remains delegated to dedicated NetworkManager tools for now.

## Bluetooth

The page can:

- enable or disable the default adapter;
- run a bounded discovery session;
- list discovered, paired, and connected devices;
- pair a new device;
- connect or disconnect paired devices;
- remove an inactive paired device.

BlueZ remains the source of truth for adapter and device state. Pairing methods
that require a graphical agent, confirmation code, or specialized profile may
still depend on the active system Bluetooth agent.

## Runtime diagnostics

Read the lightweight Dashboard state with:

```bash
qs ipc -p /path/to/lumina-shell call connectivity status
```

Read the management-layer state with:

```bash
qs ipc -p /path/to/lumina-shell call connectivity-manager status
qs ipc -p /path/to/lumina-shell call connectivity-manager refresh
```

# Connectivity settings

Lumina exposes network and Bluetooth management under **Settings →
Connectivity**. Visual QML components do not execute system commands; the page
submits typed requests to `ConnectivityManagerService`.

The category is divided into three internal subpages: **Wi-Fi**, **Wired
network**, and **Bluetooth**. Only the selected subpage is rendered and its
integration is the only one refreshed by the detailed management layer. Nearby
Wi-Fi networks, saved profiles, and Bluetooth device groups use bounded,
independently scrollable lists so a busy radio environment does not make the
whole Settings page grow indefinitely.

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
- separate connected, paired, and newly found devices;
- pair a new device;
- connect or disconnect paired devices;
- remove an inactive paired device.

Each device group has its own bounded list. Connected and paired devices remain
above newly discovered devices, so a large scan result cannot push the devices
the user actually uses out of view.

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

The management status includes `activeSection`, which is empty while the
category is closed and otherwise reports `wifi`, `wired`, or `bluetooth`.

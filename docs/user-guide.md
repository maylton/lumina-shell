# User Guide

## Bar

Lumina creates one instance of **Lumina's Material Expressive bar** for each
connected output. Its default 56-pixel, edge-to-edge surface places launcher,
overview, workspaces, and localized date/time on the left; temporary Niri
context in the center; and tray, notifications, network, audio, battery, and
the account avatar on the right. The avatar opens the Dashboard and its session
actions.

The focused workspace expands into an accent pill. Other active workspaces
remain compact, while inactive workspaces recede without reducing their pointer
or keyboard target. Context is event-driven and independent per output.

The Bar settings page controls:

- Solid, Translucent, Blur, Frosted Glass, or Transparent background;
- independent tint opacity;
- top or bottom position;
- edge-to-edge or floating geometry;
- 40–80 pixel height, margins, spacing, and compact mode;
- automatic height-derived content scale or manual 80–140% scale;
- active widgets under Left, Center, and Right;
- per-widget backgrounds, labels, text modes, and presentation settings.

Network, audio, and battery are separate widgets. They can be reordered,
removed, restored, and configured independently. Network and audio open their
dedicated panels, while battery opens the Dashboard.

Only Blur and Frosted Glass request Niri's native shaped blur. Translucent uses
client alpha without compositor blur. All modes reserve desktop work area, and
the wallpaper continues beneath the bar's reserved strip.

On laptops, battery level uses a rounded proportional indicator with optional
percentage or power-state text beside it. Missing batteries and backlights are
omitted or shown as unavailable instead of preventing the shell from starting.

## Shell surface styles

Appearance offers **Solid**, **Blur**, and **Frosted Glass** for primary shell
panels independently of the bar. Dashboard/Settings, Launcher, Dock,
Notification Center, Wallpaper Picker, Session Menu, and OSD use the shared
policy. Cards, text, icons, and controls remain opaque. Heads-up notification
cards remain opaque, while calendar and tray popups follow the bar's visual
policy.

## Launcher

Open **Apps** from the bar or Dock to reveal a centered bottom app drawer. With
an empty query, the Launcher shows its handle, rounded search field, applications
pinned to the Dock, and a scrollable **All apps** grid. It is positioned above a
bottom bar and the optional Dock or task panel.

Typing switches the content to detailed search results covering installed
applications, open Niri windows, layout actions, and shell actions. Action names,
result kinds, descriptions, empty states, and keyboard hints are localized in
Brazilian Portuguese.

Use the arrow keys to move through the application grid or result list, Enter
to activate, and Escape to close. Right-click an installed application in the
pinned row, app grid, or search results to open **Pin to Dock** or
**Unpin from Dock**. Window and shell-action results are not pinnable.

```bash
qs ipc -p /path/to/lumina-shell call launcher toggle DP-1
```

Replace `DP-1` with an output reported by `niri msg outputs`. An unavailable
name falls back to a connected output. Detailed behavior is documented in
[launcher.md](launcher.md).

## Dock and task panel

The optional application dock is configured under **Settings → Dock** and is
disabled by default. It has two presentation modes:

- **Floating dock:** a compact centered surface sized to its visible icons;
- **Task panel:** a full-width bottom panel with application icons centered.

The Launcher button is always first. Pinned applications follow it, and running
Niri applications can be appended as grouped items. Clicking a running item
focuses its window; repeated clicks cycle through multiple windows from the same
application. Clicking a pinned item that is not running launches its desktop
entry.

Right-click an application icon to open an explicit **Pin to Dock** or
**Unpin from Dock** action. The Settings page can also remove individual
favorites or clear the complete list.

Automatic hiding leaves a small bottom-edge reveal region. The floating mode
uses the center of the edge, while task-panel mode uses the complete bottom
edge. Workspace reservation is available only while automatic hiding is off.
When the main bar is at the bottom, the dock is positioned above it.

Both modes follow the current Solid, Blur, or Frosted Glass shell style. Long
application lists scroll horizontally. Detailed behavior and current limits are
in [dock.md](dock.md).

## Dashboard

The status cluster or account avatar opens the unified control center. The
**Dashboard** tab provides:

- detected account identity and Linux distribution;
- localized time and date;
- weather and the current day's temperature range;
- audio, microphone, brightness, and power-profile controls;
- notification history and Do Not Disturb;
- MPRIS media controls;
- Wi-Fi, wired, and Bluetooth status;
- battery and uptime information;
- an inline calendar.

The header contains shortcuts for Settings, session controls, Do Not Disturb,
and closing the overlay. Dashboard and Settings share the same overlay, output
selection, services, and stores.

## Weather

Weather is configured under **Settings → Weather**.

**Show weather** controls both presentation and background activity. When it is
disabled, Lumina hides the Dashboard weather block and stops location and
forecast requests.

Automatic mode estimates city, region, latitude, and longitude from the current
public IP address. Lumina does not save the IP. It caches only the resolved
city, region, coordinates, and timestamp for 24 hours. VPNs, proxies, mobile
networks, and corporate gateways may report a nearby city or an exit location.

Manual mode accepts a city or recognizable place name. The page also provides
15, 30, 60, and 120 minute refresh intervals and an immediate **Refresh**
action. The development override remains available:

```bash
LUMINA_WEATHER_LOCATION="Fortaleza" qs -p .
```

Detailed behavior and privacy notes are in [weather.md](weather.md).

## Graphical settings

Choose the settings action in the control-center header. The sidebar contains
twelve categories:

- **Appearance:** theme, dynamic palette, wallpaper, shell surfaces, motion,
  shape, and density;
- **Bar:** surface, scale, geometry, active widgets, and widget settings;
- **Dashboard:** opening behavior, density, identity, and visible cards;
- **Dock:** enablement, floating/task-panel presentation, auto-hide, size,
  workspace reservation, and pinned applications;
- **Weather:** visibility, automatic or manual location, and refresh interval;
- **Connectivity:** Wi-Fi, wired profiles, and Bluetooth devices;
- **Behavior:** outside-click dismissal, output fallback, confirmation, and
  reduced motion;
- **Notifications:** DND, popup placement, timing, limits, images, and history;
- **OSD:** visibility, position, timing, size, values, and event types;
- **Session:** visible actions and confirmation policy;
- **System:** integration state, diagnostics, configuration, and recovery;
- **About:** version, license, documentation, and credits.

The page header reports `Saved`, `Saving…`, or `Could not save`. Central shell
settings use debounced schema-v8 persistence. Weather and Dock use separate
feature-scoped state files so their location and application-surface settings
can evolve independently of the shell schema.

Settings can open directly on an output and category:

```bash
qs ipc -p /path/to/lumina-shell call settings open DP-1
qs ipc -p /path/to/lumina-shell call settings openCategory dock DP-1
qs ipc -p /path/to/lumina-shell call settings openCategory weather DP-1
qs ipc -p /path/to/lumina-shell call settings openCategory connectivity DP-1
qs ipc -p /path/to/lumina-shell call settings category osd
```

Available category identifiers are `appearance`, `bar`, `dashboard`, `dock`,
`weather`, `connectivity`, `behavior`, `notifications`, `osd`, `session`,
`system`, and `about`. `wallpaper` remains a compatibility alias for
`appearance`.

## Connectivity

Connectivity is configured under **Settings → Connectivity**.

### Wi-Fi

The page can enable or disable Wi-Fi, scan nearby networks, connect or
disconnect, manage autoconnect for saved profiles, and forget inactive saved
profiles. Open networks connect directly. Protected networks open a password
dialog.

Passwords are never written to `ConfigStore` or returned by the connectivity
status endpoint. Lumina writes the password to a temporary cache file, changes
it to mode `0600`, passes it to NetworkManager with `passwd-file`, and clears
and removes the file after the attempt.

The initial implementation targets open and personal WPA-PSK networks.
Enterprise 802.1X, certificates, hotspot creation, and VPN editing remain
outside the first management pass.

### Wired network

Existing NetworkManager Ethernet profiles can be connected, disconnected, and
configured for automatic connection. Advanced IP, DNS, route, VLAN, bridge,
bond, and MTU editing remains delegated to dedicated NetworkManager tools.

### Bluetooth

The page can enable the adapter, run a bounded discovery session, list devices,
pair, connect, disconnect, and remove an inactive paired device. Pairing modes
that require a graphical agent or confirmation code depend on the system's
active Bluetooth agent.

Detailed limits and diagnostics are in [connectivity.md](connectivity.md).

## Notifications

The notification button opens history and shows unread state. Do Not Disturb
suppresses popup surfaces while preserving history. Only one process can own
`org.freedesktop.Notifications`; stop another active notification daemon before
testing Lumina as the owner.

## Wallpapers and color

The wallpaper action opens the image picker for the selected output. Paths are
persisted independently per output with a shared fallback. Dynamic color stores
coordinated Light and Dark variants and supports Auto, Content, Expressive,
Fidelity, Fruit Salad, Monochrome, Neutral, Rainbow, and Tonal Spot profiles.

```bash
qs ipc -p /path/to/lumina-shell call wallpaper palette expressive
qs ipc -p /path/to/lumina-shell call wallpaper status DP-1
```

## Layout and session

The Session surface contains typed Niri layout actions and lock, suspend,
logout, restart, and power-off requests. Destructive confirmations are
configurable. Secure locking remains the responsibility of the configured
external locker.

## OSD integration

Lumina shows OSDs for audio, microphone, brightness, power, and published lock
state. Example IPC calls:

```bash
qs ipc -p /path/to/lumina-shell call audio outputStep 5
qs ipc -p /path/to/lumina-shell call audio outputMute
qs ipc -p /path/to/lumina-shell call brightness step 5
qs ipc -p /path/to/lumina-shell call osd lock CapsLock true DP-1
```

## Diagnostics

Read service state without changing it:

```bash
qs ipc -p /path/to/lumina-shell call audio status
qs ipc -p /path/to/lumina-shell call brightness status
qs ipc -p /path/to/lumina-shell call power status
qs ipc -p /path/to/lumina-shell call media status
qs ipc -p /path/to/lumina-shell call niri status
qs ipc -p /path/to/lumina-shell call connectivity status
qs ipc -p /path/to/lumina-shell call connectivity-manager status
qs ipc -p /path/to/lumina-shell call weather status
qs ipc -p /path/to/lumina-shell call launcher status
qs ipc -p /path/to/lumina-shell call config status
qs ipc -p /path/to/lumina-shell call diagnostics status
qs ipc -p /path/to/lumina-shell call configFile status
```

Known portal and notification-name warnings are documented in
[compatibility.md](compatibility.md).

# User Guide

## Bar

Lumina creates one instance of **Lumina's Material Expressive bar** for each
connected output. Its default edge-to-edge tonal surface places launcher,
overview, transforming workspaces, and localized date/time on the left; a
temporary Niri context capsule in the center; and tray, notifications, live
system status, and the Lumina Dashboard button on the right.

The system-status cluster can group network, volume, and battery into one
pill, or display them individually. Missing hardware is omitted. Clicking the
cluster opens the existing Dashboard rather than another popup. Wallpaper and
session actions remain in the Dashboard by default, but can be enabled on the
bar.

The Bar settings page controls:

- top or bottom position, edge-to-edge or floating surface, visible height,
  margin, opacity, spacing, and compact mode;
- Always, Contextual, or Hidden Niri context and the contextual timeout;
- title, application ID, column, localized date style, 12/24-hour time, and
  seconds;
- grouped or individual status and individual service visibility;
- independent left/right widget order with Move up, Move down, and Show/Hide.

Context is event-driven and independent per output. In Contextual mode, a
window, app ID, column, workspace, or action-error change reveals the capsule
for the configured duration. Narrow layouts first remove secondary text and
optional actions; the central context elides instead of overlapping the side
clusters.

## Launcher

Open **Apps** from the bar and type to search:

- installed desktop applications;
- open Niri windows;
- layout and shell actions.

Use the arrow keys to move, Enter to activate, and Escape to close.

The launcher can also be opened from a Niri key binding:

```bash
qs ipc -p /path/to/lumina-shell call launcher toggle DP-1
```

Replace `DP-1` with the output reported by `niri msg outputs`. An unavailable name falls back to a connected output.

## Control center

The status/volume chip opens a centered desktop dashboard. The **Dashboard** tab provides:

- the detected user, Linux distribution, time, date, and system uptime;
- current weather and the day's temperature range;
- output and microphone levels;
- display brightness when a backlight exists;
- notification history and Do Not Disturb;
- MPRIS media controls with automatic playing, paused, and idle detection;
- Wi-Fi and Bluetooth state;
- battery state and power profiles;
- an inline calendar.

The **Settings** tab contains persistent shell configuration in a fixed
category sidebar and independently scrollable content area. Recent
notifications remain in the Dashboard so daily actions do not require
switching context. The header contains shortcuts for settings, session
controls, Do Not Disturb, and closing the dashboard.

Hardware controls degrade to an unavailable state instead of preventing the shell from starting.

Weather data comes from Open-Meteo. Lumina uses the city represented by the system timezone by default. To select a more precise place, start the shell with a city, postal code, or place name:

```bash
LUMINA_WEATHER_LOCATION="Fortaleza" qs -p .
```

The integration refreshes every 30 minutes and remains unavailable without affecting the rest of the shell when the network or location lookup fails.

The control center can also be opened and switched through IPC:

```bash
qs ipc -p /path/to/lumina-shell call control open DP-1
qs ipc -p /path/to/lumina-shell call control page settings
qs ipc -p /path/to/lumina-shell call control close
```

## Graphical settings

Choose the settings action in the control-center header. Dashboard and
settings are two views of the same overlay, so they cannot compete for the
active output or keyboard focus. The nine categories are:

- **Appearance:** theme mode, dynamic palette, wallpaper, transparency,
  motion, shape, and density;
- **Bar:** edge-to-edge or floating surface geometry, Niri context, date and
  time, grouped status, optional actions, and left/right widget ordering;
- **Dashboard:** opening behavior, density, and visible cards;
- **Behavior:** outside-click dismissal, output fallback, destructive-action
  confirmation, and reduced motion;
- **Notifications:** DND, popup placement, timing, limits, images, and history;
- **OSD:** visibility, position, timing, size, values, and event types;
- **Session:** visible actions and confirmation policy;
- **System:** live integration state, diagnostics, configuration, and recovery;
- **About:** local version, license, documentation, and credits.

`Edit config` and its folder action use the system default application.
Category reset is immediate; restoring everything requires a second
confirmation. The page header reports `Saved`, `Saving…`, or
`Could not save`.

Settings can open directly on an output and category:

```bash
qs ipc -p /path/to/lumina-shell call settings open DP-1
qs ipc -p /path/to/lumina-shell call settings openCategory osd DP-1
qs ipc -p /path/to/lumina-shell call settings category wallpaper
```

Available category identifiers are `appearance`, `bar`, `dashboard`,
`behavior`, `notifications`, `osd`, `session`, `system`, and `about`.
`wallpaper` remains a compatibility alias for `appearance`. Closing and
reopening follows the configured memory policy; explicit IPC calls can select
the page and category.

Schema 5 writes are debounced, so sliders update the shell without writing
once per pointer movement. Schema 4 files migrate in place. Retired
layout-selection and single-order fields in existing schema 5 files are
ignored safely and removed on the next save. Invalid JSON is still copied to
the adjacent `.invalid` backup before defaults are restored.

## Notifications

The **Alerts** chip opens notification history. Do Not Disturb suppresses popup surfaces while preserving history.

Only one process can own `org.freedesktop.Notifications`. If Noctalia already owns it, Lumina waits without replacing or terminating Noctalia. Stop the other notification daemon before testing Lumina as the active daemon.

## Wallpapers and color

The **Wall** chip opens the image picker on the selected output. Wallpaper
paths are persisted independently per output with a shared default fallback.
Dynamic color samples the focused output wallpaper and updates semantic Lumina
colors. The Appearance page offers Auto, Content, Expressive, Fidelity, Fruit
Salad, Monochrome, Neutral, Rainbow, and Tonal Spot profiles. Auto chooses a
profile from the saturation of the extracted wallpaper color. Each profile
also derives low-chroma tonal surfaces, so the bar, dashboard, settings, and
other overlays share the wallpaper hue while maintaining readable contrast.

The profile can also be changed through IPC:

```bash
qs ipc -p /path/to/lumina-shell call wallpaper palette expressive
qs ipc -p /path/to/lumina-shell call wallpaper status DP-1
```

## Layout and session

The **Session** chip contains typed Niri layout actions and lock, suspend,
logout, restart, and power-off requests. Confirmation for destructive actions
is configurable; lock and suspend are submitted directly. Secure locking
remains the responsibility of the configured external locker.

## OSD integration

Lumina shows OSDs for changes performed through its audio and brightness services:

```bash
qs ipc -p /path/to/lumina-shell call audio outputStep 5
qs ipc -p /path/to/lumina-shell call audio outputMute
qs ipc -p /path/to/lumina-shell call brightness step 5
```

Compositor bindings can publish lock-key state:

```bash
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
qs ipc -p /path/to/lumina-shell call weather status
qs ipc -p /path/to/lumina-shell call config status
qs ipc -p /path/to/lumina-shell call diagnostics status
qs ipc -p /path/to/lumina-shell call configFile status
```

Known portal and notification-name warnings are documented in [compatibility.md](compatibility.md).

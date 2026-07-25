# User Guide

## Bar

Lumina creates one top bar for each connected output. The left side contains the launcher, overview, and output workspaces. The center follows the active window. The right side contains Niri/output state, tray items, quick settings, notifications, wallpaper, session controls, and the calendar clock.

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

- the active workspace, output, time, date, and system uptime;
- current weather and the day's temperature range;
- output and microphone levels;
- display brightness when a backlight exists;
- notification history and Do Not Disturb;
- MPRIS media controls;
- Wi-Fi and Bluetooth state;
- battery state and power profiles;
- an inline calendar.

The **Notifications** tab expands notification history while keeping the daily controls and system status available. The header contains shortcuts for refreshing Niri output state, opening settings and session controls, toggling connectivity, Do Not Disturb, dynamic color, and closing the dashboard.

Hardware controls degrade to an unavailable state instead of preventing the shell from starting.

Weather data comes from Open-Meteo. Lumina uses the city represented by the system timezone by default. To select a more precise place, start the shell with a city, postal code, or place name:

```bash
LUMINA_WEATHER_LOCATION="Fortaleza" qs -p .
```

The integration refreshes every 30 minutes and remains unavailable without affecting the rest of the shell when the network or location lookup fails.

The control center can also be opened and switched through IPC:

```bash
qs ipc -p /path/to/lumina-shell call control open DP-1
qs ipc -p /path/to/lumina-shell call control tab notifications
qs ipc -p /path/to/lumina-shell call control close
```

## Graphical settings

Choose the settings action in the control-center header. The settings surface controls:

- wallpaper-derived dynamic color;
- detailed or compact Niri status in the bar;
- OSD visibility and duration;
- Do Not Disturb;
- wallpaper directory;
- restoration of default preferences.

Reset requires a second confirmation click. The configuration card shows its schema and storage path.

## Notifications

The **Alerts** chip opens notification history. Do Not Disturb suppresses popup surfaces while preserving history.

Only one process can own `org.freedesktop.Notifications`. If Noctalia already owns it, Lumina waits without replacing or terminating Noctalia. Stop the other notification daemon before testing Lumina as the active daemon.

## Wallpapers and color

The **Wall** chip opens the image picker on the selected output. Wallpaper paths are persisted independently per output with a shared default fallback. Dynamic color samples the focused output wallpaper and updates semantic Lumina colors.

## Layout and session

The **Session** chip contains typed Niri layout actions and lock, suspend, logout, restart, and power-off requests. Every session-state action requires confirmation. Secure locking remains the responsibility of the configured external locker.

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
qs ipc -p /path/to/lumina-shell call connectivity status
qs ipc -p /path/to/lumina-shell call weather status
qs ipc -p /path/to/lumina-shell call config status
```

Known portal and notification-name warnings are documented in [compatibility.md](compatibility.md).

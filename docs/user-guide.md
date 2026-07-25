# User Guide

## Bar

Lumina creates one instance of **Lumina's Material Expressive bar** for each
connected output. Its default 56-pixel, edge-to-edge tonal surface places
launcher, overview, transforming workspaces, and localized date/time on the
left; a temporary Niri context capsule in the center; and tray, notifications,
live system status, and the Lumina Dashboard button on the right.

The focused workspace expands into an accent pill. Other active workspaces
retain a quiet compact pill, while inactive workspaces recede to lightweight
markers without reducing their keyboard or pointer target. The clock is the
primary date/time element and the date uses a secondary text role.

The system-status cluster can group network, volume, and battery into one
pill, or display them individually. Missing hardware is omitted. Clicking the
cluster opens the existing Dashboard rather than another popup. Wallpaper and
session actions remain in the Dashboard by default, but can be enabled on the
bar.

The Bar settings page controls:

- a Solid, Blur, Frosted Glass, or Transparent bar background and independent
  background opacity;
- top or bottom position, edge-to-edge or floating geometry, 40–80 pixel
  height, margin, spacing, and compact mode;
- automatic content scaling from the selected height or a manual 80–140%
  scale;
- Always, Contextual, or Hidden Niri context and the contextual timeout;
- title, application ID, column, localized date style, 12/24-hour time, and
  seconds;
- grouped or individual status, individual service visibility, optional
  network/volume text, and a grouped tray menu or always-visible tray icons;
- one global switch for resting widget pill backgrounds, without removing
  hover, focus, open, urgency, or error feedback;
- independent left/right widget order with Move up, Move down, and Show/Hide.

Automatic scaling uses 56 pixels as its 100% reference and proportionally
updates widget surfaces, icons, text, workspace shapes, padding, gaps, badges,
and pointer targets using the direct `height ÷ 56` ratio. The 40–80 pixel
height range therefore maps to approximately 71–143%. Compact mode further
reduces density without ignoring the chosen height or scale; a 30-pixel
interaction floor applies only at the smallest combinations.

Bar background opacity is separate from **Appearance → Transparency**. The
Appearance controls continue to affect Dashboard, Settings, and other shell
surfaces, while **Bar → Surface → Background opacity** changes only Blur and
Frosted Glass. Blur is a clean native background blur with a tonal tint.
Frosted Glass adds a subtle grain, optical highlight, and stronger glass edge.
Transparent mode keeps widgets on their own subtle tonal surfaces for
contrast. On Niri 26.04, Blur and Frosted Glass request native background blur
limited to the bar surface. All four modes reserve desktop work area, so tiled
windows do not appear behind bar controls. Lumina's wallpaper surface ignores
shell exclusion zones and continues beneath the reserved strip, allowing
Transparent to reveal the wallpaper without exposing a second bar surface.
Existing `translucent` preferences are loaded as Blur automatically.

When automatic content scaling is enabled, Settings shows the calculated
effective percentage as a read-only value. Disabling it exposes the manual
slider in five-percent steps from 80% through 140%, with 100% as the reference.

Context is event-driven and independent per output. In Contextual mode, a
window, app ID, column, workspace, or action-error change reveals the capsule
for the configured duration. Narrow layouts first remove secondary text and
optional actions; the central context derives its maximum width from the
smaller side clearance, so it elides or recedes instead of overlapping either
cluster.

Network and volume labels can be disabled independently while retaining their
icons, live state, Dashboard action, tooltip, and accessible description.
Responsive compact layouts may hide these labels regardless of the preference.

Disabling **Widget backgrounds** removes resting pill surfaces from launcher,
overview, workspaces, date/time, context, tray, notifications, system status,
Dashboard, and optional actions at once. Interactive and semantic state layers
still appear temporarily, and tray menus, tooltips, calendars, and other
popups keep their own surfaces.

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
- **Bar:** background transparency, responsive scale, edge-to-edge or floating
  geometry, Niri context, date and time, grouped status, optional actions, and
  left/right widget ordering;
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

Schema 6 writes are debounced, so sliders update the shell without writing
once per pointer movement. Schema 3, 4, and 5 files migrate in place. Existing
global transparency initializes the independent bar mode during schema-5
migration without changing the global preference. Retired layout-selection
and single-order fields are ignored safely and removed on the next save.
Invalid JSON is still copied to the adjacent `.invalid` backup before defaults
are restored.

## Notifications

The bell button opens notification history and keeps the unread count in a
compact badge. A crossed bell indicates Do Not Disturb, which suppresses popup
surfaces while preserving history.

The notification center grows from a compact empty state to a bounded,
scrollable history surface. Recent items use contained cards, while urgency
and unread state remain visible without turning the whole panel into an alert.

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
qs ipc -p /path/to/lumina-shell call launcher status
qs ipc -p /path/to/lumina-shell call config status
qs ipc -p /path/to/lumina-shell call diagnostics status
qs ipc -p /path/to/lumina-shell call configFile status
```

Known portal and notification-name warnings are documented in [compatibility.md](compatibility.md).

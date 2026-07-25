# Architecture Foundation

Lumina Shell runs as a Quickshell process composed of independent QML modules. Compositor and system integrations live in services and stores rather than visual components.

```text
Niri IPC event stream ───────────────┐
                                     ↓
niri msg --json outputs → NiriService
                                     ↓
              Output / Workspace / Window stores
                                     ↓
              Bar, launcher, control center, notifications
```

## Current increment

The Niri state increment introduces:

- `NiriService`, which owns the long-running `niri msg --json event-stream` process;
- newline-delimited JSON parsing through Quickshell `SplitParser`;
- automatic reconnection when the event-stream process stops;
- reactive output, workspace, and window stores;
- queued overview and workspace actions with reactive completion state;
- a demo fallback when `$NIRI_SOCKET` is unavailable;
- composable Classic and Expressive bar layouts with output-aware workspace,
  context, date/time, status, launcher, notification, and system-tray widgets.

The Niri event stream supplies a complete initial state followed by incremental updates. Unknown events are ignored so newer Niri versions can add event variants without breaking the shell.

## State ownership

`NiriService` translates compositor events into store operations:

- `WorkspacesChanged`, `WorkspaceActivated`, urgency, and active-window events update `WorkspaceStore`;
- `WindowsChanged`, window mutation, close, focus, urgency, and layout events update `WindowStore`;
- `OverviewOpenedOrClosed` updates the service overview state;
- output snapshots update `OutputStore`.

The stores replace their arrays after mutations so QML bindings receive deterministic change notifications.

`SystemInfoStore` owns session identity metadata used by the dashboard. It resolves the login name from the process environment and the distribution name from `/etc/os-release`, with generic fallbacks when either source is unavailable.

### Output refresh policy

Niri 26.04 does not expose output changes through the event-stream event enum. Lumina therefore requests `niri msg --json outputs`:

- when `NiriService` starts;
- after a successful Niri configuration reload;
- when `Quickshell.screens` changes.

Requests are debounced and coalesced. Lumina does not continuously poll outputs.

### Column position

Niri window state includes `layout.pos_in_scrolling_layout`, a 1-based pair containing the column index and the tile index inside that column. `WindowStore` normalizes this into a compact label for the active window on each output. Floating windows are represented explicitly and windows without a scrolling-layout position omit the indicator.

## Bar composition

`Bar.qml` owns only the per-screen `PanelWindow`, layer-shell geometry, output
selection, and the state passed to the active visual layout. `BarSurface`
implements the geometry contract:

- **edge-to-edge:** the surface and `PanelWindow` use `barHeight`, with no
  outer margin and a subtle edge divider;
- **floating:** `barHeight` remains the visible surface height while the
  window and exclusive zone add the configured margins.

`ExpressiveBarLayout` is the default schema-v5 preset. Its left and right
orders are registries of `Component` objects instantiated through `Loader`;
preferences therefore reorder or hide widgets without duplicating layout
branches. `ClassicBarLayout` preserves the previous floating composition and
legacy `barWidgetOrder` data as a fallback and regression reference.

Each output owns its own `ContextCapsule` and timeout. Window, application,
column, workspace, and action-error property changes restart that local timer;
there is no polling or process boundary in the visual component. Date/time
continues to use the shared `CalendarStore`, while its popup anchors below a
top bar and above a bottom bar.

`SystemStatusCluster` reads `AudioService`, `ConnectivityService`, and
`PowerService` directly and opens the existing Dashboard through
`ControlCenterStore`. Missing capabilities are omitted. It never creates a
second quick-controls popup.

## Process policy

The event-stream process is persistent and read-only. Output snapshots and compositor actions use separate short-lived `Process` objects, because an IPC connection that has entered event-stream mode cannot also accept regular requests.

When the event stream exits unexpectedly, Lumina immediately clears compositor-owned state, stops an in-flight output snapshot, and reconnects with bounded exponential backoff. A new stream remains in the synchronizing state until output, workspace, and window snapshots arrive; a five-second initial-state timeout restarts an incomplete connection. The bar exposes connecting, synchronizing, connected, reconnecting, and demo states without blocking the UI.

### Niri action lifecycle

Visual components submit typed requests to `NiriService`; they never start command processes themselves. The service serializes requests so rapid workspace or overview clicks cannot replace a process that is still running.

For each action, the service:

- exposes `running`, `succeeded`, or `failed` state;
- captures standard output and standard error;
- treats the process exit code as the source of truth;
- emits a completion signal with the action name and message;
- retains the most recent action error for diagnostics.

The bar presents failures through the Niri status indicator for six seconds. A later successful queued action does not erase an earlier failure before that feedback interval expires.

## System tray

Lumina consumes Quickshell's shared `SystemTray.items` object model and creates one visual view per output. Registration and item state remain process-global, so adding more bars does not create duplicate activation or menu actions.

Each tray item owns its hover, pressed, attention, tooltip, activation, secondary activation, scrolling, and menu behavior. `QsMenuOpener` exposes DBus menu entries to a Lumina-styled popup with separators, selection controls, disabled states, and nested entries.

## Launcher and search providers

`LauncherStore` owns the launcher query, selection, active output, and ranked results. It combines three event-driven sources:

- `DesktopEntries.applications` for installed applications;
- `WindowStore.windows` for currently open Niri windows;
- typed shell actions exposed by `NiriService`.

The launcher creates one overlay surface per screen but makes only the requested output visible. It takes exclusive keyboard focus while open, supports arrow-key navigation, and releases the surface after launching or closing.

The `launcher` IPC target allows Niri key bindings to open the surface without routing commands through visual components:

```bash
qs ipc -p /home/maylton/Development/lumina-shell call launcher toggle DP-1
```

Application launches use the native `DesktopEntry.execute()` method. Window and shell results call typed `NiriService` functions.

## Notifications

`NotificationService` owns Quickshell's native `NotificationServer` and retains at most 50 tracked notification generations. Incoming notifications are reduced into immutable history entries while retaining the original object only for lifecycle and action calls.

The service provides:

- a three-item popup queue on the focused output;
- bounded timeouts with longer visibility for critical notifications;
- replacement handling without stale close events affecting newer generations;
- action invocation and client-visible dismiss/expire reasons;
- unread state, bounded history, clearing, and Do Not Disturb.

Do Not Disturb suppresses new popup surfaces without discarding history. The notification center and popups each create a surface only on the selected output, and visual components call service methods instead of owning the D-Bus integration.

## Daily-control services

Daily hardware state is split into typed singleton services:

- `AudioService` binds the current PipeWire sink and source through `PwObjectTracker`, then exposes volume and mute operations.
- `BrightnessService` contains the optional `brightnessctl --class=backlight` process boundary. Systems without a backlight remain usable and report the capability as unavailable.
- `PowerService` consumes native UPower battery state and the power-profiles daemon.
- `MediaService` selects the currently playing MPRIS client, then a paused session, and distinguishes native playing, paused, and stopped states so stale player metadata is not presented as active playback.
- `ConnectivityService` consumes the native NetworkManager and BlueZ models for network, Wi-Fi, adapter, and connected-device status.
- `WeatherService` resolves an explicit location or the system timezone through Open-Meteo geocoding, then refreshes current conditions and a three-day forecast every 30 minutes.

Every service exposes a read-only `status` IPC operation for diagnostics. Visual components only call typed service methods and never execute the underlying system tools.

## OSD and control center

`OsdStore` reduces volume, microphone, brightness, session-lock, and explicit lock-key events into one timed presentation state. The OSD resolves the focused Niri output, never requests keyboard focus, and closes if that output disappears. The `osd` IPC target allows compositor key bindings to publish lock-key state without embedding input-device assumptions in the shell.

The Material control center is a centered desktop surface with stable
dimensions and two views. `DashboardView` combines the active workspace and
output, clock, weather, daily controls, notification history, media,
connectivity, power, and calendar. `ShellSettingsView` provides persistent
configuration through focused category components. `ControlTabBar` switches
between them with a short horizontal transition; every settings category owns
its own scroll position.

Audio and brightness sliders, media actions, Wi-Fi and Bluetooth toggles, Do
Not Disturb, dynamic color, battery status, and power profiles all call the
same typed service methods used by IPC. `ControlCenterStore` owns `activePage`,
`settingsCategory`, the selected output, and uptime presentation. It
participates in `OverlayStore`, so Dashboard and Settings never create
competing surfaces or duplicate focus state.

## Graphical settings

Settings use reusable page, section, row, switch, slider, combo, action,
segmented-control, sidebar, and preview components. The fixed sidebar exposes
Appearance, Bar, Dashboard, Behavior, Notifications, OSD, Session, System,
and About; only the right content area scrolls. Every visible preference calls
a typed `ConfigStore` setter or an existing service, and consumer modules
observe the same state immediately.

`ConfigFileService` owns argument-array `xdg-open` processes.
`SystemDiagnosticsService` owns local version and diagnostic processes.
Visual components never construct shell command strings.
`modules/settings/Settings.qml` remains an IPC bridge into the control center,
not a second visual surface. IPC can open a category directly; `wallpaper`
temporarily normalizes to Appearance.

## Persistent configuration

`ConfigStore` persists user state through an atomic Quickshell `FileView` and
`JsonAdapter`. Schema 4 added semantic appearance, dashboard, behavior,
notification, OSD, session, and navigation preferences. Schema 5 adds the
Expressive/Classic bar preset, edge/floating surface, context policy,
date/status options, widget visibility, and independent left/right orders
while retaining the legacy Classic order.

The default path is `Quickshell.stateDir/lumina-state.json`.
`LUMINA_STATE_PATH` can redirect it for isolated validation. Schema v2
migrated the single-string wallpaper shape into a default plus per-output map.
Schema v3 added OSD and bar-detail preferences. Schema v4 normalizes missing
and out-of-range values. Schema v5 migrates v4 in place, filters unknown or
duplicate widget IDs, preserves valid ordering, and restores required IDs
without changing wallpapers or preferences outside the Bar category.

Writes are debounced and only occur after initialization, so loading,
migration, and slider movement cannot continuously rewrite the file.
`dirty`, `saving`, `lastSavedAt`, `lastSaveSucceeded`, and
`saveStatusLabel` expose progress. Category defaults and full defaults share
the pure `ConfigSchema.js` definitions used by migration tests.

Before accepting loaded state, `ConfigStore` parses the original JSON independently of `JsonAdapter`. Invalid JSON is copied to the adjacent `.invalid` path, replaced atomically with defaults, and surfaced through graphical settings and the `config status` IPC operation.

## Wallpaper and dynamic color

Lumina owns one background-layer wallpaper surface per output. `WallpaperService` resolves a per-output assignment with a shared default fallback and exposes typed setters plus a `wallpaper` IPC target.

Quickshell's `ColorQuantizer` samples the focused output wallpaper. The service
scores quantized colors for saturation and mid-tone contrast, then derives
accent roles plus low-chroma neutral and neutral-variant tones for surfaces,
containers, text, and outlines. These tonal levels give the bar and overlays a
wallpaper-related tint without using saturated accent colors as large
backgrounds. Disabling dynamic color restores the static Lumina palette
immediately.

The wallpaper picker uses Qt's `FolderListModel` with image-only filters. It targets the output from which it was opened, previews the configured directory without copying files, and persists paths containing spaces or URL encoding through the same service boundary.

## Layout and session controls

Advanced layout requests remain typed methods on `NiriService`. The session surface exposes focus, move, center, width, floating, fullscreen, and tabbed-column operations without placing Niri commands in QML visual components. A subset is also available through launcher action results.

`SessionService` owns lock, suspend, logout, restart, and power-off execution.
Destructive confirmation follows schema-backed policy; lock and suspend submit
directly. Logout uses `NiriService.quitSession()`; the remaining operations use
argument-array `loginctl` or `systemctl` processes and report their exit state.

The `session` IPC target can open the menu and describe the resolved command without executing it. This provides a safe diagnostics path for session integration.

## Multi-output surfaces

`OverlayStore` is the process-wide coordinator for launcher, the unified
control center, notification center, wallpaper picker, and session menu
surfaces. It records the active surface and output so opening one full-screen
interactive overlay closes the previous one instead of stacking competing
keyboard surfaces.

Every overlay request resolves its target against `Quickshell.screens`. A missing or stale output name falls back to the first connected screen. If the active screen disappears, the overlay closes; notification popups move to the fallback screen; calendars on the removed screen close; context timers are destroyed with their bar delegate; and persisted wallpaper assignments remain available for a later reconnect.

Each module still creates one lightweight surface delegate per connected screen. The coordinator only makes the selected delegate visible, preserving independent per-output geometry without duplicating service state.

## Design system

Lumina uses Material 3 Expressive as its visual foundation while adapting it to desktop productivity and Niri's spatial workflow.

Design values are exposed through the single `Theme.luminaTokens` namespace:

- semantic color roles rather than component-specific hex values;
- a Material shape scale from `none` through `extraExtraLarge` and `full`;
- larger outer containers, smaller nested controls, and animated shape changes
  for resting, pressed, selected, and focused states;
- shared spacing and sizing scales;
- typography roles for labels, body text, and titles;
- motion durations used consistently by interactive components.

The bar adds semantic touch-target, workspace resting/active shape, and
workspace-transform motion tokens. Disabling animation or enabling reduced
motion shortens transformations through the existing global motion scale
while preserving focus and selected-state feedback.

The token namespace also provides the future boundary for wallpaper-derived dynamic color. Visual modules consume semantic roles and must not know how the palette was generated.

Other Quickshell desktops, including Sleex, are useful architectural references for modular widgets and centralized adaptive theming. Lumina does not inherit their compositor assumptions or visual identity: it remains Niri-first and develops its own Material Expressive component language.

Lumina's source is licensed under `GPL-3.0-or-later`. Runtime dependencies and external architectural or design references are listed separately in [`CREDITS.md`](../CREDITS.md); reference projects do not become source dependencies unless explicitly recorded there.

## Layer policy

- Bar: `Top`
- Launcher and control center: `Overlay`
- Wallpaper: `Background`
- Desktop widgets: `Bottom`

The bar uses the top layer so it remains visible over Niri's overview.

## Boundaries

Visual modules must not invoke `niri msg`, `wpctl`, `nmcli`, or similar commands directly. They call typed service functions such as `NiriService.focusWorkspace()` and `NiriService.toggleOverview()`.

## Next increment

The next open implementation areas are:

- laptop backlight and battery validation;
- physical two-output hotplug validation;
- 0.7 extended-beta features.

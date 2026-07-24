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
- workspace, focused-window, output, column-position, connection, overview, clock, calendar, launcher, and system-tray widgets in the bar.

The Niri event stream supplies a complete initial state followed by incremental updates. Unknown events are ignored so newer Niri versions can add event variants without breaking the shell.

## State ownership

`NiriService` translates compositor events into store operations:

- `WorkspacesChanged`, `WorkspaceActivated`, urgency, and active-window events update `WorkspaceStore`;
- `WindowsChanged`, window mutation, close, focus, urgency, and layout events update `WindowStore`;
- `OverviewOpenedOrClosed` updates the service overview state;
- output snapshots update `OutputStore`.

The stores replace their arrays after mutations so QML bindings receive deterministic change notifications.

### Output refresh policy

Niri 26.04 does not expose output changes through the event-stream event enum. Lumina therefore requests `niri msg --json outputs`:

- when `NiriService` starts;
- after a successful Niri configuration reload;
- when `Quickshell.screens` changes.

Requests are debounced and coalesced. Lumina does not continuously poll outputs.

### Column position

Niri window state includes `layout.pos_in_scrolling_layout`, a 1-based pair containing the column index and the tile index inside that column. `WindowStore` normalizes this into a compact label for the active window on each output. Floating windows are represented explicitly and windows without a scrolling-layout position omit the indicator.

## Process policy

The event-stream process is persistent and read-only. Output snapshots and compositor actions use separate short-lived `Process` objects, because an IPC connection that has entered event-stream mode cannot also accept regular requests.

When the event stream exits unexpectedly, Lumina waits briefly and reconnects. The bar exposes connecting, connected, and demo states without blocking the UI.

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

## Persistent configuration

`ConfigStore` persists user state through an atomic Quickshell `FileView` and `JsonAdapter`. The schema currently stores Do Not Disturb, wallpaper assignments, the wallpaper directory, and dynamic-theme preference.

The default path is `Quickshell.stateDir/lumina-state.json`. `LUMINA_STATE_PATH` can redirect it for isolated validation. Schema v2 migrates the original single-string wallpaper shape into a default wallpaper plus a per-output map, repairs invalid maps, and supplies the default CachyOS wallpaper directory.

Writes are debounced and only occur after initialization, so loading and migration cannot overlap or continuously rewrite the file.

## Wallpaper and dynamic color

Lumina owns one background-layer wallpaper surface per output. `WallpaperService` resolves a per-output assignment with a shared default fallback and exposes typed setters plus a `wallpaper` IPC target.

Quickshell's `ColorQuantizer` samples the focused output wallpaper. The service scores quantized colors for saturation and mid-tone contrast, then updates semantic primary, accent-container, foreground, and outline roles in `Theme`. Disabling dynamic color restores the static Lumina palette immediately.

The wallpaper picker uses Qt's `FolderListModel` with image-only filters. It targets the output from which it was opened, previews the configured directory without copying files, and persists paths containing spaces or URL encoding through the same service boundary.

## Layout and session controls

Advanced layout requests remain typed methods on `NiriService`. The session surface exposes focus, move, center, width, floating, fullscreen, and tabbed-column operations without placing Niri commands in QML visual components. A subset is also available through launcher action results.

`SessionService` owns lock, suspend, logout, restart, and power-off execution. Every session operation enters an explicit confirmation state before execution. Logout is submitted through `NiriService.quitSession()`; the remaining operations use argument-array `loginctl` or `systemctl` processes and report their exit state.

The `session` IPC target can open the menu and describe the resolved command without executing it. This provides a safe diagnostics path for session integration.

## Design system

Lumina uses Material 3 Expressive as its visual foundation while adapting it to desktop productivity and Niri's spatial workflow.

Design values are exposed through the single `Theme.luminaTokens` namespace:

- semantic color roles rather than component-specific hex values;
- contrasting shape tokens for resting, active, and focused surfaces;
- shared spacing and sizing scales;
- typography roles for labels, body text, and titles;
- motion durations used consistently by interactive components.

The token namespace also provides the future boundary for wallpaper-derived dynamic color. Visual modules consume semantic roles and must not know how the palette was generated.

Other Quickshell desktops, including Sleex, are useful architectural references for modular widgets and centralized adaptive theming. Lumina does not inherit their compositor assumptions or visual identity: it remains Niri-first and develops its own Material Expressive component language.

## Layer policy

- Bar: `Top`
- Launcher and control center: `Overlay`
- Wallpaper: `Background`
- Desktop widgets: `Bottom`

The bar uses the top layer so it remains visible over Niri's overview.

## Boundaries

Visual modules must not invoke `niri msg`, `wpctl`, `nmcli`, or similar commands directly. They call typed service functions such as `NiriService.focusWorkspace()` and `NiriService.toggleOverview()`.

## Next increment

The remaining 0.1 bar work is:

- tests for event reduction and reconnection;
- multi-output interaction refinement.

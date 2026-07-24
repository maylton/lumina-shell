# Architecture Foundation

Lumina Shell runs as a Quickshell process composed of independent QML modules. Compositor and system integrations live in services and stores rather than visual components.

```text
Niri IPC event stream
        ↓
NiriService
        ↓
WorkspaceStore / WindowStore
        ↓
Bar, launcher, control center, notifications
```

## Current increment

The Niri state increment introduces:

- `NiriService`, which owns the long-running `niri msg --json event-stream` process;
- newline-delimited JSON parsing through Quickshell `SplitParser`;
- automatic reconnection when the event-stream process stops;
- reactive workspace and window stores;
- overview and workspace actions exposed through the service API;
- a demo fallback when `$NIRI_SOCKET` is unavailable;
- workspace, focused-window, connection, overview, and clock widgets in the bar.

The Niri event stream supplies a complete initial state followed by incremental updates. Unknown events are ignored so newer Niri versions can add event variants without breaking the shell.

## State ownership

`NiriService` translates compositor events into store operations:

- `WorkspacesChanged`, `WorkspaceActivated`, urgency, and active-window events update `WorkspaceStore`;
- `WindowsChanged`, window mutation, close, focus, urgency, and layout events update `WindowStore`;
- `OverviewOpenedOrClosed` updates the service overview state.

The stores replace their arrays after mutations so QML bindings receive deterministic change notifications.

## Process policy

The event-stream process is persistent and read-only. Compositor actions use a separate short-lived `Process`, because an IPC connection that has entered event-stream mode cannot also accept regular requests.

When the event stream exits unexpectedly, Lumina waits briefly and reconnects. The bar exposes connecting, connected, and demo states without blocking the UI.

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

After native validation, the next state work will cover:

- explicit output state;
- column position and layout information;
- stronger action error reporting;
- tests for event reduction and reconnection;
- multi-output interaction refinement.

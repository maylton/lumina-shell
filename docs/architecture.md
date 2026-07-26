# Architecture Foundation

Lumina Shell starts as a Quickshell process composed of independent QML modules. Niri integration and other system state will live in services and stores rather than visual components.

```text
Niri IPC event stream
        ↓
NiriService
        ↓
Output / Workspace / Window stores
        ↓
Bar, launcher, control center, notifications
```

## Current increment

The first increment intentionally contains only:

- a `ShellRoot` entry point;
- a root-relative QML module structure;
- a multi-output `PanelWindow` bar;
- a minimal theme singleton;
- a clock using `SystemClock`;
- environment diagnostics.

This establishes the smallest runnable vertical slice before Niri IPC is introduced.

## Layer policy

- Bar: `Top`
- Launcher and control center: `Overlay`
- Wallpaper: `Background`
- Desktop widgets: `Bottom`

The bar uses the top layer so it remains visible over Niri's overview.

## Boundaries

Visual modules must not invoke `niri msg`, `wpctl`, `nmcli`, or similar commands directly. Those integrations will be introduced behind service APIs.

## Next increment

Create `NiriService` and consume `niri msg --json event-stream` to expose:

- outputs;
- workspaces;
- focused workspace;
- windows;
- focused window;
- overview state.

The first consumer will be the bar's workspace and focused-window indicators.

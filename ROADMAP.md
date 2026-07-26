# Lumina Shell Roadmap

Lumina Shell is a Niri-first desktop shell built with Quickshell and QML. This roadmap tracks the delivery order; implementation details belong in focused issues and pull requests.

## Product principles

- Niri-first rather than compositor-generic by default.
- Event-driven state from the Niri IPC stream.
- Material 3 Expressive adapted to desktop productivity.
- Multi-output behavior considered from the first component.
- Services and stores separated from visual modules.
- Optional integrations must fail gracefully.
- Rust is introduced only when QML is no longer the right boundary.

## 0.1 — Niri Foundation

### Foundation

- [x] Establish the repository and contribution workflow.
- [x] Add a runnable Quickshell entry point.
- [x] Add the first multi-output top bar.
- [x] Add minimal design tokens.
- [ ] Validate the foundation on CachyOS with Niri.
- [ ] Record the supported Quickshell and Niri versions.
- [ ] Select and add the project license.

### Niri IPC

- [ ] Connect to `$NIRI_SOCKET`.
- [ ] Consume the JSON event stream.
- [ ] Maintain reactive output, workspace, window, and overview state.
- [ ] Reconnect safely after compositor or socket interruption.
- [ ] Expose compositor actions through `NiriService`.

### First bar widgets

- [ ] Active workspace indicator.
- [ ] Focused window title and app ID.
- [ ] Overview button.
- [ ] Column position indicator.
- [ ] Clock and calendar popup.
- [ ] System tray.

## 0.2 — Daily Controls

- [ ] Audio and microphone service.
- [ ] Brightness service.
- [ ] Battery and power profile service.
- [ ] MPRIS media service.
- [ ] Volume, brightness, and lock-state OSDs.
- [ ] Material Expressive control center.
- [ ] Wi-Fi and Bluetooth status.

## 0.3 — Interactive Alpha

- [ ] Application launcher.
- [ ] Window and shell-action search providers.
- [ ] Notification daemon and popups.
- [ ] Notification history and Do Not Disturb.
- [ ] Dynamic theme generation from wallpaper.

## 0.4 — Desktop Alpha

- [ ] Wallpaper picker and per-output wallpaper state.
- [ ] Advanced Niri actions and layout controls.
- [ ] Session menu.
- [ ] Improved multi-output handling.
- [ ] Configuration persistence and migration.

## 0.5 — Public Beta

- [ ] Graphical settings.
- [ ] Installation and uninstall scripts.
- [ ] Environment diagnostics.
- [ ] Accessibility baseline.
- [ ] User and contributor documentation.
- [ ] Recovery from invalid configuration.

## 0.7 — Extended Beta

- [ ] Secure session lock.
- [ ] Optional dock.
- [ ] Optional desktop widgets.
- [ ] Performance profiling and long-running tests.

## 0.8 — Extension Preview

- [ ] Define stable extension boundaries.
- [ ] Launcher providers.
- [ ] Bar and control-center extensions.
- [ ] Optional Rust backend for indexing, caching, and persistence.

## 0.9 — Release Candidate

- [ ] Feature freeze.
- [ ] Configuration migration tests.
- [ ] Packaging for CachyOS and Arch Linux.
- [ ] Translation infrastructure.
- [ ] Critical bug and performance pass.

## 1.0 — Stable

- [ ] Stable Niri support.
- [ ] Reliable installation, upgrade, and removal.
- [ ] Complete user documentation.
- [ ] Keyboard navigation and accessibility baseline.
- [ ] No known critical defects.

## Current sprint

### Sprint 1 — Runnable foundation

The first pull request must deliver the smallest runnable vertical slice:

1. `ShellRoot` entry point.
2. Root-relative QML modules.
3. One top-layer bar per output.
4. A system clock.
5. Minimal theme tokens.
6. Environment diagnostics.
7. Architecture and contribution documentation.

### Acceptance criteria

- `qs -p .` starts without a fatal QML error.
- One bar appears on each output.
- The bar reserves its height and remains above Niri's overview.
- The clock updates.
- Stopping Quickshell removes all Lumina surfaces.
- No visual component invokes `niri msg` or other system commands directly.

## Next sprint

### Sprint 2 — Niri state

- Implement the event-stream connection.
- Add output, workspace, window, and overview stores.
- Display the active workspace and focused window in the bar.
- Add basic actions for switching workspaces and opening the overview.

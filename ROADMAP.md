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
- [x] Validate the foundation on CachyOS with Niri.
- [x] Record the supported Quickshell and Niri versions.
- [ ] Select and add the project license.

### Niri IPC

- [x] Connect to `$NIRI_SOCKET`.
- [x] Consume the JSON event stream.
- [x] Maintain reactive output, workspace, window, and overview state.
- [ ] Reconnect safely after compositor or socket interruption.
- [x] Expose compositor actions through `NiriService`.

### First bar widgets

- [x] Active workspace indicator.
- [x] Focused window title and app ID.
- [x] Overview button.
- [x] Column position indicator.
- [x] Clock and calendar popup.
- [x] System tray.

## 0.2 — Daily Controls

- [ ] Audio and microphone service.
- [ ] Brightness service.
- [ ] Battery and power profile service.
- [ ] MPRIS media service.
- [ ] Volume, brightness, and lock-state OSDs.
- [ ] Material Expressive control center.
- [ ] Wi-Fi and Bluetooth status.

## 0.3 — Interactive Alpha

- [x] Application launcher.
- [x] Window and shell-action search providers.
- [x] Notification daemon and popups.
- [x] Notification history and Do Not Disturb.
- [x] Dynamic theme generation from wallpaper.

## 0.4 — Desktop Alpha

- [x] Wallpaper picker and per-output wallpaper state.
- [x] Advanced Niri actions and layout controls.
- [x] Session menu.
- [x] Improved multi-output handling.
- [x] Configuration persistence and migration.

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

### Sprint 4 — Interactive and desktop alpha

This sprint delivers the 0.3 and 0.4 desktop surfaces:

1. Unified application, window, and shell-action search.
2. Notification daemon, popup queue, history, and Do Not Disturb.
3. Persistent per-output wallpapers and wallpaper-derived colors.
4. Advanced Niri layout actions and confirmed session controls.
5. Coordinated overlays with output fallback and disconnect handling.

### Acceptance criteria

- `qs -p .` starts without a fatal QML error.
- The bar shows the workspaces belonging to each output.
- Workspace clicks switch to the requested workspace.
- Window title and app ID update when the active window changes.
- The column indicator updates when focus moves between columns or stacked tiles.
- Output name, resolution, and scale match `niri msg --json outputs`.
- Opening and closing the overview updates the bar state.
- Disconnecting and reconnecting the event stream does not leave stale state.
- No visual component invokes `niri msg` directly.
- Only one full-screen interactive overlay is active at a time.
- An unavailable target output falls back to a connected output.

## Open follow-ups

1. [ ] Complete the 0.2 daily controls.
2. [ ] Add event-reduction and reconnection tests.
3. [ ] Validate overlay hotplug behavior with two physical outputs.
4. [ ] Select the project license.

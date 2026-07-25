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
- [x] Select and add the project license.

### Niri IPC

- [x] Connect to `$NIRI_SOCKET`.
- [x] Consume the JSON event stream.
- [x] Maintain reactive output, workspace, window, and overview state.
- [x] Reconnect safely after compositor or socket interruption.
- [x] Expose compositor actions through `NiriService`.

### First bar widgets

- [x] Active workspace indicator.
- [x] Focused window title and app ID.
- [x] Overview button.
- [x] Column position indicator.
- [x] Clock and calendar popup.
- [x] System tray.

## 0.2 — Daily Controls

- [x] Audio and microphone service.
- [x] Brightness service.
- [x] Battery and power profile service.
- [x] MPRIS media service.
- [x] Volume, brightness, and lock-state OSDs.
- [x] Material Expressive control center.
- [x] Wi-Fi and Bluetooth status.

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

- [x] Graphical settings.
- [x] Installation and uninstall scripts.
- [x] Environment diagnostics.
- [x] Accessibility baseline.
- [x] User and contributor documentation.
- [x] Recovery from invalid configuration.
- [x] Runtime internationalization foundation and contributor catalogs.

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
- [ ] Complete translation coverage and release catalogs.
- [ ] Critical bug and performance pass.

## 1.0 — Stable

- [ ] Stable Niri support.
- [ ] Reliable installation, upgrade, and removal.
- [ ] Complete user documentation.
- [ ] Keyboard navigation and accessibility baseline.
- [ ] No known critical defects.

## Current sprint

### Sprint 6 — Public beta

This sprint completes the 0.5 public-beta foundation:

1. Graphical configuration with schema v5 persistence and safe schema v3/v4
   migration.
2. Automatic backup and recovery for invalid configuration.
3. Safe managed installation and removal.
4. Native environment and service diagnostics.
5. Keyboard, focus, and assistive-technology metadata baseline.
6. User, installation, compatibility, and contributor documentation.
7. Lumina's Material Expressive bar refinement with schema v5 migration,
   per-output context, configurable widget ordering, and edge-to-edge or
   floating geometry.

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
- Missing batteries or backlights degrade to an unavailable state.
- Daily-control IPC status endpoints reflect the native services.
- Invalid JSON is preserved before defaults are restored.
- Install and uninstall scripts reject unsafe or unmanaged targets.
- Primary exclusive surfaces support keyboard dismissal and traversal.
- Dashboard and graphical settings share one overlay, service layer, and
  persistent configuration store.
- Graphical settings provide nine keyboard-accessible categories, direct IPC
  navigation, scoped reset, and debounced save feedback.
- Lumina's Material Expressive bar is the only bar layout and supports both
  edge-to-edge and floating surfaces.
- The default edge-to-edge bar uses a substantial 56-pixel surface, clear
  clock/date hierarchy, and expressive workspace state without shrinking
  interaction targets.
- Workspace, date/time, Niri context, system status, notification, tray, and
  Dashboard clusters remain single-line and output-aware.
- System tray items can be grouped in a compact popover or kept visible
  inline, and notifications use a compact stateful icon with an unread badge.
- Network and volume text can be hidden independently without disabling their
  status icons, services, tooltips, or Dashboard access.
- Bar, Dashboard, and Settings distinguish spatial shape/bounds transitions
  from color/opacity effects, share semantic spacing roles, and remove
  expressive overshoot when reduced motion is enabled.
- Related Settings rows share tonal group surfaces, internal dividers, and one
  expressive outer shape without changing their controls or persisted state.
- Runtime locale detection, regional fallback, live catalog reload, and
  translation validation support incremental community localization.
- Dashboard media progress uses a determinate Material Expressive wavy
  indicator driven by the existing MPRIS position and playback state.
- The unified control center expands when screen space permits and preserves
  comfortable card gaps, content insets, and complete Daily Controls content
  through its responsive scale policy.
- Responsive policies are covered at 1920, ultrawide, compact-desktop, narrow,
  and very narrow widths; centered context never overlaps asymmetric clusters.
- Schema v4 bar preferences migrate to schema v5 without losing valid
  left/right widget ordering or existing shell preferences; retired bar keys
  are ignored safely.
- Privacy and keyboard-layout indicators remain hidden until their native
  event sources can be validated.

## Open follow-ups

1. [x] Add event-reduction and reconnection tests.
2. [ ] Validate backlight and battery behavior on a laptop.
3. [ ] Validate overlay hotplug behavior with two physical outputs.
4. [x] Select the project license.
5. [ ] Begin the 0.7 extended-beta work.

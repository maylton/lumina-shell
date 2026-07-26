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
- [x] Configurable weather location and refresh behavior.
- [x] Wi-Fi, wired-network, and Bluetooth management split into focused subpages with bounded lists.
- [x] Bottom application drawer with pinned applications, a complete app grid, and localized search results.

## 0.7 — Extended Beta

- [ ] Secure session lock.
- [x] Optional dock with floating and task-panel presentation.
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

This sprint completes the 0.5 public-beta foundation and begins the first 0.7 surface:

1. Graphical configuration with schema v8 persistence and safe schema
   v3/v4/v5/v6/v7 migration.
2. Automatic backup and recovery for invalid configuration.
3. Safe managed installation and removal.
4. Native environment and service diagnostics.
5. Keyboard, focus, and assistive-technology metadata baseline.
6. User, installation, compatibility, and contributor documentation.
7. Lumina's Material Expressive bar refinement with schema v7 migration,
   per-output context, active-widget management, individual widget settings,
   independent background, responsive content scaling, and edge-to-edge or
   floating geometry.
8. Maintained Brazilian Portuguese catalog with localized Dashboard and
   Launcher surfaces and explicit product terminology.
9. Weather settings with optional display, GeoIP or manual-city location,
   feature-scoped persistence, expiring coordinate cache, and selectable
   refresh intervals.
10. Connectivity settings with focused Wi-Fi, wired-network, and Bluetooth
    subpages, bounded independently scrollable lists, service-owned Wi-Fi
    discovery and connection, saved-profile and wired-profile management,
    bounded Bluetooth discovery, pairing, connection, and removal, and
    section-scoped refreshes.
11. Optional per-output application dock with a compact floating mode, a
    full-width task-panel mode with centered icons, Niri window grouping,
    pinned desktop entries, auto-hide, click-through masking, shell-surface
    styling, and feature-scoped persistence.
12. Aluminium-inspired bottom Launcher drawer with a visual handle, Dock
    favorites, a complete application grid, localized Niri actions, and a
    detailed search-result mode for applications, windows, and shell actions.

### Acceptance criteria

- `qs -p .` starts without a fatal QML error.
- The bar shows the workspaces belonging to each output.
- Workspace clicks switch to the requested workspace.
- Window title and app ID update when the active window changes.
- The column indicator updates when focus moves between columns or stacked tiles.
- Output name, resolution, and scale match `niri msg --json outputs`.
- Opening and closing the overview updates the bar state.
- Disconnecting and reconnecting the event stream does not leave stale state.
- No visual component invokes `niri msg` or daily-integration commands directly.
- Only one full-screen interactive overlay is active at a time.
- An unavailable target output falls back to a connected output.
- Missing batteries or backlights degrade to an unavailable state.
- Daily-control IPC status endpoints reflect the native services.
- Invalid JSON is preserved before defaults are restored.
- Install and uninstall scripts reject unsafe or unmanaged targets.
- Primary exclusive surfaces support keyboard dismissal and traversal.
- Dashboard and graphical settings share one overlay, service layer, and
  persistent configuration store.
- Graphical settings provide twelve keyboard-accessible categories, direct IPC
  navigation, scoped reset where supported, and debounced save feedback.
- Lumina's Material Expressive bar is the only bar layout and supports both
  edge-to-edge and floating surfaces.
- The default edge-to-edge bar uses a substantial 56-pixel surface, clear
  clock/date hierarchy, and expressive workspace state without shrinking
  interaction targets.
- Primary shell surfaces support Solid, Android-inspired Blur, and Frosted
  Glass independently of the bar. Blur remains clean and grain-free; Frosted
  adds a richer tint, directional highlight, and subtle static texture. Both
  request native blur only inside their rounded panel bounds, while semantic
  cards and controls remain opaque.
- The bar supports solid, translucent, blur, frosted-glass, and transparent
  backgrounds independently of shell surface style. Only Blur and
  Frosted request native Niri blur, bounded to the visible rounded surface;
  Translucent is alpha-only, children remain opaque, and all modes reserve work
  area while the wallpaper continues beneath the transparent surface.
- Android-inspired bounded background blur keeps clean Blur grain-free,
  preserves Frosted as a richer style, exposes no fake compositor controls,
  remains readable without rendered blur, and offers opt-in xray/live Niri
  profiles without editing the user's configuration.
- Bar height spans 40–80 pixels; automatic scaling uses the direct
  `barHeight / 56` ratio for widget geometry, icons, type, spacing, and shapes,
  while bounded manual scaling and small safety floors preserve a single-line
  layout.
- Workspace, date/time, Niri context, system status, notification, tray, and
  Dashboard clusters remain single-line and output-aware.
- Circular bar controls morph into rounded squircles for pressed and expanded
  states, return to true circles at rest, and honor the shared reduced-motion
  behavior without changing their hit targets.
- Circular Dashboard and Settings actions use the same state model for
  pressed, checked, and selected states while component-specific controls keep
  their own Material shapes.
- Every supported bar widget owns normalized individual presentation settings,
  including its resting background where applicable, while workspace state
  pills continue to communicate focused and active navigation.
- Bar settings list only active widgets under Left, Center, and Right; removed
  widgets move to an Add widgets menu, active-only reordering preserves hidden
  order, and each gear opens one keyboard-accessible internal settings dialog
  with a scoped reset.
- System tray items can be grouped in a compact popover or kept visible
  inline, and notifications use a compact stateful icon with an unread badge.
- Network and volume text can be hidden independently without disabling their
  status icons, services, tooltips, or Dashboard access.
- Laptop battery status uses a proportional rounded indicator without embedded
  text, with optional percentage or power state beside the icon and correct
  charging versus discharging semantics.
- The final right-side Dashboard entry uses the detected account avatar with
  AccountsService, `.face`, custom-image, initials, and Lumina fallbacks; its
  image can be disabled without removing the button or session access.
- Bar, Dashboard, and Settings distinguish spatial shape/bounds transitions
  from color/opacity effects, share semantic spacing roles, and remove
  expressive overshoot when reduced motion is enabled.
- Related Settings rows share tonal group surfaces, internal dividers, and one
  expressive outer shape without changing their controls or persisted state.
- Settings sliders separate active and inactive tracks with a stable gap around
  the Material handle at intermediate and endpoint values.
- Dashboard volume, microphone, and brightness sliders use the same Material 3
  track gap, small inner track corners, fully rounded outer ends, vertical
  handle, endpoint-safe geometry, and stop indicator while preserving pointer,
  keyboard, and service interactions.
- Explicit Light and Dark modes own complete, contrast-tested tonal schemes;
  wallpaper-derived color stores both variants and switches modes without
  retaining colors from the previous scheme.
- Settings combo rows open real Material dropdown menus with selected state,
  bounded placement, outside dismissal, and keyboard navigation.
- Runtime locale detection, regional fallback, live catalog reload, and
  translation validation support incremental community localization.
- Brazilian Portuguese is a maintained complete catalog for all extracted
  message IDs; Dashboard remains Dashboard, and localized Settings surfaces
  update through the runtime catalog without changing persisted IDs.
- Weather can be disabled without background requests; automatic mode resolves
  an approximate city from the public IP without storing the IP, caches only
  city/region/coordinates for 24 hours, and falls back to a manually entered
  city with 15–120 minute refresh choices.
- The Connectivity category keeps Wi-Fi, wired networking, and Bluetooth in
  separate internal subpages; nearby networks, saved profiles, and Bluetooth
  device groups use bounded lists, and only the selected integration receives
  detailed periodic refreshes. Visual QML does not run commands. Password-
  protected Wi-Fi uses a temporary `0600` secret file passed to NetworkManager
  and removes it after the attempt.
- The optional dock is disabled by default and appears per output when enabled.
  Floating mode sizes the surface to its content; task-panel mode spans the
  output while keeping icons centered. Both modes group Niri windows by app ID,
  launch pinned desktop entries, cycle existing windows, follow Solid/Blur/
  Frosted shell styling, keep transparent regions click-through, and bound long
  application lists with horizontal scrolling.
- Dock auto-hide uses a bottom-edge reveal region and a delayed collapse.
  Workspace reservation is applied only while the dock is always visible and
  includes any bottom-bar offset.
- The Launcher opens as a centered bottom drawer above the bottom bar or Dock,
  displays Dock favorites and an alphabetic application grid when idle, and
  switches to localized application/window/action results while searching.
  Right-click pinning uses the same explicit context menu in all Launcher modes.
- Dashboard media progress uses a determinate Material Expressive wavy
  indicator driven by the existing MPRIS position and playback state.
- The unified control center expands when screen space permits and preserves
  comfortable card gaps, content insets, and complete Daily Controls content
  through its responsive scale policy.
- Responsive policies are covered at 1920, ultrawide, compact-desktop, narrow,
  and very narrow widths; centered context never overlaps asymmetric clusters.
- Schema v4 bar preferences migrate through schema v5, schema v6, and
  schema v7 into schema v8 without losing valid widget ordering, visibility,
  shell style, or existing preferences; legacy global transparency becomes
  bounded Blur and retired keys are ignored safely after migration.
- Privacy and keyboard-layout indicators remain hidden until their native
  event sources can be validated.

## Open follow-ups

1. [x] Add event-reduction and reconnection tests.
2. [ ] Validate backlight and battery behavior on a laptop.
3. [ ] Validate overlay hotplug behavior with two physical outputs.
4. [x] Select the project license.
5. [ ] Continue the 0.7 extended-beta work.
6. [ ] Continue extracting hard-coded English from notifications, session,
   wallpaper, calendar, OSD, and the remaining Settings pages.
7. [ ] Validate GeoIP/manual weather switching and cache fallback on the native
   runtime.
8. [ ] Validate protected Wi-Fi, saved-profile, wired-profile, and Bluetooth
   pairing flows against physical hardware and the active system agents.
9. [ ] Add advanced NetworkManager editing for static IP, DNS, IPv6, VPN,
   hotspot, and 802.1X only after the basic management flow is stable.
10. [ ] Validate floating/task-panel switching, multi-output geometry, auto-hide,
    click-through masking, bottom-bar coexistence, window cycling, and workspace
    reservation on the native Niri runtime.
11. [ ] Validate the Launcher drawer geometry, pinned row, app-grid scrolling,
    keyboard navigation, and localized search results on the native runtime.

# Changelog

All notable changes to Lumina Shell will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project intends to use Semantic Versioning once public releases begin.

## [Unreleased]

### Added

- Added an Aluminium-inspired bottom application drawer with a visual handle,
  rounded search field, reactive Dock favorites, a complete application grid,
  detailed search results for applications, Niri windows, and shell actions,
  and shared right-click Pin/Unpin menus.
- Added an optional per-output application dock with a compact floating mode and
  a full-width task-panel mode with centered icons. Both presentations support
  pinned desktop entries, grouped Niri windows, focus cycling, auto-hide,
  click-through masking, optional workspace reservation, horizontal overflow,
  and the shared Solid, Blur, and Frosted Glass shell styles.
- Added dedicated Weather settings with enable/disable behavior, approximate
  GeoIP location, manual-city lookup, feature-scoped persistence, a 24-hour
  coordinate cache, selectable refresh intervals, and immediate refresh.
- Added a Connectivity settings page for Wi-Fi discovery and connection, saved
  NetworkManager profiles, wired profiles, bounded Bluetooth discovery,
  pairing, connection, and removal.
- Added a reusable settings text-field row plus tested weather-preference and
  connectivity-command parsing helpers.
- Added service-owned protected Wi-Fi handling with a temporary `0600` secret
  file passed to NetworkManager and removed after the connection attempt.
- Added independent Solid, Android-inspired Blur, and Frosted Glass styles for
  primary shell surfaces. Blur is bounded to each rounded panel, Frosted adds a
  restrained highlight and static grain, and inner semantic content remains
  opaque.
- Initial Quickshell project skeleton.
- Minimal multi-output top bar.
- Foundation design tokens.
- Environment diagnostic script.
- Niri-first project roadmap and contribution guide.
- Native PipeWire audio and microphone controls.
- Optional display brightness service with safe no-device fallback.
- UPower battery and power-profile integration.
- Native MPRIS media controls.
- NetworkManager and BlueZ connectivity status.
- Volume, brightness, and lock-state OSDs.
- Material Expressive per-output control center.
- Graphical settings for appearance, OSD, notifications, and wallpapers.
- Schema v3 persistence with invalid-JSON backup and recovery.
- Safe managed install and uninstall scripts.
- Expanded Niri and daily-service environment diagnostics.
- Keyboard navigation and Qt accessibility metadata baseline.
- Installation, user, accessibility, and contributor documentation.
- Centered control-center dashboard with overview, notification, media, status, control, and calendar cards.
- Optional Open-Meteo conditions and daily temperature range in the dashboard.
- Automatic dashboard identity from the session user and `/etc/os-release`.
- Automatic MPRIS playing, paused, and idle-state presentation.
- Tested Niri event reduction with stale-state clearing, bounded reconnect backoff, and initial-state synchronization.
- GPL-3.0-or-later project licensing with explicit third-party credits and contribution terms.
- Unified Dashboard and Shell Settings views with direct category navigation
  and no duplicate overlay state.
- Material Expressive settings sidebar with twelve categories, reusable
  accessible controls, light/dark previews, and local Edit config actions.
- Schema v4 persistence with debounced save status, category reset, schema v3
  migration, validation clamps, and serialization tests.
- Live appearance, bar, dashboard, notification, OSD, and session preferences,
  plus local system diagnostics and project information.
- Nine persistent wallpaper-derived Material palette profiles with live
  previews and IPC selection.
- Expanded Material 3 shape tokens and expressive settings containment,
  selection pills, switches, sliders, and pressed-state shape motion.
- Wallpaper-derived neutral and neutral-variant tonal roles for shell
  surfaces, containers, text, and outlines.
- Schema v5 Material Expressive bar preferences with safe schema-v4 migration
  and normalized left/right widget orders.
- Composable Material Expressive bar with edge-to-edge and floating geometry,
  transforming workspaces,
  localized date/time, per-output contextual Niri capsule, real system-status
  services, dedicated Dashboard access, and responsive optional actions.
- Expanded Bar settings with surface/context/status controls,
  optional actions, accessible ordering, and immediate persistence.
- Consistent semantic spacing between the bar and calendars, tray popups,
  notifications, and the unified control-center surface on either edge.
- Palette-aware rocket glyph for the unified Dashboard and Settings entry
  point in the desktop bar and the Dashboard tab.
- Theme-independent gear glyphs for Settings navigation and its dashboard
  shortcut, optically scaled to match adjacent icons.
- Configurable system tray presentation with a compact grouped popover or
  always-visible inline icons.
- Compact notification bell with unread badge, Do Not Disturb state, tooltip,
  and accessible status.
- Persistent Bar settings to hide network and volume text independently while
  preserving their status icons and interactions.
- Schema v6 bar appearance preferences with safe schema-v5 migration,
  independent background mode and opacity, automatic height-derived content
  scaling, and bounded manual scaling.
- Solid, Translucent, Blur, Frosted Glass, and Transparent bar backgrounds
  that keep child widgets and popup surfaces fully opaque. Translucent is an
  alpha-only tonal surface; only Blur and Frosted request Niri's native shaped
  layer-shell effect. Schema-6 `translucent` preferences retain their
  historical Blur meaning during migration.
- Optional namespace-scoped Niri profiles for efficient xray or normal/live
  blur, validated against Niri 26.04 without forcing blur or modifying the
  user's compositor configuration.
- Persistent global control for resting bar-widget pill backgrounds, covering
  launcher, overview, date/time, context, tray, notifications, system status,
  Dashboard, wallpaper, and session actions while preserving interactive and
  semantic feedback. Workspace pills remain visible because they communicate
  focused and active navigation state.
- Account-backed user avatar as the final Dashboard entry point, shared with
  the welcome card and resolved through AccountsService, `.face`, an optional
  custom image, initials, and a Lumina fallback. Dashboard settings can
  disable profile images without removing the entry point.
- The wallpaper surface now ignores shell exclusion zones, allowing Transparent
  bars to reserve work area without exposing a compositor-colored strip or
  placing tiled windows behind bar controls.
- Schema v7 individual bar-widget settings with safe schema-v6 migration,
  strict nested normalization, immutable updates, scoped widget reset, and
  preservation of existing visibility and order.
- A central bar-widget catalog plus active-only Left, Center, and Right
  management. Removed widgets move to a bounded Add widgets menu and retain
  their settings.
- Internal Material Expressive settings dialogs for launcher, overview,
  workspaces, date/time, context, tray, notifications, system status, user
  avatar, wallpaper, and session widgets.
- Android-inspired expressive battery status icon with proportional fill,
  external charging bolt, low-level color state, and optional percentage or
  power-state text beside the icon.

### Changed

- Completed Brazilian Portuguese coverage for Launcher result kinds, Niri action
  names and descriptions, open-window fallbacks, and Settings restart feedback.
- Launcher browsing now uses a centered app grid while typed queries retain the
  detailed application/window/action result list and keyboard navigation.
- Pointer activation in the Dock and graphical Settings now clears transient
  focus after the action, so keyboard-focus outlines remain specific to Tab
  navigation. Widget dialogs restore their source focus only when opened from
  the keyboard, and the Dock Launcher grid now uses a neutral foreground color.
- Weather no longer infers a city from the system timezone. Automatic mode now
  resolves an approximate city from the public IP and never stores the IP.
- Refined the bar into Android-inspired bounded background blur adapted to
  Lumina and Niri: clean Blur uses neutral tint and contrast protection,
  Frosted Glass retains restrained highlight and static grain, and all modes
  animate client layers without changing compositor blur radius.
- Removed the avatar-only color ring and image-shape morph from the bar entry
  point. The account picture stays circular while the shared button container
  owns hover, focus, pressed, and open states like adjacent bar widgets.
- Simplified Bar settings to global surface controls followed by active widget
  rows with configure, reorder, and remove actions. Hidden widgets no longer
  occupy the main list or make reorder controls skip.
- Replaced the global widget-background switch with per-widget presentation,
  and added real service-backed text modes for network, audio, and battery.
- Extended state-aware circle-to-squircle morphs to circular Dashboard actions,
  selected calendar days and navigation, and Settings widget-order controls,
  while leaving non-circular and component-specific shapes unchanged.
- Added Material Expressive state morphs to circular bar controls: launcher,
  overview, notifications, grouped tray, and Dashboard avatar now transition
  from circles to rounded squircles while pressed or expanded; inline tray
  actions morph only for the duration of the press.
- Increased the notification bell's optical size through a dedicated
  height-scaled bar token so its glyph matches adjacent controls without
  changing the shared circular target.
- Enforced true 1:1 circular geometry for icon-only bar controls, including
  launcher, overview, tray, notifications, and the user avatar, without
  changing stateful workspace or information capsules.
- Made automatic bar sizing fully proportional to its 56-pixel reference:
  widget surfaces, icons, typography, spacing, badges, context thresholds, and
  expressive radii now follow `barHeight / 56` across the 40–80 pixel range,
  with narrow safety floors at the smallest sizes.
- Increased the preferred unified control-center surface, card gaps, content
  insets, and Dashboard action targets; rebalanced the left column so Daily
  Controls no longer clips its power-profile actions.
- Replaced the Dashboard media player's flat progress bar with a determinate
  Material Expressive wavy indicator, including active/track gap, shrinking
  stop indicator, slower playback motion, a smooth play/pause waveform morph,
  and reduced-motion handling.
- Split shell motion into semantic spatial and effects families, with
  coordinated shape/bounds transitions, short state effects, and an
  overshoot-free reduced-motion path.
- Refined bar motion and spacing across workspaces, context, date/time, tray,
  notifications, system status, and Dashboard entry without changing their
  services or interactions.
- Added directional Dashboard/Settings and settings-category transitions, a
  shared moving tab indicator, persistent category instances, and consistent
  card, section, item, and content spacing.
- Grouped related Settings rows into shared tonal surfaces with subtle internal
  dividers and one expressive outer contour.
- Moved section-level segmented selectors outside row groups and replaced
  full-row hover fills with inset state layers that preserve the outer contour.
- Split Settings slider tracks around the Material handle with a semantic gap
  and endpoint-safe, tested geometry.
- Restyled Dashboard volume, microphone, and brightness sliders with Material
  3 active/inactive tracks, a vertical handle, stable gap, stop indicator, and
  shared endpoint-safe geometry.
- Refined slider tracks with small handle-facing corners and fully rounded
  outer endpoints across Dashboard and Settings.
- Rendered Material slider segments as single contours to remove dark overlap
  artifacts from disabled Settings sliders.
- Added a complete contrast-tested Light tonal scheme while preserving the
  validated Dark palette, and made wallpaper-derived palettes retain separate
  reactive Light and Dark variants.
- Added semantic light-theme surface, outline, primary, error, and state-layer
  roles; previews and selected/destructive states now consume those roles
  without dark-theme-specific hardcoded overlays.
- Added a typed `config theme` IPC action for Light, Dark, and Auto mode
  switching and runtime validation.
- Replaced cyclic Settings combo controls with real Material dropdown menus,
  including selected state, viewport-aware placement, outside dismissal, and
  complete keyboard navigation.
- Added runtime JSON internationalization with automatic locale selection,
  regional fallback, English and Brazilian Portuguese catalogs, live reload,
  contributor validation, and initial Control Center/Settings coverage.
- Reworked the notification center with adaptive height, lighter scrim,
  hierarchical header controls, an expressive empty state, and contained
  notification cards.
- Launcher search no longer truncates application catalogs and broad queries
  to the first 12 ranked results.
- Pointer activation no longer leaves a keyboard-focus outline on bar buttons
  after their panel or popup closes.
- Raised the default edge-to-edge bar to 56 pixels with 40-pixel interaction
  targets, stronger clock hierarchy, lighter inactive workspaces, and a more
  restrained edge divider.
- Split centered Niri context into primary and secondary information, bounded
  it against asymmetric side clusters, and refined responsive visibility at
  desktop, ultrawide, and narrow widths.
- Added expressive shape transitions to grouped system status, notifications,
  and Dashboard controls while retaining the global reduced-motion policy.
- Removed the legacy alternate bar layout, preset selector, preview, and
  persisted style/single-order state. Lumina's Material Expressive bar is now
  the sole implementation while retaining edge-to-edge and floating modes.
- Preserve left/right widget ordering when JsonAdapter exposes persisted
  arrays as QML sequence values.
- Scale Material Expressive bar icons, typography, workspace states, status
  badges, padding, gaps, and interaction targets semantically across 40–80
  pixel heights while retaining a moderate compact-density adjustment.
- Show the effective automatic content scale while keeping manual adjustments
  on clear five-percent steps.

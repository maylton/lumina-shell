# Changelog

All notable changes to Lumina Shell will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project intends to use Semantic Versioning once public releases begin.

## [Unreleased]

### Added

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
- Volume, microphone, brightness, and lock-state OSDs.
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
- Material Expressive settings sidebar with nine categories, reusable
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

### Changed

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

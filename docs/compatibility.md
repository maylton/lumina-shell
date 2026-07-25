# Compatibility

Lumina Shell is currently developed and validated against a Niri-first CachyOS environment.

## Validated native combination

Validated on 2026-07-24:

- CachyOS running Niri natively;
- Niri `26.04` (`8ed0da4`);
- `noctalia-qs 0.0.12` (`76c13298a1a3daf54f5e63db3aad3e71228e5d2c`);
- Wayland session with `$NIRI_SOCKET` available.

## Development host

The runnable foundation was also exercised with standard Quickshell `0.3.0` on a KDE Wayland development host. Native Niri behavior remains the release gate for compositor integrations.

## System tray menus

The `noctalia-qs 0.0.12` StatusNotifierItem API exposes dynamic items, activation, scrolling, tooltips, and DBus menus. Lumina renders menu entries through the fork's `QsMenuOpener` API so buttons, tooltips, and menus share the same design tokens.

Nested entries are presented as expandable sections inside the same popup instead of separate cascading windows. This avoids extra Wayland popup surfaces while preserving access to submenu actions.

## Notification service ownership

Only one process can own `org.freedesktop.Notifications` in a user session. When Noctalia is already running its notification daemon, Lumina logs the Quickshell registration warning and waits for the D-Bus name to become available. It does not terminate or replace the existing daemon.

Lumina's daemon, popup queue, history, actions, and Do Not Disturb behavior were validated on an isolated session bus so the normal Noctalia session did not need to be interrupted.

## Session controls

Session actions use tools already present in the validated CachyOS environment:

- `loginctl lock-session` for lock requests;
- `systemctl suspend`, `reboot`, and `poweroff` for system state;
- Niri's `quit --skip-confirmation` action after Lumina's own confirmation.

The session locker itself remains an external session responsibility until Lumina's secure-lock roadmap item is implemented.

## Multi-output validation

Per-output surface selection, exclusive overlay coordination, and fallback from an unavailable output name were validated on the active `DP-1` output. The bar, wallpaper, and overlay delegates all derive their geometry from `Quickshell.screens`.

Lumina's Material Expressive bar keeps workspace, active-window context,
context timeout, calendar, and Dashboard targeting inside each output
delegate. The same layout supports edge-to-edge and floating geometry on the
top or bottom edge. Disconnect handling is implemented for active overlays,
notification popups, calendars, context timers, and persisted wallpaper
mappings. A native hotplug transition across two physical outputs remains an
explicit compatibility follow-up.

The active host provides one 3440×1440 output. Compact breakpoints and
non-overlap behavior are implemented for narrower logical widths, but
1920×1080, mixed-scale, and two-physical-output visual passes remain native
validation items.

## Daily controls

The validated desktop exposes PipeWire output and input devices, the power-profiles daemon, a wired NetworkManager connection, a Wi-Fi adapter, a BlueZ adapter, and an MPRIS Chrome player. Lumina reads and controls these through the corresponding native Quickshell APIs.

This host has no laptop battery or `backlight` class device. Both capabilities correctly render as unavailable; physical percentage changes and charging transitions remain laptop validation follow-ups. `BrightnessService` restricts `brightnessctl` to the `backlight` class so keyboard LEDs can never be mistaken for a display.

The `noctalia-qs 0.0.12` networking model does not type the active wired device in `Networking.devices`. Lumina therefore uses the native global connectivity state as the wired fallback when no Wi-Fi network is active.

## Weather

The optional weather card uses `curl` to query Open-Meteo geocoding and forecast endpoints without an API key. By default, Lumina derives a city from the system timezone through `timedatectl`; `LUMINA_WEATHER_LOCATION` overrides that query when the timezone city is not precise enough. Network, geocoding, and command failures leave the rest of the dashboard available.

## Appearance and configuration

`noctalia-qs 0.0.12` does not expose a stable system color-scheme preference
used by Lumina. `themeMode: "auto"` therefore has a documented dark fallback;
explicit Light and Dark use complete semantic token sets. Dynamic wallpaper
colors continue to provide accent roles in either mode.

Transparency changes semantic surface alpha directly. Blur and Frosted Glass
bar modes use Niri 26.04's native `ext-background-effect` support through the
Quickshell `BackgroundEffect` region API. Frosted Glass adds a local tonal
tint, edge highlight, and subtle grain; the available client API does not
change Niri's compositor-wide blur algorithm. Disabling animations or
enabling reduced motion preserves focus feedback while minimizing transition
duration.

The bar has a separate schema-v6 background policy. Solid, Blur, Frosted
Glass, and Transparent alter only `BarSurface`; Dashboard, Settings, bar
children, calendars, and tray popups do not inherit `barSurfaceOpacity` or
the bar blur region. All modes retain the full layer-shell exclusive zone.
The Lumina wallpaper surface explicitly ignores exclusion zones, so it still
covers the output behind a Transparent bar while tiled windows remain outside
the bar area.
Automatic content scale is implemented semantically for 40–80 logical-pixel
heights, not as a global transform.
Native visual passes for every height/mode combination at 1920×1080,
mixed-scale, and multi-output configurations remain explicit follow-ups.

Local System/About actions resolve project files from `LUMINA_ROOT`, or the
shell process working directory. Installed packages should set `LUMINA_ROOT`
when they launch Lumina outside its installation directory.

## Keyboard layout and privacy status

Niri 26.04 does not expose a stable keyboard-layout event in the state stream
consumed by Lumina. The validated noctalia-qs 0.0.12 runtime also does not
provide a reliable camera, screen-capture, or recording usage source for this
bar. The components and ordering slots exist, but stay invisible; Lumina does
not poll shell commands or treat an unmuted microphone as “in use.”

## Configuration recovery

Schema v3/v4-to-v5 and v5-to-v6 migration, retired bar-key handling,
normalization, serialization, scoped reset, widget-order deduplication,
bar-scale policy, surface-alpha policy, and malformed-JSON recovery are
covered by isolated tests. Invalid source is preserved at the adjacent
`.invalid` path before defaults are written atomically.

## Accessibility validation

Primary controls expose Qt accessibility metadata and keyboard actions. Runtime surface traversal was validated without QML errors. A screen-reader-specific pass and laptop keyboard/backlight pass remain compatibility follow-ups.

## Compatibility policy

- The JSON IPC is treated as append-only: unknown fields and event variants must be ignored gracefully.
- Visual modules must remain compatible with the CachyOS `noctalia-qs` runtime used by the native test environment.
- New Niri or Quickshell versions are not marked supported until the shell starts, renders its surfaces, and passes the relevant interaction checks.

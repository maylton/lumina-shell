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

## Compatibility policy

- The JSON IPC is treated as append-only: unknown fields and event variants must be ignored gracefully.
- Visual modules must remain compatible with the CachyOS `noctalia-qs` runtime used by the native test environment.
- New Niri or Quickshell versions are not marked supported until the shell starts, renders its surfaces, and passes the relevant interaction checks.

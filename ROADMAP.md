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

- [x] Repository and Quickshell project foundation.
- [x] Reactive Niri IPC state and multi-output shell surfaces.
- [x] Material Expressive design system and dynamic wallpaper color.
- [x] Bar, Dashboard, Launcher, notifications, OSD, wallpaper, and session surfaces.
- [x] Daily audio, brightness, power, media, network, and Bluetooth integrations.
- [x] Graphical settings with persistent schema migration and recovery.
- [x] Bounded native Niri blur and frosted shell-surface styles.
- [x] English and maintained Brazilian Portuguese catalogs.
- [x] Weather settings with GeoIP fallback, manual city, cache, and refresh control.
- [x] Connectivity settings split into Wi-Fi, wired, and Bluetooth subpages with bounded lists and section-scoped refreshes.
- [ ] Native laptop battery and backlight validation.
- [ ] Native dual-output hotplug validation.
- [ ] Advanced NetworkManager editing for static IP, DNS, IPv6, VPN, hotspot, and 802.1X.

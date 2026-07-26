# Lumina Shell

Lumina Shell is a Niri-first desktop shell for Wayland, built with Quickshell and QML and guided by Material 3 Expressive design principles.

> Status: public-beta foundation. The 0.2 through 0.5 milestones are implemented; extended-beta work is next.

## Goals

- Deep integration with Niri's scrolling layout, vertical workspaces, columns, outputs, and overview.
- A modular Material Expressive interface for the bar, launcher, control center, notifications, OSD, wallpaper, and settings.
- Event-driven state, predictable fallbacks, keyboard accessibility, and multi-monitor support from the beginning.

## Initial stack

- Niri
- Official Quickshell
- QML / Qt Quick
- Rust later, only where a separate backend is justified

## Requirements

Install the base tools on CachyOS or Arch Linux:

```bash
sudo pacman -S --needed \
    git \
    niri \
    quickshell \
    qt6-declarative \
    python-dbus-next
```

`python-dbus-next` is used by Lumina's BlueZ `org.bluez.Agent1` bridge for PIN, passkey, service authorization, and numeric-comparison confirmation dialogs.

## Run from a checkout

```bash
git clone https://github.com/maylton/lumina-shell.git
cd lumina-shell
qs -p .
```

The shell opens a top panel and wallpaper surface on every detected output. It includes reactive Niri state, launcher search, notifications, calendar and tray widgets, daily controls, per-output wallpapers, dynamic color, layout actions, and confirmed session controls.

Validate all native integrations:

```bash
./scripts/check-environment.sh --require-niri --require-daily
```

Install or preview a managed Quickshell copy:

```bash
./scripts/install.sh --dry-run
./scripts/install.sh
```

## Development status

Current completed milestones: **0.2 — Daily Controls**, **0.3 — Interactive Alpha**, **0.4 — Desktop Alpha**, and **0.5 — Public Beta**

The current implementation includes:

1. A typed, event-driven Niri service and reactive compositor stores.
2. Per-output bars, wallpapers, and coordinated interactive overlays.
3. Application, window, and shell-action search.
4. Notification history, Do Not Disturb, and wallpaper-derived colors.
5. Advanced layout actions and confirmed session controls.
6. PipeWire, MPRIS, UPower, NetworkManager, and BlueZ daily controls.
7. Per-output OSDs and a Material Expressive control center.
8. Graphical settings, safe configuration recovery, and managed installation tooling.

See [ROADMAP.md](ROADMAP.md) for the complete plan and [CONTRIBUTING.md](CONTRIBUTING.md) for the workflow.

Documentation:

- [Installation](docs/installation.md)
- [User guide](docs/user-guide.md)
- [Architecture](docs/architecture.md)
- [Compatibility](docs/compatibility.md)
- [Accessibility](docs/accessibility.md)
- [Performance diagnostics](docs/performance.md)
- [Translations](docs/translations.md)

## Repository structure

```text
lumina-shell/
├── shell.qml
├── design/
├── modules/
├── services/
├── stores/
├── i18n/
├── docs/
├── scripts/
└── ROADMAP.md
```

## License

Copyright © 2026 Maylton and Lumina Shell contributors.

Lumina Shell is free software licensed under the [GNU General Public License version 3 or later](LICENSE), identified by SPDX as `GPL-3.0-or-later`.

See [CREDITS.md](CREDITS.md) for the licenses of runtime components and the projects used as architectural or design references.

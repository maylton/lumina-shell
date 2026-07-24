# Lumina Shell

Lumina Shell is a Niri-first desktop shell for Wayland, built with Quickshell and QML and guided by Material 3 Expressive design principles.

> Status: interactive desktop alpha. The 0.3 and 0.4 shell surfaces are implemented; daily controls from 0.2 remain open.

## Goals

- Deep integration with Niri's scrolling layout, vertical workspaces, columns, outputs, and overview.
- A modular Material Expressive interface for the bar, launcher, control center, notifications, OSD, wallpaper, and settings.
- Event-driven state, predictable fallbacks, keyboard accessibility, and multi-monitor support from the beginning.

## Initial stack

- Niri
- Quickshell
- QML / Qt Quick
- Rust later, only where a separate backend is justified

## Requirements

Install the base tools on CachyOS or Arch Linux:

```bash
sudo pacman -S --needed git niri quickshell qt6-declarative
```

## Run from a checkout

```bash
git clone https://github.com/maylton/lumina-shell.git
cd lumina-shell
qs -p .
```

The shell opens a top panel and wallpaper surface on every detected output. It includes reactive Niri state, launcher search, notifications, calendar and tray widgets, per-output wallpapers, dynamic color, layout actions, and confirmed session controls.

## Development status

Current completed milestones: **0.3 — Interactive Alpha** and **0.4 — Desktop Alpha**

The current implementation includes:

1. A typed, event-driven Niri service and reactive compositor stores.
2. Per-output bars, wallpapers, and coordinated interactive overlays.
3. Application, window, and shell-action search.
4. Notification history, Do Not Disturb, and wallpaper-derived colors.
5. Advanced layout actions and confirmed session controls.

See [ROADMAP.md](ROADMAP.md) for the complete plan and [CONTRIBUTING.md](CONTRIBUTING.md) for the workflow.

## Repository structure

```text
lumina-shell/
├── shell.qml
├── design/
├── modules/
├── services/
├── stores/
├── docs/
├── scripts/
└── ROADMAP.md
```

## License

The project license has not been selected yet. Do not copy or redistribute the source as an open-source package until a license is added.

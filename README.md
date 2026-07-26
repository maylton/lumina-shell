# Lumina Shell

Lumina Shell is a Niri-first desktop shell for Wayland, built with Quickshell and QML and guided by Material 3 Expressive design principles.

> Status: early foundation. The repository currently contains only the first runnable shell skeleton and project documentation.

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

The foundation build opens a top panel on every detected output and displays a clock. It intentionally does not start Niri IPC integration yet; that is the next development increment.

## Development status

Current milestone: **0.1 — Niri Foundation**

First implementation sequence:

1. Establish a runnable and modular Quickshell base.
2. Add a typed, event-driven Niri service.
3. Display workspaces and the focused window.
4. Introduce the first reusable Material Expressive components.

See [ROADMAP.md](ROADMAP.md) for the complete plan and [CONTRIBUTING.md](CONTRIBUTING.md) for the workflow.

## Repository structure

```text
lumina-shell/
├── shell.qml
├── design/
├── modules/
│   └── bar/
├── docs/
├── scripts/
└── ROADMAP.md
```

## License

The project license has not been selected yet. Do not copy or redistribute the source as an open-source package until a license is added.

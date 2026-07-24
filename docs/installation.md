# Installation

Lumina Shell targets CachyOS and Arch Linux with Niri and the validated `noctalia-qs` runtime.

## Dependencies

The minimum runtime is:

```bash
sudo pacman -S --needed git niri qt6-declarative
```

Install a compatible Quickshell package that provides `qs`. The native validation environment uses `noctalia-qs 0.0.12`.

Daily controls use these services when available:

```bash
sudo pacman -S --needed \
    brightnessctl \
    pipewire \
    wireplumber \
    upower \
    power-profiles-daemon \
    networkmanager \
    bluez \
    bluez-utils
```

Missing batteries and display backlights are supported desktop configurations. Missing PipeWire, NetworkManager, BlueZ, or power-profile services disable only their corresponding controls.

## Validate the session

Run the complete native check inside Niri:

```bash
./scripts/check-environment.sh --require-niri --require-daily
```

Omit `--require-daily` when intentionally running a minimal environment.

## Run from the checkout

```bash
qs -p /path/to/lumina-shell
```

This is the recommended development workflow.

## Install

The installer copies the runnable tree into the Quickshell configuration directory and marks it as a managed installation:

```bash
./scripts/install.sh
qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/lumina-shell"
```

Preview the operation:

```bash
./scripts/install.sh --dry-run
```

Use a different absolute target when needed:

```bash
./scripts/install.sh --target /absolute/path/to/lumina-shell
```

Running the installer again updates an existing managed installation. It refuses to replace an unrelated directory unless `--force` is explicitly supplied.

## Uninstall

Preview and then remove the managed installation:

```bash
./scripts/uninstall.sh --dry-run
./scripts/uninstall.sh
```

The uninstaller verifies the management marker and refuses broad or unmanaged targets. Quickshell state is retained intentionally so reinstalling does not discard preferences or wallpaper assignments.

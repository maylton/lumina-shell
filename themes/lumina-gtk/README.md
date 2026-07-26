# Lumina GTK

Lumina GTK is the companion application theme for Lumina Shell. It translates the shell's Material 3 Expressive visual language to GTK 3, GTK 4, libadwaita-friendly applications, and sandboxed Flatpak applications.

## Design goals

- Keep native GTK behavior and accessibility intact.
- Reuse Lumina semantic color roles instead of hard-coded component colors.
- Use rounded, layered surfaces that visually match shell panels and widgets.
- Prefer subtle elevation and state layers over heavy borders.
- Support light and dark variants from the same token model.
- Avoid fragile application-specific selectors in the base theme.

## Current scope

This first phase provides:

- shared semantic color and geometry tokens;
- GTK 3 and GTK 4 CSS entrypoints;
- dark and light variants selected through generated token files;
- an installer for the user theme directory;
- Flatpak filesystem overrides so sandboxed applications can read the theme;
- a small theme switch helper based on `gsettings`.

## Layout

```text
lumina-gtk/
├── common/
│   ├── base.css
│   ├── colors-dark.css
│   └── colors-light.css
├── gtk-3.0/
│   └── gtk.css
├── gtk-4.0/
│   └── gtk.css
├── scripts/
│   ├── apply-theme.sh
│   └── install-theme.sh
└── index.theme
```

## Install and test

```bash
cd themes/lumina-gtk
bash scripts/install-theme.sh
bash scripts/apply-theme.sh dark
```

Use `light` instead of `dark` to switch variants.

## Flatpak notes

The installer grants Flatpak applications read-only access to the installed theme directory and exports `GTK_THEME=Lumina-Dark` or `Lumina-Light` through a per-user override. Some libadwaita applications intentionally limit full CSS theming; for those applications Lumina focuses on matching system colors, rounded geometry, and window chrome without replacing application-specific styling.

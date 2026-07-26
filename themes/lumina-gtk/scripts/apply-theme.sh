#!/usr/bin/env bash
set -euo pipefail

variant="${1:-dark}"

case "$variant" in
  dark)
    theme="Lumina-Dark"
    color_scheme="prefer-dark"
    ;;
  light)
    theme="Lumina-Light"
    color_scheme="prefer-light"
    ;;
  *)
    printf 'Usage: %s dark|light\n' "$0" >&2
    exit 2
    ;;
esac

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface gtk-theme "$theme"

  if gsettings writable org.gnome.desktop.interface color-scheme >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme "$color_scheme"
  fi
fi

if command -v flatpak >/dev/null 2>&1; then
  flatpak override --user --env=GTK_THEME="$theme"
fi

printf 'Applied %s for GTK and Flatpak applications.\n' "$theme"
printf 'Restart already-open applications to reload the theme.\n'

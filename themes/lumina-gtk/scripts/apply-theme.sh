#!/usr/bin/env bash
set -euo pipefail

variant="${1:-dark}"
THEMES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
LUMINA_CONFIG_DIR="$CONFIG_DIR/lumina-gtk"
BEGIN_MARKER="/* BEGIN LUMINA GTK MANAGED IMPORT */"
END_MARKER="/* END LUMINA GTK MANAGED IMPORT */"

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

if [[ ! -f "$THEMES_DIR/$theme/gtk-4.0/lumina-user.css" ]]; then
  printf 'Theme files are missing. Run install-theme.sh first.\n' >&2
  exit 1
fi

managed_import() {
  local gtk_version="$1"
  local source_css="$THEMES_DIR/$theme/$gtk_version/lumina-user.css"
  local managed_css="$LUMINA_CONFIG_DIR/$gtk_version.css"
  local user_dir="$CONFIG_DIR/$gtk_version"
  local user_css="$user_dir/gtk.css"
  local temporary
  local uri

  mkdir -p "$LUMINA_CONFIG_DIR" "$user_dir"
  cp "$source_css" "$managed_css"
  touch "$user_css"
  temporary="$(mktemp)"

  awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
    $0 == begin { managed = 1; next }
    $0 == end { managed = 0; next }
    !managed { print }
  ' "$user_css" > "$temporary"

  if command -v python3 >/dev/null 2>&1; then
    uri="$(python3 -c 'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_uri())' "$managed_css")"
  else
    uri="file://$managed_css"
  fi

  {
    cat "$temporary"
    printf '\n%s\n' "$BEGIN_MARKER"
    printf '@import url("%s");\n' "$uri"
    printf '%s\n' "$END_MARKER"
  } > "$user_css"

  rm -f "$temporary"
}

managed_import "gtk-3.0"
managed_import "gtk-4.0"

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface gtk-theme "$theme"
  gsettings set org.gnome.desktop.interface color-scheme "$color_scheme" 2>/dev/null || true
fi

if command -v flatpak >/dev/null 2>&1; then
  flatpak override --user --env=GTK_THEME="$theme"
  flatpak override --user --filesystem=xdg-config/gtk-3.0:ro
  flatpak override --user --filesystem=xdg-config/gtk-4.0:ro
  flatpak override --user --filesystem=xdg-config/lumina-gtk:ro
fi

printf 'Applied %s to GTK 3, GTK 4, libadwaita and Flatpak applications.\n' "$theme"
printf 'Close every Nautilus window and run: nautilus -q\n'
printf 'Then open Nautilus again to reload its stylesheet.\n'

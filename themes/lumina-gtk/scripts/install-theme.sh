#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
LEGACY_THEMES_DIR="$HOME/.themes"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

compile_css() {
  local target="$1"
  local gtk_version="$2"

  {
    cat "$target/common/colors.css"
    printf '\n'
    cat "$target/common/base.css"
    printf '\n'
    sed '1,2d' "$target/$gtk_version/gtk.css"
  } > "$target/$gtk_version/lumina-user.css"
}

install_variant() {
  local variant="$1"
  local palette="$2"
  local target="$THEMES_DIR/$variant"

  rm -rf "$target"
  mkdir -p \
    "$target/common" \
    "$target/assets" \
    "$target/gtk-3.0" \
    "$target/gtk-4.0"

  cp "$ROOT_DIR/common/base.css" "$target/common/base.css"
  cp "$ROOT_DIR/common/$palette" "$target/common/colors.css"
  cp "$ROOT_DIR/index.theme" "$target/index.theme"
  cp "$ROOT_DIR/assets/"*.svg "$target/assets/"

  sed 's#../common/colors-dark.css#../common/colors.css#' \
    "$ROOT_DIR/gtk-3.0/gtk.css" > "$target/gtk-3.0/gtk.css"
  sed 's#../common/colors-dark.css#../common/colors.css#' \
    "$ROOT_DIR/gtk-4.0/gtk.css" > "$target/gtk-4.0/gtk.css"

  compile_css "$target" "gtk-3.0"
  compile_css "$target" "gtk-4.0"

  sed -i "s/^Name=.*/Name=$variant/" "$target/index.theme"
  sed -i "s/^GtkTheme=.*/GtkTheme=$variant/" "$target/index.theme"
  sed -i "s/^MetacityTheme=.*/MetacityTheme=$variant/" "$target/index.theme"
}

mkdir -p "$THEMES_DIR" "$LEGACY_THEMES_DIR" "$CONFIG_DIR/lumina-gtk"
install_variant "Lumina-Dark" "colors-dark.css"
install_variant "Lumina-Light" "colors-light.css"

for variant in Lumina-Dark Lumina-Light; do
  ln -sfn "$THEMES_DIR/$variant" "$LEGACY_THEMES_DIR/$variant"
done

if command -v flatpak >/dev/null 2>&1; then
  flatpak override --user --filesystem="$THEMES_DIR:ro"
  flatpak override --user --filesystem="$LEGACY_THEMES_DIR:ro"
  flatpak override --user --filesystem=xdg-config/gtk-3.0:ro
  flatpak override --user --filesystem=xdg-config/gtk-4.0:ro
  flatpak override --user --filesystem=xdg-config/lumina-gtk:ro
fi

printf 'Installed Lumina-Dark and Lumina-Light in %s\n' "$THEMES_DIR"
printf 'Installed Android-style window control assets.\n'
printf 'Run %s/scripts/apply-theme.sh dark|light to activate a variant.\n' "$ROOT_DIR"

#!/usr/bin/env bash
set -uo pipefail

failures=0

check_command() {
    local command_name="$1"

    if command -v "$command_name" >/dev/null 2>&1; then
        printf 'OK   %-12s %s\n' "$command_name" "$(command -v "$command_name")"
    else
        printf 'MISS %-12s not found in PATH\n' "$command_name"
        failures=$((failures + 1))
    fi
}

printf 'Lumina Shell environment check\n\n'
check_command niri
check_command qs

printf '\nSession variables\n'
printf 'NIRI_SOCKET=%s\n' "${NIRI_SOCKET:-<not set>}"
printf 'WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-<not set>}"
printf 'XDG_CURRENT_DESKTOP=%s\n' "${XDG_CURRENT_DESKTOP:-<not set>}"

if [[ -n "${NIRI_SOCKET:-}" && -S "${NIRI_SOCKET}" ]]; then
    printf 'OK   Niri IPC socket is available.\n'
else
    printf 'WARN Niri IPC socket is unavailable. Run this inside an active Niri session.\n'
fi

printf '\n'
if (( failures > 0 )); then
    printf 'Environment check completed with %d missing required command(s).\n' "$failures"
    exit 1
fi

printf 'Environment check completed successfully.\n'

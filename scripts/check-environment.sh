#!/usr/bin/env bash
set -uo pipefail

require_niri=false
failures=0
warnings=0

usage() {
    cat <<'EOF'
Usage: ./scripts/check-environment.sh [--require-niri]

By default, validates the host development environment.
Use --require-niri inside the Niri test session to require Niri and its IPC socket.
EOF
}

if [[ "${1:-}" == "--require-niri" ]]; then
    require_niri=true
    shift
fi

if (( $# > 0 )); then
    usage >&2
    exit 2
fi

check_required_command() {
    local command_name="$1"

    if command -v "$command_name" >/dev/null 2>&1; then
        printf 'OK   %-12s %s\n' "$command_name" "$(command -v "$command_name")"
    else
        printf 'MISS %-12s not found in PATH\n' "$command_name"
        failures=$((failures + 1))
    fi
}

check_optional_command() {
    local command_name="$1"

    if command -v "$command_name" >/dev/null 2>&1; then
        printf 'OK   %-12s %s\n' "$command_name" "$(command -v "$command_name")"
    else
        printf 'INFO %-12s not found in PATH (optional on the development host)\n' "$command_name"
    fi
}

printf 'Lumina Shell environment check\n\n'
check_required_command qs
check_optional_command qmllint

if "$require_niri"; then
    check_required_command niri
else
    check_optional_command niri
fi

printf '\nSession variables\n'
printf 'NIRI_SOCKET=%s\n' "${NIRI_SOCKET:-<not set>}"
printf 'WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-<not set>}"
printf 'XDG_CURRENT_DESKTOP=%s\n' "${XDG_CURRENT_DESKTOP:-<not set>}"

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    printf 'OK   A Wayland session is active.\n'
else
    printf 'WARN No Wayland display is available. Runtime UI testing is unavailable.\n'
    warnings=$((warnings + 1))
fi

if [[ -n "${NIRI_SOCKET:-}" && -S "${NIRI_SOCKET}" ]]; then
    printf 'OK   Niri IPC socket is available.\n'
elif "$require_niri"; then
    printf 'MISS Niri IPC socket is unavailable. Run this inside an active Niri session.\n'
    failures=$((failures + 1))
else
    printf 'INFO Niri IPC socket is unavailable, which is expected outside Niri.\n'
fi

printf '\n'
if (( failures > 0 )); then
    printf 'Environment check failed with %d required check(s) missing.\n' "$failures"
    exit 1
fi

if (( warnings > 0 )); then
    printf 'Environment check completed with %d warning(s).\n' "$warnings"
else
    printf 'Environment check completed successfully.\n'
fi

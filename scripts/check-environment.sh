#!/usr/bin/env bash
set -uo pipefail

require_niri=false
require_daily=false
failures=0
warnings=0

usage() {
    cat <<'EOF'
Usage: ./scripts/check-environment.sh [--require-niri] [--require-daily]

By default, validates the host development environment.
Use --require-niri inside the Niri test session to require Niri and its IPC socket.
Use --require-daily to require the daily-control D-Bus services.
EOF
}

while (( $# > 0 )); do
    case "$1" in
        --require-niri)
            require_niri=true
            shift
            ;;
        --require-daily)
            require_daily=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
done

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

check_system_service() {
    local service_name="$1"
    local label="$2"
    local required="$3"

    if ! command -v busctl >/dev/null 2>&1; then
        printf 'INFO %-12s busctl unavailable; service not checked\n' "${label}"
        return
    fi

    if busctl --system --no-pager --no-legend list 2>/dev/null \
        | awk '{ print $1 }' \
        | grep -Fqx -- "${service_name}"; then
        printf 'OK   %-12s %s\n' "${label}" "${service_name}"
    elif "${required}"; then
        printf 'MISS %-12s %s is unavailable\n' "${label}" "${service_name}"
        failures=$((failures + 1))
    else
        printf 'INFO %-12s %s is unavailable (optional)\n' "${label}" "${service_name}"
    fi
}

check_pipewire() {
    local required="$1"

    if ! command -v wpctl >/dev/null 2>&1; then
        if "${required}"; then
            printf 'MISS %-12s wpctl is unavailable\n' PipeWire
            failures=$((failures + 1))
        fi
        return
    fi

    if wpctl status >/dev/null 2>&1; then
        printf 'OK   %-12s PipeWire socket is responding\n' PipeWire
    elif "${required}"; then
        printf 'MISS %-12s PipeWire socket is unavailable\n' PipeWire
        failures=$((failures + 1))
    else
        printf 'INFO %-12s PipeWire socket is unavailable (optional)\n' PipeWire
    fi
}

check_background_blur_support() {
    local qmltypes_file=""
    local candidate=""
    local niri_version=""

    for candidate in \
        /usr/lib/qt6/qml/Quickshell/Wayland/_BackgroundEffect/quickshell-wayland-background-effect.qmltypes \
        /usr/lib64/qt6/qml/Quickshell/Wayland/_BackgroundEffect/quickshell-wayland-background-effect.qmltypes; do
        if [[ -f "${candidate}" ]]; then
            qmltypes_file="${candidate}"
            break
        fi
    done

    if [[ -n "${qmltypes_file}" ]] \
        && grep -Fq 'name: "blurRegion"' "${qmltypes_file}"; then
        printf 'OK   %-12s Quickshell exposes a shaped blur-region request\n' \
            'Blur API'
    else
        printf 'INFO %-12s shaped BackgroundEffect API was not detected\n' \
            'Blur API'
    fi

    if command -v niri >/dev/null 2>&1; then
        niri_version="$(
            niri --version 2>/dev/null \
                | grep -Eo '[0-9]+\.[0-9]+' \
                | head -n 1
        )"

        if [[ -n "${niri_version}" ]] \
            && printf '%s\n%s\n' 26.04 "${niri_version}" \
                | sort -V -C; then
            printf 'OK   %-12s Niri %s includes ext-background-effect\n' \
                'Compositor' "${niri_version}"
        else
            printf 'INFO %-12s Niri 26.04+ is required for native blur\n' \
                'Compositor'
        fi
    fi

    printf 'INFO %-12s API presence does not prove the effect is enabled\n' \
        'Blur state'
}

printf 'Lumina Shell environment check\n\n'
check_required_command qs
check_optional_command qmllint

if "$require_niri"; then
    check_required_command niri
else
    check_optional_command niri
fi

printf '\nRuntime versions\n'
printf 'qs:   %s\n' "$(qs --version 2>/dev/null || printf 'unknown')"
if command -v niri >/dev/null 2>&1; then
    printf 'niri: %s\n' "$(niri --version 2>/dev/null || printf 'unknown')"
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

printf '\nBackground blur integration\n'
check_background_blur_support

printf '\nDaily-control integrations\n'
check_optional_command brightnessctl
check_optional_command powerprofilesctl
check_optional_command wpctl
check_optional_command nmcli
check_optional_command bluetoothctl
check_optional_command curl
check_optional_command timedatectl

check_pipewire "$require_daily"
check_system_service org.freedesktop.UPower UPower "$require_daily"
check_system_service net.hadess.PowerProfiles PowerProfiles "$require_daily"
check_system_service org.freedesktop.NetworkManager NetworkManager "$require_daily"
check_system_service org.bluez BlueZ "$require_daily"

if compgen -G '/sys/class/backlight/*' >/dev/null; then
    printf 'OK   %-12s a display backlight is available\n' Backlight
else
    printf 'INFO %-12s no display backlight found (desktop-safe fallback)\n' Backlight
fi

if compgen -G '/sys/class/power_supply/BAT*' >/dev/null; then
    printf 'OK   %-12s a laptop battery is available\n' Battery
else
    printf 'INFO %-12s no laptop battery found (desktop-safe fallback)\n' Battery
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

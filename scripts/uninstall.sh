#!/usr/bin/env bash
set -euo pipefail

target_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/quickshell/lumina-shell"
dry_run=false

usage() {
    printf '%s\n' \
        'Usage: ./scripts/uninstall.sh [--target PATH] [--dry-run]' \
        '' \
        'Removes a managed Lumina Shell installation.' \
        'Persistent Quickshell state is intentionally retained.'
}

fail() {
    printf 'ERROR: %s\n' "$1" >&2
    exit 1
}

validate_target() {
    [[ -n "${target_dir}" ]] || fail 'Uninstall target is empty.'
    [[ "${target_dir}" == /* ]] || fail 'Uninstall target must be absolute.'

    case "${target_dir}" in
        /|/home|/usr|/etc|"${HOME}")
            fail "Refusing unsafe uninstall target: ${target_dir}"
            ;;
    esac
}

while (( $# > 0 )); do
    case "$1" in
        --target)
            (( $# >= 2 )) || fail '--target requires a path.'
            target_dir="$2"
            shift 2
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            fail "Unknown argument: $1"
            ;;
    esac
done

if [[ "${target_dir}" != /* ]]; then
    target_dir="$(cd -- "$(dirname -- "${target_dir}")" 2>/dev/null && pwd)/$(basename -- "${target_dir}")"
fi

validate_target

if [[ ! -e "${target_dir}" ]]; then
    printf 'Lumina Shell is not installed at %s\n' "${target_dir}"
    exit 0
fi

[[ -f "${target_dir}/.lumina-shell-install" ]] \
    || fail "Refusing to remove unmanaged directory: ${target_dir}"

printf 'Lumina Shell uninstall\n'
printf 'Target: %s\n' "${target_dir}"

if "${dry_run}"; then
    printf 'DRY  Would remove the managed installation.\n'
    printf 'DRY  Persistent Quickshell state would be retained.\n'
    exit 0
fi

rm -rf -- "${target_dir}"

printf 'Managed installation removed.\n'
printf 'Persistent Quickshell state was retained.\n'

#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$(cd -- "${script_dir}/.." && pwd)"
target_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/quickshell/lumina-shell"
dry_run=false
force=false

usage() {
    printf '%s\n' \
        'Usage: ./scripts/install.sh [--target PATH] [--dry-run] [--force]' \
        '' \
        'Installs Lumina Shell into the Quickshell configuration directory.' \
        'Existing managed installations are updated in place.' \
        '--force permits replacing an existing unmanaged target.'
}

fail() {
    printf 'ERROR: %s\n' "$1" >&2
    exit 1
}

validate_target() {
    [[ -n "${target_dir}" ]] || fail 'Installation target is empty.'
    [[ "${target_dir}" == /* ]] || fail 'Installation target must be absolute.'

    case "${target_dir}" in
        /|/home|/usr|/etc|"${HOME}")
            fail "Refusing unsafe installation target: ${target_dir}"
            ;;
    esac

    if [[ "${target_dir}" == "${source_dir}" ]]; then
        fail 'The checkout itself cannot be used as the installation target.'
    fi
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
        --force)
            force=true
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

command -v qs >/dev/null 2>&1 \
    || fail 'Quickshell (qs) is required before installation.'

if [[ -e "${target_dir}" && ! -f "${target_dir}/.lumina-shell-install" ]]; then
    "${force}" || fail \
        "Target exists and is not a managed Lumina installation: ${target_dir}"
fi

install_paths=(
    CHANGELOG.md
    CONTRIBUTING.md
    README.md
    ROADMAP.md
    assets
    design
    docs
    i18n
    modules
    qmldir
    scripts
    services
    shell.qml
    stores
)

printf 'Lumina Shell installation\n'
printf 'Source: %s\n' "${source_dir}"
printf 'Target: %s\n' "${target_dir}"

if "${dry_run}"; then
    printf 'DRY  Would create or update the managed installation.\n'
    printf 'DRY  Run with: qs -p %q\n' "${target_dir}"
    exit 0
fi

install -d -- "${target_dir}"

for path in "${install_paths[@]}"; do
    source_path="${source_dir}/${path}"
    [[ -e "${source_path}" ]] || fail "Required source path is missing: ${path}"
    cp -a -- "${source_path}" "${target_dir}/"
done

printf 'managed-by=lumina-shell\n' > "${target_dir}/.lumina-shell-install"

printf 'Installed successfully.\n'
printf 'Run with: qs -p %q\n' "${target_dir}"

#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_dir="$(cd -- "${script_dir}/.." && pwd)"
catalog_dir="${repository_dir}/i18n"
source_catalog="${catalog_dir}/en-US.json"

command -v jq >/dev/null 2>&1 || {
    printf 'jq is required to validate translation catalogs.\n' >&2
    exit 1
}

command -v perl >/dev/null 2>&1 || {
    printf 'perl is required to inspect QML translation keys.\n' >&2
    exit 1
}

[[ -f "${source_catalog}" ]] || {
    printf 'Missing source translation catalog: %s\n' "${source_catalog}" >&2
    exit 1
}

validate_catalog() {
    local catalog_path="$1"

    jq -e '
        type == "object"
        and all(to_entries[];
            (.key | type == "string" and length > 0)
            and (.value | type == "string" and length > 0)
        )
    ' "${catalog_path}" >/dev/null || {
        printf 'Invalid translation catalog: %s\n' "${catalog_path}" >&2
        exit 1
    }
}

validate_catalog "${source_catalog}"

while IFS= read -r catalog_path; do
    validate_catalog "${catalog_path}"

    unknown_keys="$(
        jq -n -r \
            --slurpfile source "${source_catalog}" \
            --slurpfile catalog "${catalog_path}" \
            '($catalog[0] | keys) - ($source[0] | keys) | .[]'
    )"

    if [[ -n "${unknown_keys}" ]]; then
        printf 'Unknown keys in %s:\n%s\n' \
            "${catalog_path}" "${unknown_keys}" >&2
        exit 1
    fi
done < <(find "${catalog_dir}" -maxdepth 1 -type f -name '*.json' | sort)

missing_source_keys="$(
    mapfile -t qml_files < <(
        rg --files "${repository_dir}" --glob '*.qml'
    )

    perl -0777 -ne '
        while (/I18n\.tr\(\s*"([^"]+)"/g) {
            print "$1\n";
        }
    ' "${qml_files[@]}" \
        | sort -u \
        | while IFS= read -r message_id; do
            jq -e --arg key "${message_id}" \
                'has($key)' "${source_catalog}" >/dev/null \
                || printf '%s\n' "${message_id}"
        done
)"

if [[ -n "${missing_source_keys}" ]]; then
    printf 'Translation keys missing from en-US.json:\n%s\n' \
        "${missing_source_keys}" >&2
    exit 1
fi

printf 'Translation catalogs are valid.\n'

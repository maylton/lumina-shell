#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_dir="$(cd -- "${script_dir}/.." && pwd)"
catalog_dir="${repository_dir}/i18n"
source_catalog="${catalog_dir}/en-US.json"
pt_br_catalog="${catalog_dir}/pt-BR.json"
appearance_messages="${repository_dir}/services/i18n/AppearanceMessages.js"

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

[[ -f "${pt_br_catalog}" ]] || {
    printf 'Missing maintained Brazilian Portuguese catalog: %s\n' \
        "${pt_br_catalog}" >&2
    exit 1
}

[[ -f "${appearance_messages}" ]] || {
    printf 'Missing supplemental appearance translations: %s\n' \
        "${appearance_messages}" >&2
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

missing_pt_br_keys="$(
    jq -n -r \
        --slurpfile source "${source_catalog}" \
        --slurpfile catalog "${pt_br_catalog}" \
        '($source[0] | keys) - ($catalog[0] | keys) | .[]'
)"

if [[ -n "${missing_pt_br_keys}" ]]; then
    printf 'Keys missing from the maintained pt-BR catalog:\n%s\n' \
        "${missing_pt_br_keys}" >&2
    exit 1
fi

jq -e '
    .["control.tab.dashboard"] == "Dashboard"
    and .["settings.category.dashboard.label"] == "Dashboard"
    and (.["control.header.dashboardSubtitle"] | startswith("Dashboard"))
' "${pt_br_catalog}" >/dev/null || {
    printf 'The product term Dashboard must remain Dashboard in pt-BR.\n' >&2
    exit 1
}

supplemental_has_key() {
    local message_id="$1"
    grep -Fq "\"${message_id}\"" "${appearance_messages}"
}

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
                || supplemental_has_key "${message_id}" \
                || printf '%s\n' "${message_id}"
        done
)"

if [[ -n "${missing_source_keys}" ]]; then
    printf 'Translation keys missing from en-US.json or supplemental catalogs:\n%s\n' \
        "${missing_source_keys}" >&2
    exit 1
fi

printf 'Translation catalogs are valid.\n'

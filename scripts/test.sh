#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_dir="$(cd -- "${script_dir}/.." && pwd)"

"${repository_dir}/scripts/check-translations.sh"

PYTHONPYCACHEPREFIX="${TMPDIR:-/tmp}/lumina-shell-pycache" \
    python3 -m py_compile \
    "${repository_dir}/services/connectivity/BluetoothPairingAgent.py"

PYTHONPYCACHEPREFIX="${TMPDIR:-/tmp}/lumina-shell-pycache" \
    python3 "${repository_dir}/tests/test_bluetooth_pairing_agent.py"

pointer_focus_matches="$({
    rg -n \
        'forceActiveFocus\(Qt\.MouseFocusReason\)' \
        "${repository_dir}/modules/control/settings" \
        "${repository_dir}/modules/dock" \
        || true
})"

if [[ -n "${pointer_focus_matches}" ]]; then
    printf '%s\n' \
        'Pointer activation must not leave keyboard-focus styling active:' \
        "${pointer_focus_matches}" >&2
    exit 1
fi

async_pixmap_matches="$({
    rg -n \
        'asynchronous:[[:space:]]*true' \
        "${repository_dir}/modules/control/DashboardIcon.qml" \
        "${repository_dir}/modules/control/UserAvatar.qml" \
        "${repository_dir}/modules/wallpaper/Wallpaper.qml" \
        "${repository_dir}/modules/notifications/NotificationCard.qml" \
        || true
})"

if [[ -n "${async_pixmap_matches}" ]]; then
    printf '%s\n' \
        'Critical local images and shared icons must avoid QQuickPixmapReader:' \
        "${async_pixmap_matches}" >&2
    exit 1
fi

(
    install_test_root="$(mktemp -d)"
    install_test_target="${install_test_root}/lumina-shell"

    cleanup_install_test() {
        if [[ -e "${install_test_target}" ]]; then
            "${repository_dir}/scripts/uninstall.sh" \
                --target "${install_test_target}" >/dev/null
        fi

        rmdir "${install_test_root}"
    }
    trap cleanup_install_test EXIT

    "${repository_dir}/scripts/install.sh" \
        --target "${install_test_target}" >/dev/null

    test -f "${install_test_target}/.lumina-shell-install"
    test -f "${install_test_target}/shell.qml"
    test -f \
        "${install_test_target}/assets/icons/notification-symbolic.svg"
    test -f \
        "${install_test_target}/assets/icons/rocket-symbolic.svg"

    "${repository_dir}/scripts/uninstall.sh" \
        --target "${install_test_target}" >/dev/null
)

if command -v qmltestrunner >/dev/null 2>&1; then
    qml_test_runner="$(command -v qmltestrunner)"
elif [[ -x /usr/lib/qt6/bin/qmltestrunner ]]; then
    qml_test_runner="/usr/lib/qt6/bin/qmltestrunner"
else
    printf 'qmltestrunner was not found. Install Qt 6 declarative tools.\n' >&2
    exit 1
fi

qml_import_dir="$(mktemp -d)"
ln -s "${repository_dir}" "${qml_import_dir}/qs"
cleanup_qml_import() {
    unlink "${qml_import_dir}/qs"
    rmdir "${qml_import_dir}"
}
trap cleanup_qml_import EXIT

QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}" \
    "${qml_test_runner}" \
        -import "${qml_import_dir}" \
        -input "${repository_dir}/tests"

#!/usr/bin/env python3
"""Audit and apply the schema-8 shell-surface migration transactionally.

The migration is executed first in a detached temporary worktree. Tests and
static integration checks run there before the real checkout is touched. Only
an audited staged binary patch is then applied to the current branch. The
helper never pushes automatically and removes itself from the product commit.
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import textwrap

EXPECTED_BRANCH = "agent/niri-state-foundation"
PAYLOAD_REF = "automation/shell-surface-payload"
PAYLOAD_PATH = ".github/workflows/apply-shell-surface-style.yml"
PAYLOAD_COMMIT = "859585ec4eaad2f4d76cdd87bead3e8e6158fc99"
PAYLOAD_BLOB = "6b971550cf2b12aa471dff516e4c3428ad234080"
FINAL_COMMIT_MESSAGE = "Add Android-inspired shell surface styles"
ROOT = Path(__file__).resolve().parent.parent
SELF_RELATIVE = Path("scripts/apply-shell-surface-style-migration.py")


def run(
    *args: str,
    cwd: Path = ROOT,
    check: bool = True,
    capture: bool = False,
    stdout=None,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        list(args),
        cwd=cwd,
        check=check,
        text=True,
        stdout=subprocess.PIPE if capture else stdout,
        stderr=subprocess.PIPE if capture else None,
    )


def output(*args: str, cwd: Path = ROOT) -> str:
    return run(*args, cwd=cwd, capture=True).stdout.strip()


def replace_exact(path: Path, old: str, new: str) -> None:
    content = path.read_text(encoding="utf-8")
    count = content.count(old)
    if count != 1:
        raise RuntimeError(
            f"{path}: expected exactly one replacement target, found {count}"
        )
    path.write_text(content.replace(old, new, 1), encoding="utf-8")


def append_once(path: Path, marker: str, addition: str) -> None:
    content = path.read_text(encoding="utf-8")
    if addition.strip() in content:
        return
    if marker not in content:
        raise RuntimeError(f"{path}: documentation marker was not found")
    path.write_text(content.replace(marker, marker + addition, 1), encoding="utf-8")


def verify_payload() -> str:
    print("Fetching and verifying the immutable migration payload...")
    run(
        "git",
        "fetch",
        "--no-tags",
        "origin",
        f"{PAYLOAD_REF}:refs/remotes/origin/{PAYLOAD_REF}",
    )

    resolved = output("git", "rev-parse", f"origin/{PAYLOAD_REF}")
    if resolved != PAYLOAD_COMMIT:
        raise RuntimeError(
            "The preserved payload branch moved. "
            f"Expected {PAYLOAD_COMMIT}, found {resolved}."
        )

    blob = output("git", "rev-parse", f"{PAYLOAD_COMMIT}:{PAYLOAD_PATH}")
    if blob != PAYLOAD_BLOB:
        raise RuntimeError(
            "The migration payload blob does not match the audited content."
        )

    return output("git", "show", f"{PAYLOAD_COMMIT}:{PAYLOAD_PATH}")


def extract_payload(source: str) -> str:
    start_marker = "          python <<'PY'\n"
    end_marker = "\n          PY\n"

    try:
        start = source.index(start_marker) + len(start_marker)
        end = source.index(end_marker, start)
    except ValueError as error:
        raise RuntimeError("migration payload markers were not found") from error

    payload = textwrap.dedent(source[start:end])
    payload = payload.replace(
        '''
        Behavior on border.color {
            ColorAnimation {
                duration: root.luminaDesign.motion.effectsDefault
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }
''',
        "",
    )
    payload = payload.replace(
        "Path('.github/workflows/apply-shell-surface-style.yml').unlink()",
        "# Temporary-file cleanup is owned by the transactional wrapper.",
    )
    return payload


def apply_payload(worktree: Path, payload: str) -> None:
    previous = Path.cwd()
    os.chdir(worktree)
    try:
        exec(
            compile(payload, f"<{PAYLOAD_COMMIT}>", "exec"),
            {"__name__": "__main__", "__file__": str(worktree / SELF_RELATIVE)},
        )
    finally:
        os.chdir(previous)


def refine_policy(worktree: Path) -> None:
    policy = worktree / "modules/control/ShellSurfacePolicy.js"
    replace_exact(
        policy,
        '''function fallbackAlpha(mode, opacity, lightMode) {
    var normalized = normalizeMode(mode)

    if (!requestsBackdropBlur(normalized))
        return baseAlpha(normalized)

    return clamp(
        tintAlpha(normalized, opacity, lightMode)
            + contrastProtectionAlpha(normalized, lightMode),
        0.52,
        0.92
    )
}
''',
        '''function renderedCompositeAlpha(mode, opacity, lightMode) {
    var normalized = normalizeMode(mode)

    if (!requestsBackdropBlur(normalized))
        return baseAlpha(normalized)

    var tint = tintAlpha(normalized, opacity, lightMode)
    var protection = contrastProtectionAlpha(normalized, lightMode)
    return 1 - (1 - tint) * (1 - protection)
}
''',
    )
    replace_exact(
        policy,
        'return clamp(level * (lightMode ? 0.78 : 0.68), 0.40, 0.76)',
        'return clamp(level * (lightMode ? 0.78 : 0.68), 0.48, 0.76)',
    )
    replace_exact(
        policy,
        'return clamp(level * (lightMode ? 0.88 : 0.80), 0.48, 0.84)',
        'return clamp(level * (lightMode ? 0.88 : 0.80), 0.55, 0.84)',
    )

    tests = worktree / "tests/tst_shell_surface_policy.qml"
    replace_exact(
        tests,
        '''    function test_effectFallbackRemainsReadable() {
        verify(ShellSurfacePolicy.fallbackAlpha("blur", 0.55, true) >= 0.52)
        verify(ShellSurfacePolicy.fallbackAlpha(
            "frosted", 0.55, false
        ) >= 0.52)
    }
''',
        '''    function test_renderedCompositionRemainsReadable() {
        verify(ShellSurfacePolicy.renderedCompositeAlpha(
            "blur", 0.55, true
        ) >= 0.52)
        verify(ShellSurfacePolicy.renderedCompositeAlpha(
            "blur", 0.55, false
        ) >= 0.52)
        verify(ShellSurfacePolicy.renderedCompositeAlpha(
            "frosted", 0.55, false
        ) >= 0.60)
    }
''',
    )


def document_popup_policy(worktree: Path) -> None:
    popups = worktree / "modules/notifications/NotificationPopups.qml"
    replace_exact(
        popups,
        '                WlrLayershell.namespace: "lumina-notification-popups"\n',
        '''                WlrLayershell.namespace: "lumina-notification-popups"

                // Heads-up notifications intentionally remain opaque semantic
                // cards. The shared shell style applies to the bounded
                // Notification Center panel, not the transient multi-card stack.
''',
    )

    append_once(
        worktree / "docs/architecture.md",
        "The bar keeps its\nindependent background configuration.\n",
        '''

Transient heads-up notification cards remain opaque semantic surfaces rather
than requesting one large blur region across the gaps of their multi-card
stack. Calendar and tray popups remain owned by the independent bar surface
policy. This preserves urgency, avoids blur leaking through transparent gaps,
and keeps shell and bar configuration boundaries explicit.
''',
    )

    guide = worktree / "docs/user-guide.md"
    guide_text = guide.read_text(encoding="utf-8")
    guide_text = guide_text.replace(
        "- **Appearance:** theme mode, dynamic palette, wallpaper, transparency,\n  motion, shape, and density;",
        "- **Appearance:** theme mode, dynamic palette, wallpaper, shell surface\n  style, motion, shape, and density;",
    )
    guide_text = guide_text.replace(
        "Schema 7 writes are debounced",
        "Schema 8 writes are debounced",
    )
    guide_text = guide_text.replace(
        "Schema 3, 4, 5, and 6 files migrate in place.",
        "Schema 3, 4, 5, 6, and 7 files migrate in place.",
    )
    section = '''

### Shell surface styles

Appearance offers **Solid**, **Blur**, and **Frosted Glass** for primary shell
panels independently of the bar. Blur uses a clean bounded compositor request
with neutral tint and contrast protection. Frosted Glass adds a richer tint,
directional highlight, and subtle static texture. The tint-opacity control does
not change compositor blur radius or passes.

Dashboard/Settings, Launcher, Notification Center, Wallpaper Picker, Session
Menu, and OSD use the shared style. Their cards, text, icons, and controls remain
opaque. Heads-up notification cards stay opaque for urgency and readability,
while calendar and tray popups continue to follow the bar's independent visual
policy.
'''
    if "### Shell surface styles" not in guide_text:
        if "\n## Launcher\n" not in guide_text:
            raise RuntimeError("docs/user-guide.md: Launcher marker was not found")
        guide_text = guide_text.replace("\n## Launcher\n", section + "\n## Launcher\n", 1)
    guide.write_text(guide_text, encoding="utf-8")


def remove_temporary_files(worktree: Path) -> None:
    for relative in (
        ".github/workflows/apply-shell-surface-style.yml",
        ".github/workflows/run-shell-surface-migration.yml",
        SELF_RELATIVE.as_posix(),
    ):
        path = worktree / relative
        if path.exists():
            path.unlink()


def require_text(path: Path, *patterns: str) -> None:
    content = path.read_text(encoding="utf-8")
    for pattern in patterns:
        if pattern not in content:
            raise RuntimeError(f"{path}: required integration pattern missing: {pattern}")


def validate_generated_tree(worktree: Path) -> list[str]:
    for relative in (
        "modules/control/ShellSurface.qml",
        "modules/control/ShellSurfacePolicy.js",
        "tests/tst_shell_surface_policy.qml",
    ):
        if not (worktree / relative).is_file():
            raise RuntimeError(f"required generated file is missing: {relative}")

    require_text(
        worktree / "stores/config/ConfigSchema.js",
        "var CURRENT_VERSION = 8",
        'shellBackgroundMode: "solid"',
        "shellSurfaceOpacity: 0.82",
        "if (version < 8)",
        "delete input.transparencyEnabled",
        "delete input.surfaceOpacity",
        "barBackgroundMode",
        "barSurfaceOpacity",
    )
    require_text(
        worktree / "stores/config/ConfigStore.qml",
        "property alias shellBackgroundMode",
        "property alias shellSurfaceOpacity",
        '"shellBackgroundMode"',
        '"shellSurfaceOpacity"',
    )
    require_text(
        worktree / "design/Theme.qml",
        "readonly property real surfaceAlpha: 1",
    )
    require_text(
        worktree / "modules/control/qmldir",
        "ShellSurface 1.0 ShellSurface.qml",
    )
    require_text(
        worktree / "modules/control/ShellSurfacePolicy.js",
        "function renderedCompositeAlpha",
        "0.48, 0.76",
        "0.55, 0.84",
    )
    require_text(
        worktree / "docs/user-guide.md",
        "### Shell surface styles",
        "Schema 8 writes are debounced",
    )

    integration_targets = {
        "modules/control/ControlCenter.qml": "dashboardSurface",
        "modules/launcher/Launcher.qml": "launcherSurface",
        "modules/notifications/NotificationCenter.qml": "centerSurface",
        "modules/session/SessionMenu.qml": "menuSurface",
        "modules/wallpaper/WallpaperPicker.qml": "pickerSurface",
        "modules/osd/Osd.qml": "osdSurface",
    }
    for relative, identifier in integration_targets.items():
        require_text(
            worktree / relative,
            "surfaceFormat.opaque: false",
            "BackgroundEffect.blurRegion",
            "ShellSurface {",
            identifier,
        )

    notification_popups = (
        worktree / "modules/notifications/NotificationPopups.qml"
    ).read_text(encoding="utf-8")
    if "Heads-up notifications intentionally remain opaque" not in notification_popups:
        raise RuntimeError("notification popup surface policy is undocumented")
    if "BackgroundEffect.blurRegion" in notification_popups:
        raise RuntimeError("notification popup stack must not request one shared blur region")

    forbidden = (
        "ConfigStore.transparencyEnabled",
        "ConfigStore.surfaceOpacity",
        "property alias transparencyEnabled",
        "property alias surfaceOpacity",
    )
    for root_name in ("modules", "design", "stores"):
        for path in (worktree / root_name).rglob("*"):
            if not path.is_file() or path.name == "ConfigSchema.js":
                continue
            try:
                content = path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
            for token in forbidden:
                if token in content:
                    raise RuntimeError(
                        f"legacy public transparency reference remains in "
                        f"{path.relative_to(worktree)}: {token}"
                    )

    changed = output(
        "git", "diff", "--cached", "--name-only", "HEAD", cwd=worktree
    ).splitlines()
    for path in changed:
        if path.startswith("modules/bar/") \
            or path == "modules/control/settings/pages/BarPage.qml":
            raise RuntimeError(f"shell migration unexpectedly modified bar code: {path}")

    expected = {
        "CHANGELOG.md",
        "ROADMAP.md",
        "design/Theme.qml",
        "docs/architecture.md",
        "docs/user-guide.md",
        "modules/control/ControlCenter.qml",
        "modules/control/ShellSurface.qml",
        "modules/control/ShellSurfacePolicy.js",
        "modules/control/qmldir",
        "modules/control/settings/pages/AppearancePage.qml",
        "modules/launcher/Launcher.qml",
        "modules/notifications/NotificationCenter.qml",
        "modules/notifications/NotificationPopups.qml",
        "modules/osd/Osd.qml",
        "modules/session/SessionMenu.qml",
        "modules/wallpaper/WallpaperPicker.qml",
        "stores/config/ConfigSchema.js",
        "stores/config/ConfigStore.qml",
        "tests/tst_config_schema.qml",
        "tests/tst_shell_surface_policy.qml",
        SELF_RELATIVE.as_posix(),
    }
    unexpected = sorted(set(changed) - expected)
    missing = sorted(expected - set(changed))
    if unexpected:
        raise RuntimeError(
            "migration changed unexpected files:\n  " + "\n  ".join(unexpected)
        )
    if missing:
        raise RuntimeError(
            "migration did not produce expected files:\n  " + "\n  ".join(missing)
        )
    return changed


def run_validation(worktree: Path) -> None:
    print("Running translation, schema, and policy tests in the worktree...")
    run("./scripts/check-translations.sh", cwd=worktree)
    for script in sorted((worktree / "scripts").glob("*.sh")):
        run("bash", "-n", str(script), cwd=worktree)
    run("./scripts/test.sh", cwd=worktree)
    run("git", "diff", "--cached", "--check", cwd=worktree)

    environment_args = ["./scripts/check-environment.sh"]
    if os.environ.get("NIRI_SOCKET"):
        environment_args.append("--require-niri")
    run(*environment_args, cwd=worktree)

    if shutil.which("niri") and os.environ.get("NIRI_SOCKET"):
        run("niri", "validate", cwd=worktree)


def create_audited_patch(worktree: Path, patch_path: Path) -> None:
    with patch_path.open("w", encoding="utf-8") as stream:
        run(
            "git",
            "diff",
            "--cached",
            "--binary",
            "HEAD",
            cwd=worktree,
            stdout=stream,
        )
    if patch_path.stat().st_size == 0:
        raise RuntimeError("the audited migration produced an empty patch")


def cleanup_worktree(worktree: Path, temporary_root: Path) -> None:
    if worktree.exists():
        run("git", "worktree", "remove", "--force", str(worktree), check=False)
    shutil.rmtree(temporary_root, ignore_errors=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--audit-only",
        action="store_true",
        help="Run the complete migration audit without applying or committing it.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    os.chdir(ROOT)

    branch = output("git", "branch", "--show-current")
    if branch != EXPECTED_BRANCH:
        raise SystemExit(
            f"Run this on {EXPECTED_BRANCH}; current branch is {branch or '<detached>'}."
        )
    dirty = output("git", "status", "--porcelain")
    if dirty:
        raise SystemExit("The working tree must be clean before migration.\n\n" + dirty)

    original_head = output("git", "rev-parse", "HEAD")
    payload = extract_payload(verify_payload())
    temporary_root = Path(tempfile.mkdtemp(prefix="lumina-shell-surface-audit-"))
    worktree = temporary_root / "worktree"
    patch_path = temporary_root / "shell-surface.patch"

    try:
        print("Creating an isolated detached worktree...")
        run("git", "worktree", "add", "--detach", str(worktree), original_head)

        print("Applying the migration only inside the audit worktree...")
        apply_payload(worktree, payload)
        refine_policy(worktree)
        document_popup_policy(worktree)
        remove_temporary_files(worktree)
        run("git", "add", "-A", cwd=worktree)

        changed = validate_generated_tree(worktree)
        run_validation(worktree)
        create_audited_patch(worktree, patch_path)

        print("\nAudited files:")
        for path in changed:
            print(f"  {path}")

        if args.audit_only:
            print("\nAudit completed successfully; the real checkout was not changed.")
            return

        if output("git", "rev-parse", "HEAD") != original_head:
            raise RuntimeError("the real checkout moved during the audit")
        if output("git", "status", "--porcelain"):
            raise RuntimeError("the real checkout became dirty during the audit")

        print("\nApplying the audited patch to the real checkout...")
        run("git", "apply", "--index", "--binary", str(patch_path))
        run("git", "commit", "-m", FINAL_COMMIT_MESSAGE)
    except Exception as error:
        if output("git", "rev-parse", "HEAD") == original_head:
            run("git", "reset", "--hard", original_head, check=False)
        raise SystemExit(f"Migration audit failed: {error}") from error
    finally:
        cleanup_worktree(worktree, temporary_root)

    print("\nMigration audited, applied, and committed locally.")
    print("Start Lumina with: qs -p .")
    print("After native visual validation, publish with:")
    print(f"  git push origin {EXPECTED_BRANCH}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Apply the schema-8 Lumina shell surface migration once, locally.

The GitHub connector cannot trigger repository workflows in this repository.
This helper applies the already-reviewed migration payload from a preserved
remote branch, validates it in the native development checkout, creates the
product commit, and deletes itself. It never pushes automatically.
"""

from __future__ import annotations

import os
from pathlib import Path
import subprocess
import sys
import textwrap

EXPECTED_BRANCH = "agent/niri-state-foundation"
PAYLOAD_REF = "automation/shell-surface-payload"
PAYLOAD_PATH = ".github/workflows/apply-shell-surface-style.yml"
PAYLOAD_COMMIT = "859585ec4eaad2f4d76cdd87bead3e8e6158fc99"
FINAL_COMMIT_MESSAGE = "Add Android-inspired shell surface styles"
ROOT = Path(__file__).resolve().parent.parent
SELF = Path(__file__).resolve()


def run(
    *args: str,
    check: bool = True,
    capture: bool = False,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        list(args),
        cwd=ROOT,
        check=check,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def output(*args: str) -> str:
    result = run(*args, capture=True)
    return result.stdout.strip()


def rollback(message: str) -> None:
    print(f"\nMigration failed: {message}", file=sys.stderr)
    print("Restoring the clean pre-migration checkout...", file=sys.stderr)
    run("git", "reset", "--hard", "HEAD", check=False)
    run("git", "clean", "-fd", check=False)
    raise SystemExit(1)


def extract_payload(source: str) -> str:
    start_marker = "          python <<'PY'\n"
    end_marker = "\n          PY\n"

    try:
        start = source.index(start_marker) + len(start_marker)
        end = source.index(end_marker, start)
    except ValueError as error:
        raise RuntimeError("migration payload markers were not found") from error

    payload = textwrap.dedent(source[start:end])

    incompatible_behavior = """
        Behavior on border.color {
            ColorAnimation {
                duration: root.luminaDesign.motion.effectsDefault
                easing.type: root.luminaDesign.motion.effectsEasing
            }
        }
"""
    payload = payload.replace(incompatible_behavior, "")

    payload = payload.replace(
        "Path('.github/workflows/apply-shell-surface-style.yml').unlink()",
        "# Cleanup is owned by the one-shot wrapper.",
    )

    return payload


def patch_legacy_schema_fallback() -> None:
    schema = ROOT / "stores/config/ConfigSchema.js"
    content = schema.read_text(encoding="utf-8")
    content = content.replace(
        "defaults().surfaceOpacity",
        "defaults().shellSurfaceOpacity",
    )
    schema.write_text(content, encoding="utf-8")


def remove_temporary_files() -> None:
    for relative in (
        ".github/workflows/apply-shell-surface-style.yml",
        ".github/workflows/run-shell-surface-migration.yml",
    ):
        path = ROOT / relative
        if path.exists():
            path.unlink()

    if SELF.exists():
        SELF.unlink()


def validate_generated_tree() -> None:
    required = (
        "modules/control/ShellSurface.qml",
        "modules/control/ShellSurfacePolicy.js",
        "tests/tst_shell_surface_policy.qml",
    )
    for relative in required:
        if not (ROOT / relative).is_file():
            raise RuntimeError(f"required generated file is missing: {relative}")

    schema = (ROOT / "stores/config/ConfigSchema.js").read_text(
        encoding="utf-8"
    )
    store = (ROOT / "stores/config/ConfigStore.qml").read_text(
        encoding="utf-8"
    )
    qmldir = (ROOT / "modules/control/qmldir").read_text(encoding="utf-8")

    if "var CURRENT_VERSION = 8" not in schema:
        raise RuntimeError("ConfigSchema did not advance to schema 8")
    if "shellBackgroundMode" not in store:
        raise RuntimeError("ConfigStore does not expose shellBackgroundMode")
    if "ShellSurface 1.0 ShellSurface.qml" not in qmldir:
        raise RuntimeError("ShellSurface was not exported by the control module")

    forbidden = (
        "ConfigStore.transparencyEnabled",
        "ConfigStore.surfaceOpacity",
    )
    for root_name in ("modules", "design", "stores"):
        for path in (ROOT / root_name).rglob("*"):
            if not path.is_file() or path.name == "ConfigSchema.js":
                continue
            try:
                content = path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
            for token in forbidden:
                if token in content:
                    raise RuntimeError(
                        f"legacy public transparency reference remains: "
                        f"{path.relative_to(ROOT)}: {token}"
                    )


def main() -> None:
    os.chdir(ROOT)

    branch = output("git", "branch", "--show-current")
    if branch != EXPECTED_BRANCH:
        raise SystemExit(
            f"Run this on {EXPECTED_BRANCH}; current branch is {branch or '<detached>'}."
        )

    dirty = output("git", "status", "--porcelain")
    if dirty:
        raise SystemExit(
            "The working tree must be clean before migration.\n\n" + dirty
        )

    print("Fetching the preserved migration payload...")
    try:
        run(
            "git",
            "fetch",
            "--no-tags",
            "origin",
            f"{PAYLOAD_REF}:refs/remotes/origin/{PAYLOAD_REF}",
        )
        source = output(
            "git",
            "show",
            f"origin/{PAYLOAD_REF}:{PAYLOAD_PATH}",
        )
        payload = extract_payload(source)
    except (subprocess.CalledProcessError, RuntimeError) as error:
        rollback(str(error))

    print("Applying Solid, Blur, and Frosted Glass shell surfaces...")
    try:
        namespace = {
            "__name__": "__main__",
            "__file__": str(SELF),
        }
        exec(
            compile(payload, f"<{PAYLOAD_COMMIT}>", "exec"),
            namespace,
        )
        patch_legacy_schema_fallback()
        remove_temporary_files()
        validate_generated_tree()

        print("Validating translations and scripts...")
        run("./scripts/check-translations.sh")
        for script in sorted((ROOT / "scripts").glob("*.sh")):
            run("bash", "-n", str(script))

        print("Running QML tests...")
        run("./scripts/test.sh")
        run("git", "diff", "--check")

        environment_args = ["./scripts/check-environment.sh"]
        if os.environ.get("NIRI_SOCKET"):
            environment_args.append("--require-niri")
        run(*environment_args)

        if shutil_which("niri") and os.environ.get("NIRI_SOCKET"):
            run("niri", "validate")

        print("Creating the local product commit...")
        run("git", "add", "-A")
        run("git", "commit", "-m", FINAL_COMMIT_MESSAGE)
    except (subprocess.CalledProcessError, RuntimeError) as error:
        rollback(str(error))

    print("\nMigration completed and committed locally.")
    print("Start Lumina with: qs -p .")
    print("After visual validation, publish with:")
    print(f"  git push origin {EXPECTED_BRANCH}")


def shutil_which(command: str) -> str | None:
    from shutil import which

    return which(command)


if __name__ == "__main__":
    main()

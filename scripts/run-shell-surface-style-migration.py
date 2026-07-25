#!/usr/bin/env python3
"""Run the audited shell-surface migration with the schema-8 clamp fix."""

from pathlib import Path
import subprocess

BASE_COMMIT = "6f7d13ce6cdd5ddc16f7da90a08485ae779afe61"
BASE_PATH = "scripts/run-shell-surface-style-migration.py"
BASE_BLOB = "0b7121e31696e8d607c71170e916e9f4151b9c26"
ROOT = Path(__file__).resolve().parent.parent


def output(*args: str) -> str:
    return subprocess.run(
        list(args),
        cwd=ROOT,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout.rstrip("\n")


def replace_once(source: str, old: str, new: str, label: str) -> str:
    count = source.count(old)
    if count != 1:
        raise SystemExit(
            f"Could not patch {label}: expected one match, found {count}."
        )
    return source.replace(old, new, 1)


def main() -> None:
    blob = output("git", "rev-parse", f"{BASE_COMMIT}:{BASE_PATH}")
    if blob != BASE_BLOB:
        raise SystemExit(
            "The audited migration launcher does not match its pinned blob."
        )

    source = output("git", "show", f"{BASE_COMMIT}:{BASE_PATH}") + "\n"
    source = replace_once(
        source,
        '''    namespace["replace_exact"] = replace_exact_whitespace_aware
    namespace["main"]()
''',
        '''    namespace["replace_exact"] = replace_exact_whitespace_aware

    original_refine_policy = namespace["refine_policy"]
    original_validate_generated_tree = namespace["validate_generated_tree"]

    def refine_policy_with_schema_clamp_test(worktree):
        original_refine_policy(worktree)
        tests = worktree / "tests/tst_config_schema.qml"
        replace_exact_whitespace_aware(
            tests,
            "            surfaceOpacity: 0.1,\\n",
            "            shellSurfaceOpacity: 0.1,\\n",
        )
        replace_exact_whitespace_aware(
            tests,
            "        compare(state.surfaceOpacity, 0.72)\\n",
            "        compare(state.shellSurfaceOpacity, 0.55)\\n",
        )

    def validate_generated_tree_with_schema_clamp_test(worktree):
        changed = original_validate_generated_tree(worktree)
        tests = (
            worktree / "tests/tst_config_schema.qml"
        ).read_text(encoding="utf-8")
        required = (
            "            shellSurfaceOpacity: 0.1,",
            "        compare(state.shellSurfaceOpacity, 0.55)",
        )
        for pattern in required:
            if pattern not in tests:
                raise RuntimeError(
                    "schema clamp migration assertion is missing: " + pattern
                )
        forbidden = (
            "            surfaceOpacity: 0.1,",
            "        compare(state.surfaceOpacity, 0.72)",
        )
        for pattern in forbidden:
            if pattern in tests:
                raise RuntimeError(
                    "legacy schema clamp assertion remains: " + pattern
                )
        return changed

    namespace["refine_policy"] = refine_policy_with_schema_clamp_test
    namespace["validate_generated_tree"] = (
        validate_generated_tree_with_schema_clamp_test
    )
    namespace["main"]()
''',
        "schema-8 clamp test hook",
    )

    namespace = {
        "__name__": "__main__",
        "__file__": str(Path(__file__).resolve()),
    }
    exec(compile(source, str(Path(__file__).resolve()), "exec"), namespace)


if __name__ == "__main__":
    main()

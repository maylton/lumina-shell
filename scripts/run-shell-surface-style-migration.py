#!/usr/bin/env python3
"""Run the transactional shell-surface migration with safe payload fixes."""

from pathlib import Path

ORIGINAL = Path(__file__).resolve().with_name(
    "apply-shell-surface-style-migration.py"
)
HELPER_RELATIVE = "scripts/run-shell-surface-style-migration.py"


def replace_once(source: str, old: str, new: str, label: str) -> str:
    count = source.count(old)
    if count != 1:
        raise SystemExit(
            f"Could not patch {label}: expected one match, found {count}."
        )
    return source.replace(old, new, 1)


def normalize_payload(payload: str) -> str:
    ambiguous_boolean_removal = '''replace_once(
    'stores/config/ConfigSchema.js',
    '        "transparencyEnabled",\\n',
    ''
)
'''
    contextual_boolean_removal = '''replace_once(
    'stores/config/ConfigSchema.js',
    ''' + "'''" + '''        "showStatusDetails",
        "transparencyEnabled",
        "animationsEnabled",
''' + "'''" + ''',
    ''' + "'''" + '''        "showStatusDetails",
        "animationsEnabled",
''' + "'''" + '''
)
'''

    count = payload.count(ambiguous_boolean_removal)
    if count != 1:
        raise RuntimeError(
            "Could not make the schema boolean migration contextual: "
            f"expected one payload target, found {count}."
        )

    return payload.replace(
        ambiguous_boolean_removal,
        contextual_boolean_removal,
        1,
    )


def main() -> None:
    source = ORIGINAL.read_text(encoding="utf-8")

    source = replace_once(
        source,
        "    payload = textwrap.dedent(source[start:end])\n",
        '''    raw_payload = source[start:end]
    yaml_indent = "          "
    payload = "".join(
        line[len(yaml_indent):]
            if line.startswith(yaml_indent)
            else line
        for line in raw_payload.splitlines(keepends=True)
    )
    compile(payload, f"<{PAYLOAD_COMMIT}>", "exec")
''',
        "payload extraction",
    )

    source = replace_once(
        source,
        '''    return payload


def apply_payload''',
        '''    return normalize_payload(payload)


def apply_payload''',
        "payload normalization hook",
    )

    source = replace_once(
        source,
        '''        SELF_RELATIVE.as_posix(),
    ):
''',
        f'''        SELF_RELATIVE.as_posix(),
        "{HELPER_RELATIVE}",
    ):
''',
        "temporary-file cleanup",
    )

    source = replace_once(
        source,
        '''        SELF_RELATIVE.as_posix(),
    }
''',
        f'''        SELF_RELATIVE.as_posix(),
        "{HELPER_RELATIVE}",
    }}
''',
        "expected changed files",
    )

    namespace = {
        "__name__": "lumina_shell_surface_migration",
        "__file__": str(ORIGINAL),
        "normalize_payload": normalize_payload,
    }
    exec(compile(source, str(ORIGINAL), "exec"), namespace)
    namespace["main"]()


if __name__ == "__main__":
    main()

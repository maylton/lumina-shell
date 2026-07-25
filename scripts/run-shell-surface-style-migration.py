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


def replace_exact_whitespace_aware(path: Path, old: str, new: str) -> None:
    """Replace one block, allowing only leading/trailing whitespace drift."""
    content = path.read_text(encoding="utf-8")
    count = content.count(old)

    if count == 1:
        path.write_text(content.replace(old, new, 1), encoding="utf-8")
        return

    old_lines = old.splitlines(keepends=True)
    content_lines = content.splitlines(keepends=True)
    matches: list[int] = []

    def normalized(line: str) -> str:
        return line.strip()

    if old_lines:
        for start_line in range(0, len(content_lines) - len(old_lines) + 1):
            candidate = content_lines[
                start_line:start_line + len(old_lines)
            ]
            if all(
                normalized(candidate[index]) == normalized(old_lines[index])
                for index in range(len(old_lines))
            ):
                matches.append(start_line)

    if len(matches) != 1:
        raise RuntimeError(
            f"{path}: expected one exact or whitespace-only replacement "
            f"target, found exact={count}, whitespace={len(matches)}: "
            f"{old[:100]!r}"
        )

    start_line = matches[0]
    start_offset = sum(len(line) for line in content_lines[:start_line])
    end_offset = start_offset + sum(
        len(line)
        for line in content_lines[
            start_line:start_line + len(old_lines)
        ]
    )
    path.write_text(
        content[:start_offset] + new + content[end_offset:],
        encoding="utf-8",
    )


def normalize_literal_block(
    payload: str,
    first_line: str,
    following_lines: list[tuple[str, str]],
    label: str,
) -> str:
    """Repair YAML-stripped indentation inside one inline triple literal."""
    old = first_line
    new = first_line

    for broken, intended in following_lines:
        old += broken
        new += intended

    count = payload.count(old)
    if count != 1:
        raise RuntimeError(
            f"Could not normalize {label}: expected one target, found {count}."
        )

    return payload.replace(old, new, 1)


def upgrade_payload_replace_once(payload: str) -> str:
    """Allow one unique match whose only difference is leading indentation."""
    strict = """def replace_once(path, old, new):
    content = read(path)
    count = content.count(old)
    if count != 1:
        raise RuntimeError(f'{path}: expected one match, found {count}: {old[:80]!r}')
    write(path, content.replace(old, new, 1))
"""
    flexible = """def replace_once(path, old, new):
    content = read(path)
    count = content.count(old)

    if count == 1:
        write(path, content.replace(old, new, 1))
        return

    old_lines = old.splitlines(keepends=True)
    content_lines = content.splitlines(keepends=True)
    matches = []

    def without_indent(line):
        return line.lstrip(' \\t')

    if old_lines:
        for start_line in range(0, len(content_lines) - len(old_lines) + 1):
            candidate = content_lines[
                start_line:start_line + len(old_lines)
            ]
            if all(
                without_indent(candidate[index])
                    == without_indent(old_lines[index])
                for index in range(len(old_lines))
            ):
                matches.append(start_line)

    if len(matches) != 1:
        raise RuntimeError(
            f'{path}: expected one exact or indentation-only match, '
            f'found exact={count}, indentation={len(matches)}: {old[:80]!r}'
        )

    start_line = matches[0]
    start_offset = sum(len(line) for line in content_lines[:start_line])
    end_offset = start_offset + sum(
        len(line)
        for line in content_lines[
            start_line:start_line + len(old_lines)
        ]
    )
    write(path, content[:start_offset] + new + content[end_offset:])
"""

    count = payload.count(strict)
    if count != 1:
        raise RuntimeError(
            "Could not upgrade payload replace_once: "
            f"expected one definition, found {count}."
        )

    return payload.replace(strict, flexible, 1)


def normalize_payload(payload: str) -> str:
    payload = upgrade_payload_replace_once(payload)

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

    payload = payload.replace(
        ambiguous_boolean_removal,
        contextual_boolean_removal,
        1,
    )

    payload = normalize_literal_block(
        payload,
        "'''            \"paletteStyle\",\n",
        [
            ('  "transparencyEnabled",\n', '            "transparencyEnabled",\n'),
            ('  "surfaceOpacity",\n', '            "surfaceOpacity",\n'),
            ('  "animationsEnabled",\n', '            "animationsEnabled",\n'),
        ],
        "schema Appearance source keys",
    )
    payload = normalize_literal_block(
        payload,
        "'''            \"paletteStyle\",\n",
        [
            ('  "shellBackgroundMode",\n', '            "shellBackgroundMode",\n'),
            ('  "shellSurfaceOpacity",\n', '            "shellSurfaceOpacity",\n'),
            ('  "animationsEnabled",\n', '            "animationsEnabled",\n'),
        ],
        "schema Appearance replacement keys",
    )
    payload = normalize_literal_block(
        payload,
        "'''            \"transparencyEnabled\",\n",
        [
            ('  "surfaceOpacity",\n', '            "surfaceOpacity",\n'),
            ('  "animationsEnabled",\n', '            "animationsEnabled",\n'),
        ],
        "ConfigStore Appearance source keys",
    )
    payload = normalize_literal_block(
        payload,
        "'''            \"shellBackgroundMode\",\n",
        [
            ('  "shellSurfaceOpacity",\n', '            "shellSurfaceOpacity",\n'),
            ('  "animationsEnabled",\n', '            "animationsEnabled",\n'),
        ],
        "ConfigStore Appearance replacement keys",
    )

    payload = normalize_literal_block(
        payload,
        "'''            property string themeMode: \"auto\"\n",
        [
            (
                "  property bool transparencyEnabled: false\n",
                "            property bool transparencyEnabled: false\n",
            ),
            (
                "  property real surfaceOpacity: 0.96\n",
                "            property real surfaceOpacity: 0.96\n",
            ),
            (
                "  property bool animationsEnabled: true\n",
                "            property bool animationsEnabled: true\n",
            ),
        ],
        "ConfigStore adapter source properties",
    )
    payload = normalize_literal_block(
        payload,
        "'''            property string themeMode: \"auto\"\n",
        [
            (
                '  property string shellBackgroundMode: "solid"\n',
                '            property string shellBackgroundMode: "solid"\n',
            ),
            (
                "  property real shellSurfaceOpacity: 0.82\n",
                "            property real shellSurfaceOpacity: 0.82\n",
            ),
            (
                "  property bool animationsEnabled: true\n",
                "            property bool animationsEnabled: true\n",
            ),
        ],
        "ConfigStore adapter replacement properties",
    )

    payload = normalize_literal_block(
        payload,
        "'''                themeMode: root.themeMode,\n",
        [
            (
                "      dynamicTheme: root.dynamicTheme,\n",
                "                dynamicTheme: root.dynamicTheme,\n",
            ),
        ],
        "ConfigStore snapshot source",
    )
    payload = normalize_literal_block(
        payload,
        "'''                themeMode: root.themeMode,\n",
        [
            (
                "      shellBackgroundMode: root.shellBackgroundMode,\n",
                "                shellBackgroundMode: root.shellBackgroundMode,\n",
            ),
            (
                "      shellSurfaceOpacity: root.shellSurfaceOpacity,\n",
                "                shellSurfaceOpacity: root.shellSurfaceOpacity,\n",
            ),
            (
                "      dynamicTheme: root.dynamicTheme,\n",
                "                dynamicTheme: root.dynamicTheme,\n",
            ),
        ],
        "ConfigStore snapshot replacement",
    )

    return payload


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
    namespace["replace_exact"] = replace_exact_whitespace_aware
    namespace["main"]()


if __name__ == "__main__":
    main()

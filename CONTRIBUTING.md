# Contributing to Lumina Shell

Lumina Shell is in its public-beta hardening stage. Contributions should remain small, reviewable, and aligned with the current roadmap.

## Workflow

1. Create a branch from `main`.
2. Keep each pull request focused on one increment.
3. Explain what changed, why it changed, and how it was tested.
4. Avoid adding optional dependencies without documenting a fallback.
5. Do not access Niri or system commands directly from visual components; route actions through services.

Suggested branch prefixes:

- `feat/`
- `fix/`
- `docs/`
- `refactor/`
- `chore/`

## QML conventions

- Prefer typed properties and explicit IDs.
- Use root-relative imports such as `import qs.modules.bar`.
- Keep state and system integration outside visual components.
- Use design tokens instead of arbitrary colors, radii, and animation durations.
- Design every panel with multi-monitor behavior in mind.
- Ensure keyboard focus is visible whenever a component can receive focus.

## QML tooling

Create the local QML language-server file next to `shell.qml`:

```bash
touch .qmlls.ini
qs -p .
```

Quickshell manages the contents of `.qmlls.ini` for the current machine. The file is intentionally ignored by Git.

Use `qmlls` through the editor for project-aware diagnostics. A standalone `qmllint` invocation may not resolve Quickshell root-relative `qs.*` imports or `PanelWindow`, so runtime validation remains required.

Run the pure QML service tests with:

```bash
./scripts/test.sh
```

## Translations

New user-visible strings should use the runtime `I18n` service with a stable
message ID and an English fallback. Translation catalogs live in `i18n/` and
are validated as part of `./scripts/test.sh`.

See [docs/translations.md](docs/translations.md) for locale naming, catalog
fallback, placeholders, live reload, and the contribution workflow.

## Manual validation

On a Wayland development host:

```bash
./scripts/check-environment.sh
qs -p .
```

Inside the clean Niri test session:

```bash
./scripts/check-environment.sh --require-niri --require-daily
qs -p .
```

Confirm that:

- the shell starts without fatal QML errors;
- one bar appears on each output;
- the bar reserves its configured height;
- the clock updates;
- launcher, control center, settings, notifications, wallpaper, and session surfaces remain mutually exclusive;
- Tab, Enter, Space, arrow keys, and Escape work on affected controls;
- unavailable optional hardware renders a clear fallback;
- stopping Quickshell removes all shell surfaces cleanly.

For installation changes, validate both dry-run and an isolated target:

```bash
./scripts/install.sh --target /safe/temporary/path --dry-run
./scripts/install.sh --target /safe/temporary/path
./scripts/uninstall.sh --target /safe/temporary/path --dry-run
./scripts/uninstall.sh --target /safe/temporary/path
```

Never run uninstall validation against a real user configuration.

## Contribution license

Lumina Shell is licensed under `GPL-3.0-or-later`. By submitting a contribution for inclusion, you agree to license it under the same terms unless a different compatible license is explicitly documented for that material.

Do not submit copied code, artwork, icons, or other third-party material without preserving its copyright notice, confirming license compatibility, and recording it in [CREDITS.md](CREDITS.md).

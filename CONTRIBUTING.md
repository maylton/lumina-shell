# Contributing to Lumina Shell

Lumina Shell is at an early architectural stage. Contributions should remain small, reviewable, and aligned with the current roadmap.

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

## Manual validation

Before requesting review:

```bash
./scripts/check-environment.sh
qs -p .
```

Confirm that:

- the shell starts without fatal QML errors;
- one bar appears on each output;
- the bar reserves its configured height;
- the clock updates;
- stopping Quickshell removes all shell surfaces cleanly.

## License note

A project license is still pending. External contributions should wait until the licensing decision is recorded.

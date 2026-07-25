# Accessibility Baseline

Lumina's public-beta baseline provides semantic names, roles, descriptions, checked or selected state, and activation actions for the primary interactive surfaces.

## Keyboard behavior

- Escape closes the active launcher, unified control center, notification,
  wallpaper, or session surface.
- Tab and Shift+Tab move through controls that accept keyboard interaction.
- Enter and Space activate buttons, toggles, radio choices, notification actions, and session actions.
- Left and Right adjust focused audio, microphone, and brightness sliders in five-percent steps.
- Settings rows expose names and descriptions; switches announce checked
  state, previews/navigation announce selection, and Left/Right adjust focused
  settings sliders and choices.
- Launcher arrow keys move through ranked results; Enter activates the selected result.

Focused controls use a visible primary-color outline. Disabled controls are
removed from keyboard traversal and retain an explanatory label such as
`No backlight`. The Settings sidebar stays fixed while each category keeps an
independent scroll position.

## Assistive technology

Controls expose Qt `Accessible` metadata and actions instead of relying on painted text alone. Notifications expose their summary and body, launcher results expose selection state, toggles expose checked state, and exclusive surfaces provide predictable Escape behavior.

This baseline has been runtime-tested for QML validity and keyboard focus behavior. A formal screen-reader pass and contrast audit remain part of the stable-release accessibility work.

## Reporting problems

Include the following when reporting an accessibility issue:

- output of `qs --version`;
- output of `niri --version`;
- the affected surface and control;
- keyboard or assistive technology used;
- whether dynamic color was enabled.

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
- Lumina's Material Expressive bar controls use a 40-pixel interaction area
  at the default 56-pixel height and retain at least 36 pixels across 40–80
  pixel heights, automatic/manual scaling, and compact mode. Launcher,
  overview, workspaces, date/time, tray items,
  notifications, system status, and Dashboard expose focus outlines, names,
  descriptions, Enter, Space, and hover tooltips.
- The grouped tray button announces its active-item count, while the
  notification bell announces unread count and Do Not Disturb state.
- The active workspace changes both shape and width, so selection does not
  depend on color. Urgency has a border and an assistive description.
- Transparent-bar mode keeps interactive widgets on subtle tonal state
  surfaces rather than reducing text or icon opacity; focus outlines and
  selected states remain unchanged.
- Bar widget-order rows provide separate keyboard-focusable Show/Hide, Move
  up, and Move down controls.

Focused controls use a visible primary-color outline. Disabled controls are
removed from keyboard traversal and retain an explanatory label such as
`No backlight`. The Settings sidebar stays fixed while each category keeps an
independent scroll position.

## Assistive technology

Controls expose Qt `Accessible` metadata and actions instead of relying on painted text alone. Notifications expose their summary and body, launcher results expose selection state, toggles expose checked state, and exclusive surfaces provide predictable Escape behavior.

The non-interactive Niri context capsule exposes a static-text description and
never enters the tab order. Reduced motion keeps selected shapes and focus
outlines even when transitions are minimized. It also removes expressive
spatial overshoot; color and opacity remain brief enough to communicate state
without becoming the only source of feedback.

This baseline has been runtime-tested for QML validity and keyboard focus behavior. A formal screen-reader pass and contrast audit remain part of the stable-release accessibility work.

## Reporting problems

Include the following when reporting an accessibility issue:

- output of `qs --version`;
- output of `niri --version`;
- the affected surface and control;
- keyboard or assistive technology used;
- whether dynamic color was enabled.

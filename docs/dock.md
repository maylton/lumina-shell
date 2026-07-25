# Optional dock and task panel

Lumina provides one optional application surface with two presentation modes:

- **Floating dock** — a compact centered surface whose width follows the visible
  application icons.
- **Task panel** — a full-width bottom panel with the same application icons
  centered inside the available width.

The feature is disabled by default. Its preferences are stored separately in
`lumina-dock.json`, so enabling the dock does not require a migration of the
main shell configuration.

## Application model

The dock combines two existing sources of truth:

- `DesktopEntries` resolves application names, icons, and launch actions.
- `WindowStore` provides live Niri windows, focus, urgency, and application IDs.

Windows are grouped by application ID. Clicking a running application focuses
its window; repeated clicks cycle through the application's windows. Clicking a
pinned application that is not running launches its desktop entry.

The Launcher button is always the first item. Running applications can be shown
after pinned favorites. Right-clicking an application icon pins or unpins it.
Favorites can also be removed or cleared from **Settings → Dock**.

## Visibility and workspace reservation

Automatic hiding collapses the surface to a small bottom-edge reveal region.
The floating mode limits that reveal region to the bottom center, while the task
panel uses the full bottom edge. Moving the pointer into the region reveals the
surface; leaving it starts a short hide delay.

Click-through masking keeps transparent areas of the full-width layer window
from blocking normal application input.

Workspace reservation is available only when automatic hiding is disabled. It
reserves the complete bottom strip needed by the dock. When Lumina's bar is also
at the bottom, the dock is placed above it and includes the bar offset in its
reserved area.

## Appearance

Both presentation modes use the current primary shell surface style:

- Solid
- Blur
- Frosted Glass

Blur is requested only for the visible dock or panel geometry. The floating
mode supports a configurable bottom margin. Task-panel mode is edge-to-edge and
keeps application icons centered.

Icon size is bounded from 36 to 72 pixels. Long application lists scroll
horizontally rather than expanding beyond the output width.

## Current scope

The first implementation intentionally does not include:

- drag-and-drop reordering;
- application context menus beyond pin/unpin;
- badges from application-specific APIs;
- minimizing windows by clicking an already focused application;
- per-output favorite lists or presentation modes.

Those features can be added after native multi-output, auto-hide, focus cycling,
and task-panel behavior are validated.

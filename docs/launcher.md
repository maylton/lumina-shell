# Application launcher

Lumina's Launcher is a centered bottom app drawer inspired by modern Android desktop shells while remaining native to Niri and Quickshell.

## Browsing applications

Opening the Launcher with an empty query presents:

- a small drawer handle;
- a rounded search field;
- up to eight applications pinned to the Dock;
- a centered **All apps** heading;
- an alphabetically sorted, vertically scrollable application grid.

The drawer appears above a bottom Lumina bar and above the optional Dock or task panel. It follows the selected Solid, Blur, or Frosted Glass shell surface style.

Application tiles use desktop-entry names and icons. Hover gently enlarges the icon without adding a permanent focus state. Labels may wrap to two lines.

## Search

Typing switches the body to a detailed result list. Search covers:

- installed applications;
- open Niri windows;
- Niri layout and shell actions.

Application, window, and action labels are localized. Brazilian Portuguese includes the action names and descriptions rather than displaying the previous English-only strings.

Arrow keys navigate the grid or result list, Enter activates the selected result, and Escape closes a contextual menu first or the Launcher itself when no menu is open.

## Dock integration

Right-clicking an installed application in the pinned row, application grid, or search results opens the shared application menu. It offers **Pin to Dock** or **Unpin from Dock** and changes persistence only after the action is selected.

Window and shell-action search results are not pinnable. Favorites remain stored in the Dock's feature-scoped preferences and update the Launcher's pinned row reactively.

## Localization

The runtime catalogs continue to provide shared Launcher text such as the search placeholder, empty state, and keyboard hints. Feature-specific labels and Niri action descriptions are maintained in `services/i18n/LauncherStrings.js` for English and Brazilian Portuguese.

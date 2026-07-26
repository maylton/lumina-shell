# Lumina GTK design rules

Lumina GTK adapts Material 3 Expressive to desktop GTK applications rather than copying Android components literally.

## Shape scale

Use shape to establish hierarchy and relationships. Do not apply the same radius everywhere.

| Role | Radius | Typical use |
| --- | ---: | --- |
| Extra small | 4 px | indicators and compact internal details |
| Small | 8 px | compact menu rows, tabs and small fields |
| Medium | 12 px | standard buttons, entries and list selections |
| Large | 16 px | cards, popovers, grouped containers |
| Extra large | 24 px | prominent dialogs and hero containers |
| Full | 999 px | switches, progress tracks and circular icon buttons |

Nested containers should normally use a smaller radius than their parent. Adjacent items that form one functional group should visually share a container or use reduced spacing between them.

## Spacing scale

GTK CSS cannot expose numeric custom properties, so these values are applied directly and reviewed against this scale:

- 4 px: icon-to-label micro spacing and dense internal gaps;
- 8 px: compact control padding and gaps inside grouped controls;
- 12 px: standard horizontal control padding;
- 16 px: card and popover padding;
- 24 px: large section separation.

Avoid arbitrary 2 px and 6 px values except for optical alignment or compact state-layer margins.

## Desktop component targets

- Standard icon buttons: 40 × 40 px visual container.
- Compact window controls: 28 × 28 px.
- Text fields and location bars: at least 40 px high.
- Navigation rows: at least 40 px high, with 8 px horizontal outer margins.
- Popovers: 16 px radius and 8 px internal padding.
- Cards: 16 px radius; nested interactive children use 8–12 px.

## Expressive hierarchy

- Neutral surfaces carry most content.
- Primary color indicates selection, focus and important actions.
- Filled containers are reserved for selected or emphasized states.
- Default toolbar icon buttons should be tonal/subtle, not strongly outlined.
- Shape variation must communicate role; it must not become decoration without purpose.

## Motion

GTK themes cannot reliably define Material spring motion for every toolkit component. Lumina should preserve native GTK transitions and later add shell-level spring and shape-morphing behavior where the toolkit exposes safe animation hooks.

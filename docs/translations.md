# Translating Lumina Shell

Lumina loads UTF-8 JSON catalogs directly at runtime. The source locale is
`en-US`; incomplete or unavailable translations safely fall back to the
English string supplied by the QML component.

## Add a locale

1. Copy `i18n/en-US.json` to `i18n/<language>-<REGION>.json`, using ISO 639
   language and ISO 3166 region codes such as `fr-FR` or `de-DE`.
2. Translate values only. Keep every message ID unchanged.
3. Add the locale name to `I18n.availableLocales` in
   `services/i18n/I18n.qml`.
4. Run `./scripts/check-translations.sh`.
5. Start Lumina with `LUMINA_LOCALE=<locale> qs -p .` and check truncation,
   keyboard navigation, accessibility labels, dates, and numbers.

Catalogs may be incomplete while a translation is in progress. Missing keys
fall back to the English source text. Unknown keys fail validation so stale or
misspelled IDs do not silently ship.

## Add user-visible text

Import the service and provide a stable message ID plus an English fallback:

```qml
import qs.services.i18n

Text {
    text: I18n.tr(
        "settings.example.title",
        "Example setting"
    )
}
```

Use `%1`, `%2`, and later placeholders for dynamic values:

```qml
text: I18n.tr(
    "settings.example.output",
    "Output %1",
    [outputName]
)
```

Add every new ID to `i18n/en-US.json`. Add translations to other catalogs
when available; do not block a feature because one locale is incomplete.

Bar widget catalog titles and descriptions use stable
`settings.bar.catalog.<widget-id>.*` keys. Active-widget management, add,
reorder, remove, dialog, and scoped-reset labels are available in both the
English and Brazilian Portuguese catalogs. New widget settings should add
their user-visible strings to the source catalog without changing widget IDs
or persisted configuration keys.

## Locale selection

Lumina normalizes the Qt system locale and selects an exact regional catalog
when available. If only a matching language catalog exists, that catalog is
used. Unsupported locales fall back to `en-US`.

Set `LUMINA_LOCALE` before starting Quickshell to test a specific catalog:

```bash
LUMINA_LOCALE=pt-BR qs -p .
```

During development, catalog files are watched and reloaded. Runtime status and
manual reload are available through:

```bash
qs ipc -p . call i18n status
qs ipc -p . call i18n reload
```

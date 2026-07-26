import QtQuick
import QtTest
import "../services/i18n/I18n.js" as I18nLogic

TestCase {
    name: "I18n"

    readonly property var locales: [
        "en-US",
        "pt-BR",
        "fr-FR"
    ]

    function test_normalizesUnixLocale() {
        compare(
            I18nLogic.normalizedLocale("pt_BR.UTF-8"),
            "pt-BR"
        )
        compare(
            I18nLogic.normalizedLocale("en_US@calendar=gregorian"),
            "en-US"
        )
    }

    function test_prefersExactRegionalCatalog() {
        compare(
            I18nLogic.resolveLocale(
                "pt_BR.UTF-8",
                locales,
                "en-US"
            ),
            "pt-BR"
        )
    }

    function test_fallsBackByLanguageThenSource() {
        compare(
            I18nLogic.resolveLocale(
                "fr-CA",
                locales,
                "en-US"
            ),
            "fr-FR"
        )
        compare(
            I18nLogic.resolveLocale(
                "ja-JP",
                locales,
                "en-US"
            ),
            "en-US"
        )
    }

    function test_interpolatesRepeatedPlaceholders() {
        compare(
            I18nLogic.interpolate(
                "%1 uses %2 on %1",
                ["Lumina", "Niri"]
            ),
            "Lumina uses Niri on Lumina"
        )
    }
}

import QtQuick
import QtTest
import "../design/ThemePalette.js" as ThemePalette

TestCase {
    name: "ThemePalette"

    function test_autoKeepsDocumentedDarkFallback() {
        compare(ThemePalette.normalizedMode("auto"), "dark")
        compare(ThemePalette.normalizedMode("dark"), "dark")
        compare(ThemePalette.normalizedMode("light"), "light")
    }

    function test_baseSchemesAreComplete() {
        verify(ThemePalette.complete(
            ThemePalette.basePalette("light")
        ))
        verify(ThemePalette.complete(
            ThemePalette.basePalette("dark")
        ))
    }

    function test_darkSchemePreservesValidatedFoundation() {
        const palette = ThemePalette.basePalette("dark")

        compare(palette.primary, "#ADC6FF")
        compare(palette.surfaceBase, "#111318")
        compare(palette.surfaceContainer, "#1D2026")
        compare(palette.surfaceMuted, "#292C33")
        compare(palette.onSurface, "#E2E2E9")
    }

    function test_lightSchemeHasReadableSemanticPairs() {
        const palette = ThemePalette.basePalette("light")

        verify(ThemePalette.contrastRatio(
            palette.onSurface,
            palette.surfaceBase
        ) >= 7)
        verify(ThemePalette.contrastRatio(
            palette.textMuted,
            palette.surfaceContainer
        ) >= 4.5)
        verify(ThemePalette.contrastRatio(
            palette.onAccentContainer,
            palette.accentContainer
        ) >= 4.5)
        verify(ThemePalette.contrastRatio(
            palette.onPrimary,
            palette.primary
        ) >= 4.5)
    }

    function test_surfaceHierarchyChangesDirectionByMode() {
        const light = ThemePalette.basePalette("light")
        const dark = ThemePalette.basePalette("dark")

        verify(ThemePalette.relativeLuminance(light.surfaceLowest)
            > ThemePalette.relativeLuminance(light.surfaceContainer))
        verify(ThemePalette.relativeLuminance(light.surfaceContainer)
            > ThemePalette.relativeLuminance(light.surfaceMuted))
        verify(ThemePalette.relativeLuminance(dark.surfaceLowest)
            < ThemePalette.relativeLuminance(dark.surfaceContainer))
        verify(ThemePalette.relativeLuminance(dark.surfaceContainer)
            < ThemePalette.relativeLuminance(dark.surfaceMuted))
    }

    function test_dynamicPalettesSwitchWithoutRecalculationRace() {
        const light = ThemePalette.basePalette("light")
        const dark = ThemePalette.basePalette("dark")

        light.primary = "#123456"
        dark.primary = "#ABCDEF"

        compare(
            ThemePalette.activePalette(
                "light",
                true,
                light,
                dark
            ).primary,
            "#123456"
        )
        compare(
            ThemePalette.activePalette(
                "dark",
                true,
                light,
                dark
            ).primary,
            "#ABCDEF"
        )
    }

    function test_incompleteDynamicPaletteFallsBackSafely() {
        const palette = ThemePalette.activePalette(
            "light",
            true,
            { primary: "#123456" },
            {}
        )

        compare(
            palette.primary,
            ThemePalette.basePalette("light").primary
        )
    }
}

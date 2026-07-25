import QtQuick
import QtTest
import "../modules/bar/BarSurfacePolicy.js" as BarSurfacePolicy

TestCase {
    name: "BarSurfacePolicy"

    function test_onlyBlurStylesRequestBackdropBlur() {
        verify(BarSurfacePolicy.requestsBackdropBlur("blur"))
        verify(BarSurfacePolicy.requestsBackdropBlur("frosted"))
        verify(!BarSurfacePolicy.requestsBackdropBlur("translucent"))
        verify(!BarSurfacePolicy.requestsBackdropBlur("solid"))
        verify(!BarSurfacePolicy.requestsBackdropBlur("transparent"))
        verify(!BarSurfacePolicy.requestsBackdropBlur("invalid"))
    }

    function test_invalidModesUseSafeSolidPolicy() {
        compare(BarSurfacePolicy.normalizeMode("invalid"), "solid")
        compare(BarSurfacePolicy.backgroundAlpha("invalid", 0), 1)
        compare(BarSurfacePolicy.fallbackMode("invalid", false), "solid")
    }

    function test_blurFallbackPreservesNonBlurPreference() {
        compare(
            BarSurfacePolicy.fallbackMode("blur", false),
            "translucent"
        )
        compare(
            BarSurfacePolicy.fallbackMode("frosted", false),
            "translucent"
        )
        compare(
            BarSurfacePolicy.fallbackMode("transparent", false),
            "transparent"
        )
        compare(
            BarSurfacePolicy.fallbackMode("blur", true),
            "blur"
        )
    }

    function test_edgeToEdgeRegionUsesWholeSurfaceWithoutRadius() {
        const geometry = BarSurfacePolicy.blurRegionGeometry(
            1920,
            56,
            "edge-to-edge",
            8,
            24
        )

        compare(geometry.x, 0)
        compare(geometry.y, 0)
        compare(geometry.width, 1920)
        compare(geometry.height, 56)
        compare(geometry.radius, 0)
    }

    function test_floatingRegionExcludesMarginsAndKeepsRadius() {
        const geometry = BarSurfacePolicy.blurRegionGeometry(
            1920,
            72,
            "floating",
            8,
            24
        )

        compare(geometry.x, 8)
        compare(geometry.y, 8)
        compare(geometry.width, 1904)
        compare(geometry.height, 56)
        compare(geometry.radius, 24)
    }

    function test_regionGeometryClampsInvalidInputs() {
        const geometry = BarSurfacePolicy.blurRegionGeometry(
            -20,
            "invalid",
            "floating",
            -8,
            -24
        )

        compare(geometry.x, 0)
        compare(geometry.y, 0)
        compare(geometry.width, 0)
        compare(geometry.height, 0)
        compare(geometry.radius, 0)
    }

    function test_backgroundModesOnlyChangeSurfaceAlpha() {
        compare(BarSurfacePolicy.backgroundAlpha("solid", 0.2), 1)
        compare(BarSurfacePolicy.backgroundAlpha("blur", 0.86), 0)
        compare(BarSurfacePolicy.backgroundAlpha("frosted", 0.72), 0)
        compare(BarSurfacePolicy.backgroundAlpha("transparent", 1), 0)
        compare(
            BarSurfacePolicy.backgroundAlpha("translucent", 0),
            0.44
        )
        compare(
            BarSurfacePolicy.backgroundAlpha("translucent", 1),
            0.86
        )
    }

    function test_opacityIsSafelyClamped() {
        compare(
            BarSurfacePolicy.backgroundAlpha("translucent", -1),
            0.44
        )
        compare(
            BarSurfacePolicy.backgroundAlpha("translucent", 2),
            0.86
        )
        verify(BarSurfacePolicy.tintAlpha("blur", -1, true) > 0)
        verify(BarSurfacePolicy.tintAlpha("blur", 2, true) < 1)
    }

    function test_transparentModeHidesSemanticOutlines() {
        compare(BarSurfacePolicy.dividerAlpha("transparent", 1), 0)
        compare(BarSurfacePolicy.borderAlpha("transparent", 1), 0)
    }

    function test_blurOutlinesFollowBackgroundOpacity() {
        compare(BarSurfacePolicy.dividerAlpha("blur", 0.5), 0.15)
        compare(BarSurfacePolicy.borderAlpha("blur", 0.5), 0.3)
    }

    function test_frostedOutlinesRetainAVisibleGlassEdge() {
        compare(BarSurfacePolicy.dividerAlpha("frosted", 0), 0.18)
        compare(BarSurfacePolicy.dividerAlpha("frosted", 1), 0.34)
        compare(BarSurfacePolicy.borderAlpha("frosted", 0), 0.32)
        compare(BarSurfacePolicy.borderAlpha("frosted", 1), 0.6)
    }

    function test_frostedLayersAreModeSpecific() {
        verify(BarSurfacePolicy.showsFrostedHighlight("frosted"))
        verify(BarSurfacePolicy.showsFrostedGrain("frosted"))
        verify(!BarSurfacePolicy.showsFrostedHighlight("blur"))
        verify(!BarSurfacePolicy.showsFrostedGrain("translucent"))
        verify(!BarSurfacePolicy.showsFrostedGrain("invalid"))
    }

    function test_translucentPolicyIsDistinctFromBlur() {
        verify(
            BarSurfacePolicy.backgroundAlpha("translucent", 0.72)
            > BarSurfacePolicy.backgroundAlpha("blur", 0.72)
        )
        compare(BarSurfacePolicy.tintAlpha("translucent", 1, true), 0)
        compare(
            BarSurfacePolicy.contrastProtectionAlpha(
                "translucent", 1, true
            ),
            0
        )
    }

    function test_cleanBlurAndFrostedHaveDistinctTints() {
        const lightBlur =
            BarSurfacePolicy.tintAlpha("blur", 0.8, true)
        const darkBlur =
            BarSurfacePolicy.tintAlpha("blur", 0.8, false)
        const lightFrosted =
            BarSurfacePolicy.tintAlpha("frosted", 0.8, true)
        const darkFrosted =
            BarSurfacePolicy.tintAlpha("frosted", 0.8, false)

        verify(lightBlur > 0 && lightBlur < 1)
        verify(darkBlur > 0 && darkBlur < 1)
        verify(lightFrosted > lightBlur)
        verify(darkFrosted > darkBlur)
    }

    function test_fallbackSurfaceNeverBecomesTransparent() {
        verify(BarSurfacePolicy.fallbackAlpha("blur", 0, true) > 0)
        verify(BarSurfacePolicy.fallbackAlpha("blur", 0, false) > 0)
        verify(BarSurfacePolicy.fallbackAlpha("frosted", 0, true) > 0)
        verify(BarSurfacePolicy.fallbackAlpha("frosted", 0, false) > 0)
        compare(
            BarSurfacePolicy.fallbackAlpha("transparent", 1, true),
            0
        )
    }

    function test_highlightAndGrainAlphasAreFrostedOnly() {
        compare(
            BarSurfacePolicy.frostedHighlightAlpha("blur", 1, true),
            0
        )
        compare(
            BarSurfacePolicy.frostedGrainAlpha("blur", 1, false),
            0
        )
        verify(
            BarSurfacePolicy.frostedHighlightAlpha(
                "frosted", 1, true
            ) > 0
        )
        verify(
            BarSurfacePolicy.frostedGrainAlpha(
                "frosted", 1, false
            ) > 0
        )
    }

}

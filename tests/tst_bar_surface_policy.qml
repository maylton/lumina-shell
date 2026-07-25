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
        compare(BarSurfacePolicy.backgroundAlpha("blur", 0.86), 0.86)
        compare(BarSurfacePolicy.backgroundAlpha("frosted", 0.72), 0.72)
        compare(BarSurfacePolicy.backgroundAlpha("transparent", 1), 0)
    }

    function test_opacityIsSafelyClamped() {
        compare(BarSurfacePolicy.backgroundAlpha("blur", -1), 0)
        compare(BarSurfacePolicy.backgroundAlpha("blur", 2), 1)
        compare(BarSurfacePolicy.backgroundAlpha("frosted", -1), 0)
        compare(BarSurfacePolicy.backgroundAlpha("frosted", 2), 1)
    }

    function test_transparentModeHidesSemanticOutlines() {
        compare(BarSurfacePolicy.dividerAlpha("transparent", 1), 0)
        compare(BarSurfacePolicy.borderAlpha("transparent", 1), 0)
    }

    function test_blurOutlinesFollowBackgroundOpacity() {
        compare(BarSurfacePolicy.dividerAlpha("blur", 0.5), 0.12)
        compare(BarSurfacePolicy.borderAlpha("blur", 0.5), 0.21)
    }

    function test_frostedOutlinesRetainAVisibleGlassEdge() {
        compare(BarSurfacePolicy.dividerAlpha("frosted", 0), 0.12)
        compare(BarSurfacePolicy.dividerAlpha("frosted", 1), 0.3)
        compare(BarSurfacePolicy.borderAlpha("frosted", 0), 0.28)
        compare(BarSurfacePolicy.borderAlpha("frosted", 1), 0.64)
    }

    function test_frostedLayersAreModeSpecific() {
        verify(BarSurfacePolicy.showsFrostedHighlight("frosted"))
        verify(BarSurfacePolicy.showsFrostedGrain("frosted"))
        verify(!BarSurfacePolicy.showsFrostedHighlight("blur"))
        verify(!BarSurfacePolicy.showsFrostedGrain("translucent"))
        verify(!BarSurfacePolicy.showsFrostedGrain("invalid"))
    }

    function test_legacyTranslucentPolicyMatchesBlur() {
        compare(
            BarSurfacePolicy.backgroundAlpha("translucent", 0.72),
            BarSurfacePolicy.backgroundAlpha("blur", 0.72)
        )
        compare(
            BarSurfacePolicy.dividerAlpha("translucent", 0.72),
            BarSurfacePolicy.dividerAlpha("blur", 0.72)
        )
        compare(
            BarSurfacePolicy.borderAlpha("translucent", 0.72),
            BarSurfacePolicy.borderAlpha("blur", 0.72)
        )
    }

}

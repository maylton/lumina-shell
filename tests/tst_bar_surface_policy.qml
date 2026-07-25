import QtQuick
import QtTest
import "../modules/bar/BarSurfacePolicy.js" as BarSurfacePolicy

TestCase {
    name: "BarSurfacePolicy"

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

import QtQuick
import QtTest
import "../modules/bar/BarSurfacePolicy.js" as BarSurfacePolicy

TestCase {
    name: "BarSurfacePolicy"

    function test_backgroundModesOnlyChangeSurfaceAlpha() {
        compare(BarSurfacePolicy.backgroundAlpha("solid", 0.2), 1)
        compare(
            BarSurfacePolicy.backgroundAlpha("translucent", 0.86),
            0.86
        )
        compare(BarSurfacePolicy.backgroundAlpha("transparent", 1), 0)
    }

    function test_opacityIsSafelyClamped() {
        compare(BarSurfacePolicy.backgroundAlpha("translucent", -1), 0)
        compare(BarSurfacePolicy.backgroundAlpha("translucent", 2), 1)
    }

    function test_transparentModeHidesSemanticOutlines() {
        compare(BarSurfacePolicy.dividerAlpha("transparent", 1), 0)
        compare(BarSurfacePolicy.borderAlpha("transparent", 1), 0)
    }

    function test_translucentOutlinesFollowBackgroundOpacity() {
        compare(BarSurfacePolicy.dividerAlpha("translucent", 0.5), 0.12)
        compare(BarSurfacePolicy.borderAlpha("translucent", 0.5), 0.21)
    }

    function test_onlySolidSurfaceReservesWorkArea() {
        compare(BarSurfacePolicy.exclusiveZone("solid", 56), 56)
        compare(BarSurfacePolicy.exclusiveZone("translucent", 56), 0)
        compare(BarSurfacePolicy.exclusiveZone("transparent", 56), 0)
        compare(BarSurfacePolicy.exclusiveZone("solid", -10), 0)
    }
}

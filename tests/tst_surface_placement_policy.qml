import QtQuick
import QtTest
import "../stores/shell/SurfacePlacementPolicy.js" as SurfacePlacementPolicy

TestCase {
    name: "SurfacePlacementPolicy"

    function test_normalizeUsesCenteredFallback() {
        compare(
            SurfacePlacementPolicy.normalize("near-widget"),
            "near-widget"
        )
        compare(
            SurfacePlacementPolicy.normalize("centered"),
            "centered"
        )
        compare(
            SurfacePlacementPolicy.normalize("invalid"),
            "centered"
        )
        compare(
            SurfacePlacementPolicy.normalize("invalid", "near-widget"),
            "near-widget"
        )
    }

    function test_floatingBarOffsetEndsAtVisualBarEdge() {
        compare(
            SurfacePlacementPolicy.barWindowHeight(56, "edge-to-edge", 12),
            56
        )
        compare(
            SurfacePlacementPolicy.barWindowHeight(56, "floating", 12),
            68
        )
    }

    function test_horizontalPositionFollowsAndClampsAnchor() {
        compare(
            SurfacePlacementPolicy.horizontalX(
                "near-widget", 500, 200, 1000, 16
            ),
            400
        )
        compare(
            SurfacePlacementPolicy.horizontalX(
                "near-widget", 20, 200, 1000, 16
            ),
            16
        )
        compare(
            SurfacePlacementPolicy.horizontalX(
                "near-widget", 990, 200, 1000, 16
            ),
            784
        )
        compare(
            SurfacePlacementPolicy.horizontalX(
                "centered", 20, 200, 1000, 16
            ),
            400
        )
    }

    function test_verticalPositionStartsAtUsableAreaEdge() {
        compare(
            SurfacePlacementPolicy.verticalY(
                "near-widget", "top", 300, 900, 64, 8, 16
            ),
            8
        )
        compare(
            SurfacePlacementPolicy.verticalY(
                "near-widget", "bottom", 300, 900, 64, 8, 16
            ),
            592
        )
        compare(
            SurfacePlacementPolicy.verticalY(
                "centered", "top", 300, 900, 64, 8, 16
            ),
            8
        )
    }

    function test_verticalPositionDoesNotReuseBarWindowCoordinates() {
        compare(
            SurfacePlacementPolicy.verticalY(
                "near-widget", "top", 300, 900, 68, 8, 16, 12, 52
            ),
            8
        )
        compare(
            SurfacePlacementPolicy.verticalY(
                "near-widget", "bottom", 300, 900, 68, 8, 16, 848, 888
            ),
            592
        )
    }

    function test_invalidProvidedGeometryDoesNotAffectUsableAreaEdge() {
        compare(
            SurfacePlacementPolicy.verticalY(
                "near-widget", "top", 300, 900, 64, 8, 16, 60, 40
            ),
            8
        )
    }

    function test_verticalPositionUsesConfiguredGap() {
        compare(
            SurfacePlacementPolicy.verticalY(
                "near-widget", "top", 300, 900, 64, 24, 16
            ),
            24
        )
        compare(
            SurfacePlacementPolicy.verticalY(
                "near-widget", "bottom", 300, 900, 64, 24, 16
            ),
            576
        )
    }

    function test_zeroGapTouchesUsableAreaEdge() {
        compare(
            SurfacePlacementPolicy.verticalY(
                "near-widget", "top", 300, 900, 68, 0, 16, 12, 52
            ),
            0
        )
        compare(
            SurfacePlacementPolicy.verticalY(
                "near-widget", "bottom", 300, 900, 68, 0, 16, 848, 888
            ),
            600
        )
    }

}

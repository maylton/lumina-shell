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

    function test_barReservedHeightIncludesBothFloatingMargins() {
        compare(
            SurfacePlacementPolicy.barReservedHeight(
                56, "edge-to-edge", 12
            ),
            56
        )
        compare(
            SurfacePlacementPolicy.barReservedHeight(56, "floating", 12),
            80
        )
    }

    function test_outputYConvertsToTopBarViewportCoordinates() {
        compare(
            SurfacePlacementPolicy.outputYToViewportY(
                1380, "top", 56, "edge-to-edge", 12
            ),
            1324
        )
        compare(
            SurfacePlacementPolicy.outputYToViewportY(
                1380, "top", 56, "floating", 12
            ),
            1300
        )
    }

    function test_outputYPreservesBottomBarViewportCoordinates() {
        compare(
            SurfacePlacementPolicy.outputYToViewportY(
                1380, "bottom", 56, "edge-to-edge", 12
            ),
            1380
        )
        compare(
            SurfacePlacementPolicy.outputYToViewportY(
                -1, "top", 56, "edge-to-edge", 12
            ),
            -1
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

    function test_aboveAnchorPositionUsesAnchorAndGap() {
        compare(
            SurfacePlacementPolicy.aboveAnchorY(760, 420, 900, 8),
            332
        )
        compare(
            SurfacePlacementPolicy.aboveAnchorY(760, 420, 900, 0),
            340
        )
    }

    function test_aboveAnchorPositionClampsToViewport() {
        compare(
            SurfacePlacementPolicy.aboveAnchorY(300, 420, 900, 8),
            0
        )
        compare(
            SurfacePlacementPolicy.aboveAnchorY(1200, 420, 900, 8),
            480
        )
        compare(
            SurfacePlacementPolicy.aboveAnchorY(-1, 420, 900, 8),
            480
        )
    }

}

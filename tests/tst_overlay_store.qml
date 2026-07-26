import QtQuick
import QtTest
import qs.stores.shell

TestCase {
    id: testCase

    name: "OverlayStore"

    readonly property string outputName: "TEST-OUTPUT"

    function init() {
        OverlayStore.close()
    }

    function cleanup() {
        OverlayStore.close()
    }

    function test_prepareForReplacesCompletePendingGeometry() {
        OverlayStore.prepareFor(
            "notifications",
            outputName,
            "near-widget",
            120,
            8,
            56
        )
        OverlayStore.prepareFor(
            "control",
            outputName,
            "near-widget",
            920,
            12,
            60
        )

        compare(OverlayStore.pendingSurface, "control")
        compare(OverlayStore.pendingAnchorX, 920)
        compare(OverlayStore.pendingAnchorTop, 12)
        compare(OverlayStore.pendingAnchorBottom, 60)
    }

    function test_openForTransfersMatchingPreparedGeometry() {
        OverlayStore.prepareFor(
            "notifications",
            outputName,
            "near-widget",
            920,
            12,
            60
        )
        OverlayStore.openFor("notifications", outputName)

        compare(OverlayStore.activeSurface, "notifications")
        compare(OverlayStore.activeAnchorX, 920)
        compare(OverlayStore.activeAnchorTop, 12)
        compare(OverlayStore.activeAnchorBottom, 60)
        compare(OverlayStore.pendingAnchorX, -1)
        compare(OverlayStore.pendingAnchorTop, -1)
        compare(OverlayStore.pendingAnchorBottom, -1)
    }

    function test_openForDoesNotTransferStalePreparedGeometry() {
        OverlayStore.prepareFor(
            "notifications",
            outputName,
            "near-widget",
            920,
            12,
            60
        )
        OverlayStore.openFor("control", outputName)

        compare(OverlayStore.activeSurface, "control")
        compare(OverlayStore.activePlacement, "centered")
        compare(OverlayStore.activeAnchorX, -1)
        compare(OverlayStore.activeAnchorTop, -1)
        compare(OverlayStore.activeAnchorBottom, -1)
    }

    function test_closeClearsAllAnchorGeometry() {
        OverlayStore.prepareFor(
            "notifications",
            outputName,
            "near-widget",
            920,
            12,
            60
        )
        OverlayStore.openFor("notifications", outputName)
        OverlayStore.prepareFor(
            "control",
            outputName,
            "near-widget",
            120,
            8,
            56
        )

        OverlayStore.close()

        compare(OverlayStore.activeAnchorX, -1)
        compare(OverlayStore.activeAnchorTop, -1)
        compare(OverlayStore.activeAnchorBottom, -1)
        compare(OverlayStore.pendingAnchorX, -1)
        compare(OverlayStore.pendingAnchorTop, -1)
        compare(OverlayStore.pendingAnchorBottom, -1)
    }
}

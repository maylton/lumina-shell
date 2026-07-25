import QtQuick
import QtTest
import "../modules/control/settings/SettingsSliderGeometry.js" as Geometry

TestCase {
    name: "SettingsSliderGeometry"

    function test_normalizesAndClampsValues() {
        compare(Geometry.normalizedValue(-2, 0, 10), 0)
        compare(Geometry.normalizedValue(5, 0, 10), 0.5)
        compare(Geometry.normalizedValue(12, 0, 10), 1)
    }

    function test_centersHandleAcrossAvailableWidth() {
        compare(Geometry.handleX(160, 6, 0), 0)
        compare(Geometry.handleX(160, 6, 0.5), 77)
        compare(Geometry.handleX(160, 6, 1), 154)
    }

    function test_keepsGapAroundMiddleHandle() {
        compare(Geometry.activeWidth(160, 6, 6, 0.5), 71)
        compare(Geometry.inactiveX(160, 6, 6, 0.5), 89)
        compare(Geometry.inactiveWidth(160, 6, 6, 0.5), 71)
    }

    function test_segmentsCollapseAtEndpoints() {
        compare(Geometry.activeWidth(160, 6, 6, 0), 0)
        compare(Geometry.inactiveX(160, 6, 6, 0), 12)
        compare(Geometry.activeWidth(160, 6, 6, 1), 148)
        compare(Geometry.inactiveWidth(160, 6, 6, 1), 0)
    }
}

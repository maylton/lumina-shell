import QtQuick
import QtTest
import "../modules/control/WavyProgressGeometry.js" as Geometry

TestCase {
    name: "WavyProgressGeometry"

    function test_progressIsClamped() {
        compare(Geometry.normalizedProgress(-0.5), 0)
        compare(Geometry.normalizedProgress(0.42), 0.42)
        compare(Geometry.normalizedProgress(1.5), 1)
    }

    function test_activeExtentRespectsStrokeInsets() {
        compare(Geometry.activeEnd(240, 4, 0), 2)
        compare(Geometry.activeEnd(240, 4, 0.5), 120)
        compare(Geometry.activeEnd(240, 4, 1), 238)
    }

    function test_trackStartsAfterMaterialGap() {
        compare(Geometry.trackStart(240, 4, 0.5, 4), 124)
        compare(Geometry.trackStart(240, 4, 1, 4), 238)
    }

    function test_stopIndicatorShrinksNearCompletion() {
        const initial = Geometry.stopIndicator(240, 4, 4, 0.5)
        const nearEnd = Geometry.stopIndicator(240, 4, 4, 0.99)
        const complete = Geometry.stopIndicator(240, 4, 4, 1)

        compare(initial.size, 4)
        compare(initial.center, 238)
        verify(nearEnd.size > 0)
        verify(nearEnd.size < 4)
        compare(complete.size, 0)
    }

    function test_waveUsesConfiguredAmplitudeAndWavelength() {
        fuzzyCompare(Geometry.waveY(0, 5, 3, 40, 0), 5, 0.001)
        fuzzyCompare(Geometry.waveY(10, 5, 3, 40, 0), 8, 0.001)
        fuzzyCompare(Geometry.waveY(30, 5, 3, 40, 0), 2, 0.001)
    }
}

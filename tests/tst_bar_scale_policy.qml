import QtQuick
import QtTest
import "../modules/bar/BarScalePolicy.js" as BarScalePolicy

TestCase {
    name: "BarScalePolicy"

    function test_automaticScaleIsProportionalToBarHeight() {
        compare(BarScalePolicy.contentScale(40, true, 1.3), 40 / 56)
        compare(BarScalePolicy.contentScale(48, true, 1.3), 48 / 56)
        compare(BarScalePolicy.contentScale(56, true, 1.3), 1)
        compare(BarScalePolicy.contentScale(72, true, 1.3), 72 / 56)
        compare(BarScalePolicy.contentScale(80, true, 1.3), 80 / 56)
    }

    function test_automaticScaleClampsToSupportedHeights() {
        compare(BarScalePolicy.contentScale(20, true, 1), 40 / 56)
        compare(BarScalePolicy.contentScale(100, true, 1), 80 / 56)
    }

    function test_manualScaleIgnoresHeightAndClamps() {
        compare(BarScalePolicy.contentScale(40, false, 1.2), 1.2)
        compare(BarScalePolicy.contentScale(80, false, 0.2), 0.8)
        compare(BarScalePolicy.contentScale(56, false, 2), 1.4)
    }

    function test_compactModeModeratelyReducesScale() {
        compare(BarScalePolicy.effectiveScale(56, true, 1, false), 1)
        compare(BarScalePolicy.effectiveScale(56, true, 1, true), 0.94)
        compare(
            BarScalePolicy.effectiveScale(40, true, 1, true),
            (40 / 56) * 0.94
        )
    }

    function test_scaledValuesRespectSafetyLimits() {
        compare(BarScalePolicy.scaled(40, 0.7, 30, 57), 30)
        compare(BarScalePolicy.scaled(40, 1, 30, 57), 40)
        compare(BarScalePolicy.scaled(40, 1.5, 30, 57), 57)
    }
}

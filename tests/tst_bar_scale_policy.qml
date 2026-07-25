import QtQuick
import QtTest
import "../modules/bar/BarScalePolicy.js" as BarScalePolicy

TestCase {
    name: "BarScalePolicy"

    function test_automaticScaleUsesBarHeight() {
        compare(BarScalePolicy.contentScale(40, true, 1.3), 0.8)
        compare(BarScalePolicy.contentScale(56, true, 1.3), 1)
        compare(BarScalePolicy.contentScale(80, true, 1.3), 1.4)
    }

    function test_manualScaleIgnoresHeightAndClamps() {
        compare(BarScalePolicy.contentScale(40, false, 1.2), 1.2)
        compare(BarScalePolicy.contentScale(80, false, 0.2), 0.8)
        compare(BarScalePolicy.contentScale(56, false, 2), 1.4)
    }

    function test_compactModeModeratelyReducesScale() {
        compare(BarScalePolicy.effectiveScale(56, true, 1, false), 1)
        compare(BarScalePolicy.effectiveScale(56, true, 1, true), 0.94)
        compare(BarScalePolicy.effectiveScale(40, true, 1, true), 0.8)
    }

    function test_scaledValuesRespectSafetyLimits() {
        compare(BarScalePolicy.scaled(40, 0.8, 36, 52), 36)
        compare(BarScalePolicy.scaled(40, 1, 36, 52), 40)
        compare(BarScalePolicy.scaled(40, 1.4, 36, 52), 52)
    }

    function test_moderatedScaleRespondsLessThanContent() {
        compare(BarScalePolicy.moderatedScale(1, 0.5), 1)
        compare(BarScalePolicy.moderatedScale(1.4, 0.5), 1.2)
        compare(BarScalePolicy.moderatedScale(0.8, 0.5), 0.9)
    }
}

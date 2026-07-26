import QtQuick
import QtTest
import "../modules/bar/BarLayoutPolicy.js" as BarLayoutPolicy

TestCase {
    name: "BarLayoutPolicy"

    function test_responsiveProfiles() {
        const ultrawide = BarLayoutPolicy.profile(3440)
        const desktop = BarLayoutPolicy.profile(1920)
        const compactDesktop = BarLayoutPolicy.profile(1080)
        const narrow = BarLayoutPolicy.profile(900)
        const veryNarrow = BarLayoutPolicy.profile(700)

        verify(ultrawide.wide)
        verify(desktop.wide)
        verify(!desktop.compact)
        verify(!compactDesktop.wide)
        verify(compactDesktop.compact)
        verify(!compactDesktop.narrow)
        verify(narrow.narrow)
        verify(!narrow.veryNarrow)
        verify(veryNarrow.veryNarrow)
    }

    function test_centerWidthUsesSmallerSideClearance() {
        compare(
            BarLayoutPolicy.centerAvailableWidth(
                1920,
                450,
                350,
                18
            ),
            984
        )
        compare(
            BarLayoutPolicy.centerAvailableWidth(
                1080,
                410,
                260,
                18
            ),
            224
        )
    }

    function test_centerWidthNeverOverlapsSideClusters() {
        compare(
            BarLayoutPolicy.centerAvailableWidth(
                700,
                360,
                250,
                18
            ),
            0
        )
        compare(
            BarLayoutPolicy.centerAvailableWidth(
                0,
                0,
                0,
                18
            ),
            0
        )
    }
}

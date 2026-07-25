import QtQuick
import QtTest
import "../stores/launcher/LauncherSearch.js" as LauncherSearch

TestCase {
    name: "LauncherSearch"

    function test_resultOrderingDoesNotDiscardApplications() {
        const matches = []

        for (var index = 0; index < 30; ++index) {
            matches.push({
                title: "Application "
                    + String(30 - index).padStart(2, "0"),
                score: 1
            })
        }

        const results = LauncherSearch.finalizeResults(matches)

        compare(results.length, 30)
        compare(results[0].title, "Application 01")
        compare(results[29].title, "Application 30")
    }

    function test_higherScoresRemainFirst() {
        const results = LauncherSearch.finalizeResults([
            { title: "Details match", score: 300 },
            { title: "Exact match", score: 1000 },
            { title: "Prefix match", score: 800 }
        ])

        compare(results[0].title, "Exact match")
        compare(results[1].title, "Prefix match")
        compare(results[2].title, "Details match")
    }

    function test_multiTokenMatchingStillWorks() {
        compare(
            LauncherSearch.matchScore(
                "visual studio",
                "Visual Studio Code",
                "Code editor"
            ),
            800
        )
        compare(
            LauncherSearch.matchScore(
                "studio terminal",
                "Visual Studio Code",
                "Code editor"
            ),
            -1
        )
    }
}

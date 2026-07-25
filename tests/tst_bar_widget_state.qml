import QtQuick
import QtTest
import "../modules/control/settings/bar/BarWidgetState.js"
    as BarWidgetState

TestCase {
    name: "BarWidgetState"

    function test_moveActivePreservesHiddenSlots() {
        const order = ["tray", "notifications", "system-status", "dashboard"]
        const active = ["tray", "system-status", "dashboard"]
        const moved = BarWidgetState.moveActive(
            order,
            active,
            "dashboard",
            -1
        )

        compare(
            JSON.stringify(moved),
            JSON.stringify([
                "tray",
                "notifications",
                "dashboard",
                "system-status"
            ])
        )
    }

    function test_moveActiveDoesNotCreateDuplicates() {
        const moved = BarWidgetState.moveActive(
            ["launcher", "overview", "workspaces", "datetime"],
            ["launcher", "workspaces", "datetime"],
            "launcher",
            1
        )

        compare(
            JSON.stringify(moved),
            JSON.stringify([
                "workspaces",
                "overview",
                "launcher",
                "datetime"
            ])
        )
        compare(new Set(moved).size, moved.length)
    }

    function test_addAtEndRejectsUnknownAndMovesKnown() {
        const allowed = ["tray", "notifications", "dashboard"]

        compare(
            JSON.stringify(
                BarWidgetState.addAtEnd(
                    ["dashboard", "tray", "notifications"],
                    "tray",
                    allowed
                )
            ),
            JSON.stringify(["dashboard", "notifications", "tray"])
        )
        compare(
            JSON.stringify(
                BarWidgetState.addAtEnd(
                    ["dashboard", "tray"],
                    "unknown",
                    allowed
                )
            ),
            JSON.stringify(["dashboard", "tray"])
        )
    }

    function test_removedIdsContainsOnlyInactiveWidgets() {
        compare(
            JSON.stringify(
                BarWidgetState.removedIds(
                    ["launcher", "overview", "workspaces"],
                    ["launcher", "workspaces"]
                )
            ),
            JSON.stringify(["overview"])
        )
    }
}


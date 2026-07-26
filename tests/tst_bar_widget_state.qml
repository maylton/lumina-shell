import QtQuick
import QtTest
import "../modules/control/settings/bar/BarWidgetState.js"
    as BarWidgetState

TestCase {
    name: "BarWidgetState"

    function test_moveActivePreservesHiddenSlots() {
        const order = [
            "tray",
            "notifications",
            "network",
            "audio",
            "battery",
            "dashboard"
        ]
        const active = ["tray", "network", "audio", "dashboard"]
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
                "network",
                "dashboard",
                "battery",
                "audio"
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

    function test_moveActiveRespectsBoundaries() {
        const order = ["launcher", "overview", "workspaces"]
        const active = ["launcher", "workspaces"]

        compare(
            JSON.stringify(
                BarWidgetState.moveActive(
                    order, active, "launcher", -1
                )
            ),
            JSON.stringify(order)
        )
        compare(
            JSON.stringify(
                BarWidgetState.moveActive(
                    order, active, "workspaces", 1
                )
            ),
            JSON.stringify(order)
        )
    }

    function test_activeAndRemovedListsHaveNoDuplicates() {
        const order = ["launcher", "launcher", "overview"]
        const active = BarWidgetState.uniqueKnown(
            ["launcher", "launcher"],
            ["launcher", "overview"]
        )

        compare(JSON.stringify(active), JSON.stringify(["launcher"]))
        compare(
            JSON.stringify(
                BarWidgetState.removedIds(
                    ["launcher", "overview"],
                    active
                )
            ),
            JSON.stringify(["overview"])
        )
        compare(
            JSON.stringify(
                BarWidgetState.activeOrder(order, active)
            ),
            JSON.stringify(["launcher"])
        )
    }
}

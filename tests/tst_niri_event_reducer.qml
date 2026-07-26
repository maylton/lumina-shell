import QtQuick
import QtTest
import "../services/niri/NiriEventReducer.js" as NiriEventReducer

TestCase {
    name: "NiriEventReducer"

    function populatedState() {
        return NiriEventReducer.createState(
            [
                {
                    id: 1,
                    idx: 1,
                    output: "DP-1",
                    is_active: true,
                    is_focused: true,
                    is_urgent: false
                },
                {
                    id: 2,
                    idx: 2,
                    output: "DP-1",
                    is_active: false,
                    is_focused: false,
                    is_urgent: false
                }
            ],
            [
                {
                    id: 10,
                    workspace_id: 1,
                    title: "Terminal",
                    is_focused: true,
                    is_urgent: false
                }
            ],
            true
        )
    }

    function test_parseLine() {
        const parsed = NiriEventReducer.parseLine(
            '{"WindowFocusChanged":{"id":10}}'
        )

        verify(parsed.accepted)
        compare(parsed.eventType, "WindowFocusChanged")
        compare(parsed.payload.id, 10)
        compare(parsed.error, "")
    }

    function test_parseLineRejectsInvalidJson() {
        const parsed = NiriEventReducer.parseLine("{not-json")

        verify(!parsed.accepted)
        verify(parsed.error.indexOf("Invalid Niri event JSON") === 0)
    }

    function test_workspaceEventsReduceImmutably() {
        const original = populatedState()
        const result = NiriEventReducer.reduce(
            original,
            "WorkspaceActivated",
            {
                id: 2,
                focused: true
            }
        )

        verify(result.handled)
        compare(original.workspaces[0].is_active, true)
        compare(result.state.workspaces[0].is_active, false)
        compare(result.state.workspaces[0].is_focused, false)
        compare(result.state.workspaces[1].is_active, true)
        compare(result.state.workspaces[1].is_focused, true)
    }

    function test_windowLifecycleReduction() {
        var state = populatedState()

        state = NiriEventReducer.reduce(
            state,
            "WindowOpenedOrChanged",
            {
                window: {
                    id: 11,
                    workspace_id: 2,
                    title: "Browser",
                    is_focused: true
                }
            }
        ).state

        compare(state.windows.length, 2)
        compare(state.windows[0].is_focused, false)
        compare(state.windows[1].title, "Browser")

        state = NiriEventReducer.reduce(
            state,
            "WindowClosed",
            {
                id: 10
            }
        ).state

        compare(state.windows.length, 1)
        compare(state.windows[0].id, 11)
    }

    function test_unknownEventIsIgnored() {
        const original = populatedState()
        const result = NiriEventReducer.reduce(
            original,
            "FutureNiriEvent",
            {
                value: true
            }
        )

        verify(!result.handled)
        compare(result.state.workspaces.length, original.workspaces.length)
        compare(result.state.windows.length, original.windows.length)
        compare(result.state.overviewOpen, original.overviewOpen)
    }

    function test_disconnectClearsCompositorState() {
        const cleared = NiriEventReducer.emptyState()

        compare(cleared.workspaces.length, 0)
        compare(cleared.windows.length, 0)
        compare(cleared.overviewOpen, false)
    }

    function test_initialSynchronizationRequiresAllSnapshots() {
        var sync = NiriEventReducer.initialSyncState()

        verify(!NiriEventReducer.isInitialStateComplete(sync))

        sync = NiriEventReducer.markInitialSnapshot(
            sync,
            "WorkspacesChanged"
        )
        verify(!NiriEventReducer.isInitialStateComplete(sync))

        sync = NiriEventReducer.markInitialSnapshot(sync, "WindowsChanged")
        verify(!NiriEventReducer.isInitialStateComplete(sync))

        sync = NiriEventReducer.markInitialSnapshot(sync, "OutputsSnapshot")
        verify(NiriEventReducer.isInitialStateComplete(sync))
    }

    function test_reconnectBackoffIsBounded() {
        compare(NiriEventReducer.reconnectDelay(1), 1000)
        compare(NiriEventReducer.reconnectDelay(2), 2000)
        compare(NiriEventReducer.reconnectDelay(3), 4000)
        compare(NiriEventReducer.reconnectDelay(5), 15000)
        compare(NiriEventReducer.reconnectDelay(20), 15000)
    }
}

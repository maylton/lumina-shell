import QtQuick
import QtTest
import "../stores/dock/DockModel.js" as DockModel

TestCase {
    name: "DockModel"

    function test_normalizesDesktopIdentifiers() {
        compare(DockModel.normalizeIdentifier("Firefox.desktop"), "firefox")
        compare(
            DockModel.normalizeIdentifier(" org.kde.dolphin.desktop "),
            "org.kde.dolphin"
        )
    }

    function test_groupsWindowsByApplication() {
        const groups = DockModel.groupWindows([
            { id: 10, app_id: "firefox", is_focused: true },
            { id: 11, app_id: "firefox", is_urgent: true },
            { id: 20, app_id: "org.kde.dolphin" }
        ])

        compare(groups.length, 2)
        compare(groups[0].windowIds.length, 2)
        compare(groups[0].focused, true)
        compare(groups[0].urgent, true)
        compare(groups[1].appId, "org.kde.dolphin")
    }

    function test_cyclesAcrossApplicationWindows() {
        compare(DockModel.nextWindowId([10, 11, 12], 10), 11)
        compare(DockModel.nextWindowId([10, 11, 12], 12), 10)
        compare(DockModel.nextWindowId([10, 11, 12], 99), 10)
        compare(DockModel.nextWindowId([], 10), null)
    }
}

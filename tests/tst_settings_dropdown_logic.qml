import QtQuick
import QtTest
import "../modules/control/settings/SettingsDropdownLogic.js" as DropdownLogic

TestCase {
    name: "SettingsDropdownLogic"

    function test_initialIndexUsesSelectionOrFirstOption() {
        compare(DropdownLogic.initialIndex(2, 4), 2)
        compare(DropdownLogic.initialIndex(-1, 4), 0)
        compare(DropdownLogic.initialIndex(4, 4), 0)
        compare(DropdownLogic.initialIndex(-1, 0), -1)
    }

    function test_keyboardNavigationWraps() {
        compare(DropdownLogic.offsetIndex(0, -1, 3), 2)
        compare(DropdownLogic.offsetIndex(2, 1, 3), 0)
        compare(DropdownLogic.offsetIndex(1, 1, 3), 2)
    }

    function test_secondToggleDuringEnterRequestsClose() {
        compare(
            DropdownLogic.desiredOpenAfterToggle(true, false),
            false
        )
    }

    function test_toggleDuringExitRequestsReopen() {
        compare(
            DropdownLogic.desiredOpenAfterToggle(false, false),
            true
        )
        compare(
            DropdownLogic.shouldReopenAfterClose(true),
            true
        )
    }

    function test_popupFlipsAboveWhenNeeded() {
        compare(
            DropdownLogic.popupY(100, 20, 140, 600, 14),
            100
        )
        compare(
            DropdownLogic.popupY(500, 330, 140, 600, 14),
            330
        )
    }
}

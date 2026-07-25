import QtQuick
import QtTest
import "../modules/control/settings/bar/BarWidgetCatalog.js"
    as BarWidgetCatalog

TestCase {
    name: "BarWidgetCatalog"

    function test_catalogHasUniqueKnownWidgets() {
        const entries = BarWidgetCatalog.all()
        const ids = entries.map(entry => entry.id)

        compare(entries.length, 11)
        compare(new Set(ids).size, entries.length)
        verify(ids.indexOf("privacy") < 0)
        verify(ids.indexOf("keyboard") < 0)
    }

    function test_eachEntryHasSettingsMetadata() {
        const entries = BarWidgetCatalog.all()

        for (var index = 0; index < entries.length; ++index) {
            const entry = entries[index]

            verify(entry.title.length > 0)
            verify(entry.description.length > 0)
            verify(entry.icon.length > 0)
            verify(["left", "center", "right"]
                .indexOf(entry.side) >= 0)
            verify(entry.component.length > 0)
            verify(Object.keys(entry.defaults).length > 0)
        }
    }

    function test_contextIsTheOnlyCenterWidget() {
        compare(
            JSON.stringify(BarWidgetCatalog.idsForSide("center")),
            JSON.stringify(["context"])
        )
    }
}


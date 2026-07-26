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

    function test_individualResetPreservesOtherWidgets() {
        const configured = BarWidgetCatalog.defaultSettings()
        configured.context.timeout = 12000
        configured.tray.mode = "inline"
        const reset = BarWidgetCatalog.withReset(
            configured,
            "context"
        )

        compare(reset.context.timeout, 3500)
        compare(reset.context.mode, "contextual")
        compare(reset.tray.mode, "inline")
        compare(configured.context.timeout, 12000)
    }

    function test_individualUpdateIsImmutable() {
        const configured = BarWidgetCatalog.defaultSettings()
        const updated = BarWidgetCatalog.withSetting(
            configured,
            "launcher",
            "showLabel",
            true
        )

        compare(configured.launcher.showLabel, false)
        compare(updated.launcher.showLabel, true)
        verify(updated !== configured)
        verify(updated.launcher !== configured.launcher)
        compare(
            JSON.stringify(updated.tray),
            JSON.stringify(configured.tray)
        )
    }
}

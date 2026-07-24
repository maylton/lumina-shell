pragma Singleton

import QtQml
import Quickshell
import qs.stores.shell

Singleton {
    id: root

    readonly property var locale: Qt.locale()
    readonly property date currentDate: systemClock.date
    readonly property string formattedTime: Qt.formatDateTime(currentDate, "HH:mm")
    readonly property string todayKey: dateKey(currentDate)
    readonly property int firstDayOfWeek: Number(locale.firstDayOfWeek)
    readonly property var weekdayLabels: buildWeekdayLabels(locale, firstDayOfWeek)
    readonly property string monthTitle: buildMonthTitle(visibleYear, visibleMonth, locale)
    readonly property var monthCells: buildMonthCells(
        visibleYear,
        visibleMonth,
        firstDayOfWeek,
        todayKey,
        selectedDateKey
    )
    readonly property bool showingCurrentMonth: visibleYear === currentDate.getFullYear()
        && visibleMonth === currentDate.getMonth()
    readonly property bool open: activeOutputName.length > 0

    property string activeOutputName: ""
    property int visibleYear: currentDate.getFullYear()
    property int visibleMonth: currentDate.getMonth()
    property string selectedDateKey: todayKey
    property string recentlyDismissedOutput: ""
    property double recentlyDismissedAt: 0

    function dateKey(value) {
        if (!value)
            return ""

        const year = value.getFullYear()
        const month = String(value.getMonth() + 1).padStart(2, "0")
        const day = String(value.getDate()).padStart(2, "0")
        return year + "-" + month + "-" + day
    }

    function buildWeekdayLabels(calendarLocale, weekStart) {
        const labels = []

        for (var index = 0; index < 7; ++index) {
            const dayOfWeek = ((weekStart - 1 + index) % 7) + 1
            labels.push(calendarLocale.standaloneDayName(dayOfWeek, Locale.ShortFormat))
        }

        return labels
    }

    function buildMonthTitle(year, month, calendarLocale) {
        const monthName = calendarLocale.standaloneMonthName(month + 1, Locale.LongFormat)
        return monthName + " " + year
    }

    function buildMonthCells(year, month, weekStart, currentKey, selectedKey) {
        const cells = []
        const firstDate = new Date(year, month, 1)
        const firstIsoDay = firstDate.getDay() === 0 ? 7 : firstDate.getDay()
        const leadingCells = (firstIsoDay - weekStart + 7) % 7
        const daysInMonth = new Date(year, month + 1, 0).getDate()

        for (var index = 0; index < 42; ++index) {
            const day = index - leadingCells + 1
            const enabled = day > 0 && day <= daysInMonth
            const key = enabled ? dateKey(new Date(year, month, day)) : ""

            cells.push({
                day: enabled ? day : 0,
                enabled: enabled,
                isToday: enabled && key === currentKey,
                isSelected: enabled && key === selectedKey
            })
        }

        return cells
    }

    function isOpenFor(outputName) {
        return open && activeOutputName === String(outputName)
    }

    function outputExists(outputName) {
        const name = String(outputName || "")
        const screens = Quickshell.screens || []

        for (var i = 0; i < screens.length; ++i) {
            if (String(screens[i].name || "") === name)
                return true
        }

        return false
    }

    function openFor(outputName) {
        const name = String(outputName)

        if (!name)
            return

        goToToday()
        activeOutputName = name
    }

    function toggle(outputName) {
        const name = String(outputName)
        const dismissedRecently = recentlyDismissedOutput === name
            && Date.now() - recentlyDismissedAt < 250

        if (!isOpenFor(name) && dismissedRecently)
            return

        if (isOpenFor(name))
            close()
        else
            openFor(name)
    }

    function dismiss(outputName) {
        const name = String(outputName)

        if (activeOutputName === name)
            activeOutputName = ""

        recentlyDismissedOutput = name
        recentlyDismissedAt = Date.now()
    }

    function close() {
        activeOutputName = ""
    }

    function showPreviousMonth() {
        const previous = new Date(visibleYear, visibleMonth - 1, 1)
        visibleYear = previous.getFullYear()
        visibleMonth = previous.getMonth()
    }

    function showNextMonth() {
        const next = new Date(visibleYear, visibleMonth + 1, 1)
        visibleYear = next.getFullYear()
        visibleMonth = next.getMonth()
    }

    function goToToday() {
        visibleYear = currentDate.getFullYear()
        visibleMonth = currentDate.getMonth()
        selectedDateKey = todayKey
    }

    function selectDay(day) {
        selectedDateKey = dateKey(new Date(visibleYear, visibleMonth, day))
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Connections {
        target: Quickshell

        function onScreensChanged() {
            if (root.open && !root.outputExists(root.activeOutputName))
                root.close()
        }
    }

    Connections {
        target: OverlayStore

        function onActiveSurfaceChanged() {
            if (OverlayStore.open)
                root.close()
        }
    }
}

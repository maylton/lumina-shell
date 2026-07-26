import QtQuick
import QtTest
import "../services/notifications/NotificationModel.js" as NotificationModel

TestCase {
    name: "NotificationModel"

    function fakeNotification() {
        return {
            id: 42,
            appName: "Mail",
            summary: "New message",
            body: "Hello",
            urgency: 1,
            actions: [
                {
                    text: "Open",
                    invoke: function() {}
                },
                {
                    text: "Dismiss",
                    invoke: function() {}
                }
            ],
            expireTimeout: 5000,
            resident: false,
            transient: false
        }
    }

    function test_snapshotContainsOnlyPresentationData() {
        const notification = fakeNotification()
        const entry = NotificationModel.presentationEntry(
            notification,
            "42-1",
            "mail-unread",
            false,
            1234
        )

        compare(entry.key, "42-1")
        compare(entry.notificationId, 42)
        compare(entry.actionLabels, ["Open", "Dismiss"])
        verify(entry.notification === undefined)
        verify(entry.actions === undefined)
        verify(entry.actionLabels[0] !== notification.actions[0])
    }

    function test_modelUsesScalarKeys() {
        const entries = [
            NotificationModel.presentationEntry(
                fakeNotification(),
                "42-1",
                "mail-unread",
                false,
                1234
            )
        ]

        compare(NotificationModel.entryKeys(entries), ["42-1"])
        compare(
            NotificationModel.entryForKey(entries, [], "42-1").summary,
            "New message"
        )
    }

    function test_markReadDoesNotReplaceRows() {
        const entry = NotificationModel.presentationEntry(
            fakeNotification(),
            "42-1",
            "mail-unread",
            false,
            1234
        )
        const entries = [entry]

        verify(NotificationModel.markAllRead(entries))
        verify(entry.read)
        compare(entries[0], entry)
        compare(NotificationModel.unreadCount(entries), 0)
        verify(!NotificationModel.markAllRead(entries))
    }

    function test_copyRemainsDetachedFromNativeActions() {
        const entry = NotificationModel.presentationEntry(
            fakeNotification(),
            "42-1",
            "mail-unread",
            false,
            1234
        )
        const copy = NotificationModel.copyEntry(entry, { closed: true })

        verify(copy.closed)
        compare(copy.actionLabels, entry.actionLabels)
        verify(copy.actionLabels !== entry.actionLabels)
    }
}

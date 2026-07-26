#!/usr/bin/env python3
from pathlib import Path

PATH = Path("modules/notifications/NotificationCenter.qml")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"{label}: expected exactly one match, found {count}")
    return text.replace(old, new, 1)


def main() -> None:
    text = PATH.read_text(encoding="utf-8")
    if '"notifications.center.title"' in text:
        print("Notification center translations already applied.")
        return

    text = replace_once(
        text,
        "import qs.services.notifications\n",
        "import qs.services.i18n\nimport qs.services.notifications\n",
        "i18n import",
    )
    text = replace_once(
        text,
        '                                    text: "Notifications"',
        '''                                    text: I18n.tr(
                                        "notifications.center.title",
                                        "Notifications"
                                    )''',
        "title",
    )
    text = replace_once(
        text,
        '''                                    text: NotificationService.history.length
                                        === 0
                                        ? "All caught up"
                                        : NotificationService.history.length
                                            + (
                                                NotificationService.history.length
                                                    === 1
                                                    ? " recent notification"
                                                    : " recent notifications"
                                            )''',
        '''                                    text: NotificationService.history.length
                                        === 0
                                        ? I18n.tr(
                                            "notifications.center.allCaughtUp",
                                            "All caught up"
                                        )
                                        : NotificationService.history.length === 1
                                            ? I18n.tr(
                                                "notifications.center.recent.one",
                                                "%1 recent notification",
                                                [NotificationService.history.length]
                                            )
                                            : I18n.tr(
                                                "notifications.center.recent.other",
                                                "%1 recent notifications",
                                                [NotificationService.history.length]
                                            )''',
        "history summary",
    )
    text = replace_once(
        text,
        '                                    Accessible.name: "Do Not Disturb"',
        '''                                    Accessible.name: I18n.tr(
                                        "notifications.center.dnd",
                                        "Do Not Disturb"
                                    )''',
        "DND accessibility",
    )
    text = replace_once(
        text,
        '                                            text: "DND"',
        '''                                            text: I18n.tr(
                                                "notifications.center.dndShort",
                                                "DND"
                                            )''',
        "DND label",
    )
    text = replace_once(
        text,
        '''                                    Accessible.name:
                                        "Clear notification history"''',
        '''                                    Accessible.name: I18n.tr(
                                        "notifications.center.clearAccessible",
                                        "Clear notification history"
                                    )''',
        "clear accessibility",
    )
    text = replace_once(
        text,
        '                                        text: "Clear"',
        '''                                        text: I18n.tr(
                                            "notifications.center.clear",
                                            "Clear"
                                        )''',
        "clear label",
    )
    text = replace_once(
        text,
        '''                                    text: NotificationService.doNotDisturb
                                        ? "Quiet mode is on"
                                        : "All caught up"''',
        '''                                    text: NotificationService.doNotDisturb
                                        ? I18n.tr(
                                            "notifications.center.quietTitle",
                                            "Quiet mode is on"
                                        )
                                        : I18n.tr(
                                            "notifications.center.allCaughtUp",
                                            "All caught up"
                                        )''',
        "empty title",
    )
    text = replace_once(
        text,
        '''                                    text: NotificationService.doNotDisturb
                                        ? "New notifications stay in history "
                                            + "without interrupting you"
                                        : "New notifications will appear here"''',
        '''                                    text: NotificationService.doNotDisturb
                                        ? I18n.tr(
                                            "notifications.center.quietDescription",
                                            "New notifications stay in history without interrupting you"
                                        )
                                        : I18n.tr(
                                            "notifications.center.emptyDescription",
                                            "New notifications will appear here"
                                        )''',
        "empty description",
    )

    PATH.write_text(text, encoding="utf-8")
    print("Notification center translations applied.")


if __name__ == "__main__":
    main()

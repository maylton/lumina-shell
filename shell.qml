//@ pragma UseQApplication

import Quickshell
import qs.services
import qs.modules.bar
import qs.modules.launcher
import qs.modules.notifications
import qs.modules.session
import qs.modules.wallpaper

ShellRoot {
    DailyServices {}
    Wallpaper {}
    WallpaperPicker {}
    Bar {}
    Launcher {}
    NotificationPopups {}
    NotificationCenter {}
    SessionMenu {}
}

//@ pragma UseQApplication

import Quickshell
import qs.services
import qs.modules.bar
import qs.modules.bluetooth
import qs.modules.control
import qs.modules.dock
import qs.modules.launcher
import qs.modules.notifications
import qs.modules.osd
import qs.modules.polkit
import qs.modules.settings
import qs.modules.session
import qs.modules.wallpaper

ShellRoot {
    DailyServices {}
    Wallpaper {}
    WallpaperPicker {}
    Bar {}
    Dock {}
    ControlCenter {}
    Launcher {}
    NotificationPopups {}
    NotificationCenter {}
    Osd {}
    Settings {}
    SessionMenu {}
    BluetoothPairingDialog {}
    PolkitDialog {}
}

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.stores.settings

Scope {
    IpcHandler {
        target: "settings"

        function open(outputName: string): void {
            SettingsStore.openFor(outputName)
        }

        function openCategory(
            categoryName: string,
            outputName: string
        ): void {
            SettingsStore.openCategory(categoryName, outputName)
        }

        function category(categoryName: string): void {
            SettingsStore.setCategory(categoryName)
        }

        function close(): void {
            SettingsStore.close()
        }

        function toggle(outputName: string): void {
            SettingsStore.toggle(outputName)
        }

        function status(): string {
            return JSON.stringify({
                open: SettingsStore.open,
                output: SettingsStore.activeOutputName,
                category: SettingsStore.activeCategory,
                resetConfirmation: SettingsStore.resetConfirmation
            })
        }
    }
}

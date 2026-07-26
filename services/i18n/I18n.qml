pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "I18n.js" as I18nLogic
import "AppearanceMessages.js" as AppearanceMessages
import "BarMessages.js" as BarMessages

Singleton {
    id: root

    readonly property string sourceLocale: "en-US"
    readonly property var availableLocales: [
        "en-US",
        "pt-BR"
    ]
    readonly property string requestedLocale: String(
        Quickshell.env("LUMINA_LOCALE")
            || Qt.locale().name
            || sourceLocale
    )
    readonly property string locale:
        resolveLocale(requestedLocale)
    readonly property string catalogPath:
        Quickshell.shellPath("i18n/" + locale + ".json")

    property var messages: ({})
    property bool loaded: false
    property string lastError: ""

    function normalizedLocale(value) {
        return I18nLogic.normalizedLocale(value)
    }

    function resolveLocale(value) {
        return I18nLogic.resolveLocale(
            value,
            availableLocales,
            sourceLocale
        )
    }

    function interpolate(value, replacements) {
        return I18nLogic.interpolate(value, replacements)
    }

    function tr(messageId, fallback, replacements) {
        const key = String(messageId || "")
        const catalogValue = messages
            && typeof messages[key] === "string"
            ? messages[key]
            : ""
        const supplementalValue = AppearanceMessages.message(locale, key)
            || BarMessages.message(locale, key)
        const sourceValue = catalogValue
            || supplementalValue
            || String(fallback || key)

        return interpolate(sourceValue, replacements)
    }

    function loadCatalog(rawText) {
        try {
            const parsed = JSON.parse(String(rawText || "{}"))

            if (!parsed
                || Array.isArray(parsed)
                || typeof parsed !== "object") {
                throw new Error("catalog root must be an object")
            }

            messages = parsed
            loaded = true
            lastError = ""
        } catch (error) {
            messages = ({})
            loaded = false
            lastError = String(error)
            console.warn(
                "Lumina i18n:",
                locale,
                lastError
            )
        }
    }

    FileView {
        id: catalogFile

        path: root.catalogPath
        preload: true
        watchChanges: true
        printErrors: false

        onLoaded: root.loadCatalog(text())
        onFileChanged: reload()
        onLoadFailed: error => {
            root.messages = ({})
            root.loaded = false
            root.lastError = FileViewError.toString(error)
        }
    }

    IpcHandler {
        target: "i18n"

        function reload(): void {
            catalogFile.reload()
        }

        function status(): string {
            return JSON.stringify({
                requestedLocale: root.requestedLocale,
                locale: root.locale,
                sourceLocale: root.sourceLocale,
                availableLocales: root.availableLocales,
                catalogPath: root.catalogPath,
                loaded: root.loaded,
                error: root.lastError
            })
        }
    }
}

import QtQuick
import QtTest
import "../services/i18n/LauncherStrings.js" as LauncherStrings
import "../services/i18n/RuntimeMessages.js" as RuntimeMessages
import "../services/i18n/SettingsStrings.js" as SettingsStrings

TestCase {
    name: "SupplementalI18n"

    function test_launcherStringsUseBrazilianPortuguese() {
        compare(
            LauncherStrings.text("pt-BR", "allApps"),
            "Todos os aplicativos"
        )
        compare(
            LauncherStrings.text("pt-BR", "kindWindow"),
            "Janela"
        )
        compare(
            LauncherStrings.text("pt-BR", "toggleFullscreenTitle"),
            "Alternar tela cheia"
        )
    }

    function test_launcherStringsFallBackToEnglish() {
        compare(
            LauncherStrings.text("en-US", "allApps"),
            "All apps"
        )
        compare(
            LauncherStrings.text("fr-FR", "kindAction"),
            "Action"
        )
    }

    function test_settingsRestartFeedbackIsLocalized() {
        compare(
            SettingsStrings.text("pt-BR", "restart"),
            "Reiniciar"
        )
        compare(
            SettingsStrings.text("pt-BR", "restartRequired"),
            "Reinicialização necessária"
        )
    }

    function test_audioPanelUsesBrazilianPortuguese() {
        compare(
            RuntimeMessages.message(
                "pt-BR",
                "bar.audio.section.applications"
            ),
            "Aplicativos"
        )
        compare(
            RuntimeMessages.message("pt-BR", "bar.audio.mute"),
            "Silenciar"
        )
    }

    function test_notificationsUseLiteralDoNotDisturbTranslation() {
        compare(
            RuntimeMessages.message(
                "pt-BR",
                "notifications.center.dndShort"
            ),
            "Não perturbe"
        )
    }
}

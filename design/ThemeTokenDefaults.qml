pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    readonly property var tokens: Theme.luminaTokens
    readonly property bool defaultsApplied: applyDefaults(tokens)

    objectName: defaultsApplied ? "ThemeTokenDefaults" : ""

    function applyDefaults(tokenSet) {
        if (!tokenSet || !tokenSet.typography)
            return false

        const typography = tokenSet.typography

        if (typeof typography.titleSmall !== "number") {
            typography.titleSmall = Math.max(
                1,
                Number(typography.titleMedium || 14) - 1
            )
        }

        if (typeof typography.bodyLarge !== "number") {
            typography.bodyLarge = Math.max(
                1,
                Number(typography.bodyMedium || 13) + 2
            )
        }

        return true
    }
}

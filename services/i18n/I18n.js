.pragma library

function normalizedLocale(value) {
    let normalized = String(value || "")
        .trim()
        .replace(/_/g, "-")
    const suffixIndex = normalized.search(/[.@]/)

    if (suffixIndex >= 0)
        normalized = normalized.slice(0, suffixIndex)

    return normalized
}

function resolveLocale(value, availableLocales, sourceLocale) {
    const normalized = normalizedLocale(value)
    const lower = normalized.toLowerCase()

    for (let index = 0; index < availableLocales.length; ++index) {
        const candidate = String(availableLocales[index])

        if (candidate.toLowerCase() === lower)
            return candidate
    }

    const language = lower.split("-")[0]

    for (let index = 0; index < availableLocales.length; ++index) {
        const candidate = String(availableLocales[index])

        if (candidate.toLowerCase().split("-")[0] === language)
            return candidate
    }

    return sourceLocale
}

function interpolate(value, replacements) {
    let result = String(value || "")
    const values = replacements === undefined
        ? []
        : Array.isArray(replacements)
            ? replacements
            : [replacements]

    for (let index = 0; index < values.length; ++index) {
        result = result.replace(
            new RegExp("%" + (index + 1), "g"),
            String(values[index])
        )
    }

    return result
}

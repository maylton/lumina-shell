.pragma library

function normalizedText(value) {
    return String(value || "").toLocaleLowerCase().trim()
}

function searchableText(parts) {
    return normalizedText(
        parts.filter(part => Boolean(part)).join(" ")
    )
}

function matchScore(needle, title, details) {
    if (!needle)
        return 1

    var titleText = normalizedText(title)
    var detailText = normalizedText(details)
    var haystack = titleText + " " + detailText
    var tokens = needle.split(/\s+/)

    for (var index = 0; index < tokens.length; ++index) {
        if (haystack.indexOf(tokens[index]) < 0)
            return -1
    }

    if (titleText === needle)
        return 1000

    if (titleText.indexOf(needle) === 0)
        return 800

    if (titleText.indexOf(needle) >= 0)
        return 600

    return 300
}

function wrappedIndex(index, offset, length) {
    var count = Math.max(0, Number(length) || 0)
    if (count === 0)
        return 0

    var requested = (Number(index) || 0) + (Number(offset) || 0)
    return ((requested % count) + count) % count
}

function finalizeResults(matches) {
    var results = matches ? matches.slice() : []

    results.sort((left, right) => {
        if (left.score !== right.score)
            return right.score - left.score

        return left.title.localeCompare(right.title)
    })

    return results
}

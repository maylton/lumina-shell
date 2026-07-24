pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property var outputs: []

    readonly property int count: outputs.length

    function cloneObject(source) {
        const result = {}

        if (!source)
            return result

        for (const key in source)
            result[key] = source[key]

        return result
    }

    function normalizeOutput(name, source) {
        const output = cloneObject(source)

        if (!output.name)
            output.name = String(name)

        return output
    }

    function sortOutputs(items) {
        return items.sort((left, right) => {
            const leftLogical = left.logical || {}
            const rightLogical = right.logical || {}
            const leftX = leftLogical.x !== undefined ? Number(leftLogical.x) : Number.MAX_SAFE_INTEGER
            const rightX = rightLogical.x !== undefined ? Number(rightLogical.x) : Number.MAX_SAFE_INTEGER

            if (leftX !== rightX)
                return leftX - rightX

            return String(left.name).localeCompare(String(right.name))
        })
    }

    function replaceMap(outputMap) {
        const next = []

        if (outputMap) {
            for (const name in outputMap)
                next.push(normalizeOutput(name, outputMap[name]))
        }

        outputs = sortOutputs(next)
    }

    function replace(items) {
        const next = []

        if (items) {
            for (var i = 0; i < items.length; ++i) {
                const output = items[i]
                if (output)
                    next.push(normalizeOutput(output.name || i, output))
            }
        }

        outputs = sortOutputs(next)
    }

    function byName(name) {
        if (!name)
            return null

        for (var i = 0; i < outputs.length; ++i) {
            if (outputs[i].name === name)
                return outputs[i]
        }

        return null
    }

    function currentMode(output) {
        if (!output || output.current_mode === undefined || output.current_mode === null)
            return null

        if (!output.modes || output.current_mode < 0 || output.current_mode >= output.modes.length)
            return null

        return output.modes[output.current_mode]
    }

    function resolutionLabel(output) {
        const mode = currentMode(output)

        if (!mode)
            return "Disconnected"

        const width = mode.width !== undefined ? mode.width : "?"
        const height = mode.height !== undefined ? mode.height : "?"
        return width + "×" + height
    }

    function scaleLabel(output) {
        if (!output || !output.logical || output.logical.scale === undefined)
            return ""

        return Number(output.logical.scale).toFixed(2).replace(/\.00$/, "") + "×"
    }

    function loadDemo() {
        replaceMap({
            demo: {
                name: "demo",
                make: "Lumina",
                model: "Demo Output",
                serial: "DEMO-01",
                current_mode: 0,
                modes: [
                    {
                        width: 1920,
                        height: 1080,
                        refresh_rate: 60000
                    }
                ],
                logical: {
                    x: 0,
                    y: 0,
                    width: 1920,
                    height: 1080,
                    scale: 1.0,
                    transform: "Normal"
                },
                vrr_supported: false,
                vrr_enabled: false
            }
        })
    }
}

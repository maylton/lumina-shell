import QtQuick
import QtTest
import "../modules/control/ShellSurfacePolicy.js" as ShellSurfacePolicy

TestCase {
    name: "ShellSurfacePolicy"

    function test_onlyEffectStylesRequestBlur() {
        verify(!ShellSurfacePolicy.requestsBackdropBlur("solid"))
        verify(ShellSurfacePolicy.requestsBackdropBlur("blur"))
        verify(ShellSurfacePolicy.requestsBackdropBlur("frosted"))
        verify(!ShellSurfacePolicy.requestsBackdropBlur("invalid"))
    }

    function test_invalidModeUsesSolidFallback() {
        compare(ShellSurfacePolicy.normalizeMode("invalid"), "solid")
        compare(ShellSurfacePolicy.baseAlpha("invalid"), 1)
    }

    function test_configuredOpacityIsClamped() {
        compare(ShellSurfacePolicy.configuredOpacity(0), 0.55)
        compare(ShellSurfacePolicy.configuredOpacity(2), 0.95)
        compare(ShellSurfacePolicy.configuredOpacity(0.82), 0.82)
    }

    function test_frostedIsRicherThanCleanBlur() {
        const blur = ShellSurfacePolicy.tintAlpha("blur", 0.82, false)
        const frosted = ShellSurfacePolicy.tintAlpha(
  "frosted", 0.82, false
        )

        verify(blur > 0 && blur < 1)
        verify(frosted > blur && frosted < 1)
        compare(ShellSurfacePolicy.highlightAlpha("blur", false), 0)
        verify(ShellSurfacePolicy.highlightAlpha("frosted", false) > 0)
        compare(ShellSurfacePolicy.grainAlpha("blur", false), 0)
        verify(ShellSurfacePolicy.grainAlpha("frosted", false) > 0)
    }

    function test_renderedCompositionRemainsReadable() {
        verify(ShellSurfacePolicy.renderedCompositeAlpha(
            "blur", 0.55, true
        ) >= 0.52)
        verify(ShellSurfacePolicy.renderedCompositeAlpha(
            "blur", 0.55, false
        ) >= 0.52)
        verify(ShellSurfacePolicy.renderedCompositeAlpha(
            "frosted", 0.55, false
        ) >= 0.60)
    }
}

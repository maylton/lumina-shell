pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.design
import qs.stores.system

Item {
    id: root

    property real avatarSize: 36
    property real borderWidth: 1
    property color borderColor: luminaDesign.color.primary
    property var candidates: SystemInfoStore.avatarCandidates

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool imageReady:
        avatarImage.status === Image.Ready
    readonly property string fallbackText:
        SystemInfoStore.userInitial.length > 0
            ? SystemInfoStore.userInitial
            : "L"

    property int candidateIndex: 0

    implicitWidth: avatarSize
    implicitHeight: avatarSize

    function sourceUrl(path) {
        const value = String(path || "").trim()

        if (!value)
            return ""

        if (/^[a-z][a-z0-9+.-]*:/i.test(value))
            return value

        return "file://" + encodeURI(value)
    }

    function resetCandidate() {
        candidateIndex = 0
    }

    function advanceCandidate() {
        if (candidateIndex + 1 < candidates.length) {
            candidateIndex += 1
        } else {
            candidateIndex = candidates.length
        }
    }

    onCandidatesChanged: resetCandidate()

    ClippingRectangle {
        anchors.fill: parent
        radius: root.luminaDesign.shape.full
        color: root.luminaDesign.color.accentContainer
        border.width: root.borderWidth
        border.color: root.borderColor
        contentUnderBorder: true

        Image {
            id: avatarImage

            anchors.fill: parent
            source: root.candidateIndex < root.candidates.length
                ? root.sourceUrl(
                    root.candidates[root.candidateIndex]
                )
                : ""
            asynchronous: true
            cache: true
            fillMode: Image.PreserveAspectCrop
            visible: root.imageReady
            sourceSize.width: Math.round(root.avatarSize * 2)
            sourceSize.height: Math.round(root.avatarSize * 2)
            onStatusChanged: {
                if (status === Image.Error)
                    root.advanceCandidate()
            }
        }

        Text {
            anchors.centerIn: parent
            visible: !root.imageReady
            text: root.fallbackText
            color: root.luminaDesign.color.onAccentContainer
            font.pixelSize: Math.round(root.avatarSize * 0.42)
            font.weight: Font.Bold
        }
    }
}

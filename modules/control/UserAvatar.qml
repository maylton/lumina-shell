pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import Quickshell.Widgets
import qs.design
import qs.stores.config
import qs.stores.system

Item {
    id: root

    property real avatarSize: 36
    property real borderWidth: 1
    property color borderColor: luminaDesign.color.primary

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property string customAvatarPath:
        ConfigStore.dashboardUserAvatarPath
    readonly property var candidates: {
        if (!ConfigStore.dashboardUseUserAvatarImage)
            return []

        const result = []
        const systemCandidates = SystemInfoStore.avatarCandidates

        for (var index = 0;
            index < systemCandidates.length;
            ++index) {
            result.push(systemCandidates[index])
        }

        if (customAvatarAvailable
            && result.indexOf(customAvatarPath) < 0) {
            result.push(customAvatarPath)
        }

        return result
    }
    readonly property bool imageReady:
        avatarImage.status === Image.Ready
    readonly property string fallbackText:
        SystemInfoStore.userName !== "User"
            && SystemInfoStore.userInitial.length > 0
            ? SystemInfoStore.userInitial
            : "L"

    property int candidateIndex: 0
    property bool customAvatarAvailable: false

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

    function localPath(source) {
        const value = String(source || "")

        if (value.indexOf("file://") === 0)
            return decodeURIComponent(value.slice(7))

        return /^[a-z][a-z0-9+.-]*:/i.test(value)
            ? ""
            : value
    }

    function advanceCandidate() {
        if (candidateIndex + 1 < candidates.length) {
            candidateIndex += 1
        } else {
            candidateIndex = candidates.length
        }
    }

    onCandidatesChanged: resetCandidate()

    FileView {
        id: customAvatarFile

        path: root.localPath(root.customAvatarPath)
        preload: ConfigStore.dashboardUseUserAvatarImage
            && path.length > 0
        printErrors: false
        onPathChanged: root.customAvatarAvailable = false
        onLoaded: root.customAvatarAvailable = true
        onLoadFailed: error =>
            root.customAvatarAvailable = false
    }

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

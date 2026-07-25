pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.media
import qs.stores.control

DashboardCard {
    id: root

    function formatDuration(seconds) {
        const value = Math.max(0, Math.floor(Number(seconds || 0)))
        const minutes = Math.floor(value / 60)
        const remainingSeconds = value % 60

        return minutes + ":" + String(remainingSeconds).padStart(2, "0")
    }

    accessibleName: MediaService.hasSession
        ? MediaService.playbackLabel + ": " + MediaService.title
        : MediaService.playbackLabel

    Row {
        id: mediaLayout

        anchors {
            fill: parent
            margins: root.luminaDesign.spacing.controlContentInset
        }

        spacing: root.luminaDesign.spacing.controlItemGap

        Rectangle {
            id: albumArt

            width: height
            height: mediaLayout.height
            radius: root.luminaDesign.shape.large
            color: root.luminaDesign.color.surfaceMuted
            clip: true

            Image {
                anchors.fill: parent
                source: MediaService.artUrl
                fillMode: Image.PreserveAspectCrop
                visible: MediaService.hasSession
                    && MediaService.artUrl.length > 0
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                visible: !MediaService.hasSession
                    || MediaService.artUrl.length === 0
                text: "♪"
                color: root.luminaDesign.color.primary
                font.pixelSize: 42
                font.weight: Font.Bold
            }
        }

        Item {
            width: mediaLayout.width - albumArt.width - mediaLayout.spacing
            height: mediaLayout.height

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                spacing: root.luminaDesign.spacing.extraSmall

                Text {
                    width: parent.width
                    text: MediaService.hasSession
                        ? MediaService.title
                        : "Nothing playing"
                    color: root.luminaDesign.color.onSurface
                    elide: Text.ElideRight
                    font.pixelSize: root.luminaDesign.typography.titleMedium
                    font.weight: Font.Bold
                }

                Text {
                    width: parent.width
                    text: MediaService.hasSession
                        ? MediaService.playbackLabel + " · "
                            + (MediaService.artist || MediaService.identity)
                        : MediaService.available
                            ? MediaService.identity + " is idle"
                            : "No MPRIS player detected"
                    color: root.luminaDesign.color.textMuted
                    elide: Text.ElideRight
                    font.pixelSize: root.luminaDesign.typography.labelMedium
                }

                Text {
                    width: parent.width
                    visible: MediaService.hasSession
                        && MediaService.album.length > 0
                    text: MediaService.album
                    color: root.luminaDesign.color.textMuted
                    elide: Text.ElideRight
                    font.pixelSize: root.luminaDesign.typography.labelSmall
                }
            }

            Text {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: progressTrack.top
                    bottomMargin: root.luminaDesign.spacing.extraSmall
                }

                text: MediaService.hasSession && MediaService.length > 0
                    ? root.formatDuration(MediaService.position)
                        + " / " + root.formatDuration(MediaService.length)
                    : "--:-- / --:--"
                color: root.luminaDesign.color.textMuted
                font.pixelSize: root.luminaDesign.typography.labelSmall
            }

            WavyProgressIndicator {
                id: progressTrack

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: mediaActions.top
                    bottomMargin: root.luminaDesign.spacing.small
                }

                progress:
                    MediaService.hasSession
                        && MediaService.length > 0
                    ? MediaService.position / MediaService.length
                    : 0
                wavy: MediaService.hasSession
                    && MediaService.playing
                moving: MediaService.playing
                    && ControlCenterStore.open
                    && ControlCenterStore.activePage === "dashboard"
            }

            Row {
                id: mediaActions

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }

                spacing: root.luminaDesign.spacing.medium

                DashboardAction {
                    width: 36
                    height: 36
                    iconName: "media-skip-backward-symbolic"
                    symbol: "‹"
                    label: "Previous track"
                    available: MediaService.hasSession
                        && MediaService.activePlayer
                        && MediaService.activePlayer.canGoPrevious
                    onActivated: MediaService.previous()
                }

                DashboardAction {
                    iconName: MediaService.playing
                        ? "media-playback-pause-symbolic"
                        : "media-playback-start-symbolic"
                    symbol: MediaService.playing ? "Ⅱ" : "▶"
                    label: MediaService.playing ? "Pause" : "Play"
                    checked: MediaService.playing
                    available: MediaService.hasSession
                        && MediaService.activePlayer
                        && MediaService.activePlayer.canTogglePlaying
                    onActivated: MediaService.toggle()
                }

                DashboardAction {
                    width: 36
                    height: 36
                    iconName: "media-skip-forward-symbolic"
                    symbol: "›"
                    label: "Next track"
                    available: MediaService.hasSession
                        && MediaService.activePlayer
                        && MediaService.activePlayer.canGoNext
                    onActivated: MediaService.next()
                }
            }
        }
    }
}

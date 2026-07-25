pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.media

DashboardCard {
    id: root

    accessibleName: MediaService.hasSession
        ? MediaService.playbackLabel + ": " + MediaService.title
        : MediaService.playbackLabel

    Column {
        anchors {
            fill: parent
            margins: root.luminaDesign.spacing.large
        }

        spacing: root.luminaDesign.spacing.medium

        Row {
            width: parent.width
            height: 84
            spacing: root.luminaDesign.spacing.large

            Rectangle {
                width: 84
                height: 84
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
                    font.pixelSize: 34
                    font.weight: Font.Bold
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 84 - parent.spacing
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
        }

        Rectangle {
            width: parent.width
            height: 6
            radius: 3
            color: root.luminaDesign.color.surfaceMuted
            clip: true

            Rectangle {
                width: parent.width * (
                    MediaService.hasSession && MediaService.length > 0
                        ? Math.max(
                            0,
                            Math.min(
                                1,
                                MediaService.position / MediaService.length
                            )
                        )
                        : 0
                )
                height: parent.height
                radius: parent.radius
                color: root.luminaDesign.color.primary
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.luminaDesign.spacing.medium

            DashboardAction {
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

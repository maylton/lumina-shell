pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var activePlayer: choosePlayer(players)
    readonly property bool available: activePlayer !== null
    readonly property int playbackState: available
        ? activePlayer.playbackState
        : MprisPlaybackState.Stopped
    readonly property bool playing: playbackState === MprisPlaybackState.Playing
    readonly property bool paused: playbackState === MprisPlaybackState.Paused
    readonly property bool hasSession: playing || paused
    readonly property string playbackStatus: playing
        ? "playing"
        : paused
            ? "paused"
            : "stopped"
    readonly property string playbackLabel: playing
        ? "Playing"
        : paused
            ? "Paused"
            : "Nothing playing"
    readonly property string identity: available
        ? String(activePlayer.identity || "Media")
        : "No media player"
    readonly property string title: available
        ? String(activePlayer.trackTitle || "Unknown track")
        : ""
    readonly property string artist: available
        ? String(activePlayer.trackArtist || "")
        : ""
    readonly property string album: available
        ? String(activePlayer.trackAlbum || "")
        : ""
    readonly property string artUrl: available
        ? String(activePlayer.trackArtUrl || "")
        : ""
    readonly property real position: available
        ? Number(activePlayer.position || 0)
        : 0
    readonly property real length: available
        ? Number(activePlayer.length || 0)
        : 0

    function choosePlayer(playerList) {
        const values = playerList || []

        for (var i = 0; i < values.length; ++i) {
            if (values[i]
                    && values[i].playbackState === MprisPlaybackState.Playing)
                return values[i]
        }

        for (var j = 0; j < values.length; ++j) {
            if (values[j]
                    && values[j].playbackState === MprisPlaybackState.Paused)
                return values[j]
        }

        return values.length > 0 ? values[0] : null
    }

    function toggle() {
        if (available && activePlayer.canTogglePlaying)
            activePlayer.togglePlaying()
    }

    function next() {
        if (available && activePlayer.canGoNext)
            activePlayer.next()
    }

    function previous() {
        if (available && activePlayer.canGoPrevious)
            activePlayer.previous()
    }

    function seek(seconds) {
        if (available && activePlayer.canSeek)
            activePlayer.seek(Number(seconds || 0))
    }

    function statusObject() {
        return {
            available: available,
            playing: playing,
            paused: paused,
            hasSession: hasSession,
            playbackStatus: playbackStatus,
            player: identity,
            title: title,
            artist: artist,
            album: album,
            position: position,
            length: length,
            canPrevious: available && activePlayer.canGoPrevious,
            canToggle: available && activePlayer.canTogglePlaying,
            canNext: available && activePlayer.canGoNext
        }
    }

    IpcHandler {
        target: "media"

        function toggle(): void {
            root.toggle()
        }

        function next(): void {
            root.next()
        }

        function previous(): void {
            root.previous()
        }

        function seek(seconds: int): void {
            root.seek(seconds)
        }

        function status(): string {
            return JSON.stringify(root.statusObject())
        }
    }
}

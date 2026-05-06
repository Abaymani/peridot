pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import qs
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
  id: root

  property string previousSinkName: ""
  property string previousSourceName: ""

  property list<PwNode> sinks: []
  property list<PwNode> sources: []
  property list<PwNode> streams: []

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property PwNode source: Pipewire.defaultAudioSource

  readonly property bool muted: !!sink?.audio?.muted
  readonly property real volume: sink?.audio?.volume ?? 0

  readonly property bool sourceMuted: !!source?.audio?.muted
  readonly property real sourceVolume: source?.audio?.volume ?? 0

  readonly property real maxVolume: 100

  function setVolume(newVolume: real): void {
    if (sink?.ready && sink?.audio) {
      sink.audio.muted = false;
      sink.audio.volume = Math.max(0, Math.min(root.maxVolume, newVolume));
    }
  }

  function toggleMute() {
    root.muted 
      ? sink.audio.muted = false
      : sink.audio.muted = true
  }

  function incrementVolume(amount: real): void {
    setVolume(volume + (amount || Settings.audioIncrement));
  }

  function decrementVolume(amount: real): void {
    setVolume(volume - (amount || Settings.audioIncrement));
  }

  function setSourceVolume(newVolume: real): void {
    if (source?.ready && source?.audio) {
      source.audio.muted = false;
      source.audio.volume = Math.max(0, Math.min(root.maxVolume, newVolume));
    }
  }

  function incrementSourceVolume(amount: real): void {
    setSourceVolume(sourceVolume + (amount || Settings.audioIncrement));
  }

  function decrementSourceVolume(amount: real): void {
    setSourceVolume(sourceVolume - (amount || Settings.audioIncrement));
  }

  function setAudioSink(newSink: PwNode): void {
    Pipewire.preferredDefaultAudioSink = newSink;
  }

  function setAudioSource(newSource: PwNode): void {
    Pipewire.preferredDefaultAudioSource = newSource;
  }

  function cycleNextAudioOutput(): void {
    if (sinks.length === 0) return;

    const currentIndex = sinks.findIndex(s => s === sink);
    const nextIndex = (currentIndex + 1) % sinks.length;
    setAudioSink(sinks[nextIndex]);
  }

  function setStreamVolume(stream: PwNode, newVolume: real): void {
    if (stream?.ready && stream?.audio) {
      stream.audio.muted = false;
      stream.audio.volume = Math.max(0, Math.min(root.maxVolume, newVolume));
    }
  }

  function setStreamMuted(stream: PwNode, muted: bool): void {
    if (stream?.ready && stream?.audio) {
      stream.audio.muted = muted;
    }
  }

  function getStreamVolume(stream: PwNode): real {
    return stream?.audio?.volume ?? 0;
  }

  function getStreamMuted(stream: PwNode): bool {
    return !!stream?.audio?.muted;
  }

  function getStreamName(stream: PwNode): string {
    if (!stream)
      return qsTr("Unknown");
    // Try application name first, then description, then name
    return stream.properties["application.name"] || stream.description || stream.name || qsTr("Unknown Application");
  }

  onSinkChanged: {
    if (!sink?.ready)
      return;

    const newSinkName = sink.description || sink.name || "Unknown Device";
    previousSinkName = newSinkName;
  }

  onSourceChanged: {
    if (!source?.ready)
      return;

    const newSourceName = source.description || source.name || "Unknown Device";
    previousSourceName = newSourceName;
  }

  Component.onCompleted: {
    previousSinkName = sink?.description || sink?.name || "Unknown Device";
    previousSourceName = source?.description || source?.name || "Unknown Device";
  }

  Connections {
    function onValuesChanged(): void {
      const newSinks = [];
      const newSources = [];
      const newStreams = [];

      for (const node of Pipewire.nodes.values) {
        if (!node.isStream) {
          if (node.isSink)
            newSinks.push(node);
          else if (node.audio)
            newSources.push(node);
        } else if (node.audio) {
          newStreams.push(node);
        }
      }

      root.sinks = newSinks;
      root.sources = newSources;
      root.streams = newStreams;
    }

    target: Pipewire.nodes
  }

  PwObjectTracker {
    objects: [...root.sinks, ...root.sources, ...root.streams]
  }

  IpcHandler {
    function cycleOutput(): void {
      root.cycleNextAudioOutput();
    }

    target: "audio"
  }
}

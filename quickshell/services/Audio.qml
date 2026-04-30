pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
  id: root

  property bool ready: Pipewire.defaultAudioSink?.ready ?? false
  property PwNode sink: Pipewire.defaultAudioSink
  property PwNode source: Pipewire.defaultAudioSource
  readonly property real hardMaxValue: 2.00
  //property string audioTheme: Config.options.sounds.theme
  property real volume: 0
  property string activePortName: ""

  function friendlyDeviceName(node) {
    return (node.nickname || node.description || Translation.tr("Unknown"));
  }

  function appNodeDisplayName(node) {
    return (node.properties["application.name"] || node.description || node.name)
  }

  // Lists
  function correctType(node, isSink) {
    return (node.isSink === isSink) && node.audio
  }

  function appNodes(isSink) {
    return Pipewire.nodes.values.filter((node) => { // Should be list<PwNode> but it breaks ScriptModel
      return root.correctType(node, isSink) && node.isStream
    })
  }

  function devices(isSink) {
    return Pipewire.nodes.values.filter(node => {
      return root.correctType(node, isSink) && !node.isStream
    })
  }

  readonly property list<var> outputAppNodes: root.appNodes(true)
  readonly property list<var> inputAppNodes: root.appNodes(false)
  readonly property list<var> outputDevices: root.devices(true)
  readonly property list<var> inputDevices: root.devices(false)

  // Signals
  signal sinkProtectionTriggered(string reason);

  // Controls
  function toggleMute() {
    Audio.sink.audio.muted = !Audio.sink.audio.muted
  }

  function toggleMicMute() {
    Audio.source.audio.muted = !Audio.source.audio.muted
  }

  function incrementVolume() {
    const currentVolume = Audio.value;
    const step = currentVolume < 0.1 ? 0.01 : 0.02 || 0.2;
    Audio.sink.audio.volume = Math.min(1, Audio.sink.audio.volume + step);
  }
  
  function decrementVolume() {
    const currentVolume = Audio.value;
    const step = currentVolume < 0.1 ? 0.01 : 0.02 || 0.2;
    Audio.sink.audio.volume -= step;
  }

  function setDefaultSink(node) {
    Pipewire.preferredDefaultAudioSink = node;
  }

  function setDefaultSource(node) {
    Pipewire.preferredDefaultAudioSource = node;
  }

  PwObjectTracker {
      objects: [sink, source]
  }


  Connections {
    target: sink?.audio ?? null
    function onVolumeChanged() { 
      portUpdateProcess.running = true 
      volumeUpdateProcess.running = true
    }
    function onMutedChanged() { 
      portUpdateProcess.running = true 
    }
  }

  onSinkChanged: {
    if (sink) {
      portUpdateProcess.running = true
      volumeUpdateProcess.running = true
    }
  }

  Process {
    id: portUpdateProcess
    // This is a condensed version of your bash script logic
    command: ["sh", "-c", "pactl list sinks | awk -v tgt=\"$(pactl get-default-sink)\" '$0 ~ \"Name: \"tgt {f=1} f && /Active Port:/ {print; exit} /^$/ {f=0}'"]    
    running: true

    stdout: StdioCollector {
      onStreamFinished: { 
        root.activePortName = this.text.trim().toLowerCase();
      }
    }
  }

  Process {
    id: volumeUpdateProcess
    command: ["sh", "-c", "pactl list sinks | awk -v tgt=\"$(pactl get-default-sink)\" '$0 ~ \"Name: \"tgt {f=1} f && /^[[:space:]]*Volume:/ { match($0, /[0-9]+%/); print substr($0, RSTART, RLENGTH-1); exit }'"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: { 
        // Parse the stdout to a float, ignoring trailing newlines or [MUTED] tags
        let parsedVol = parseFloat(this.text);
        if (!isNaN(parsedVol)) {
          root.volume = parsedVol;
        }
      }
    }
  }
}

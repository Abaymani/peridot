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
  property real value: sink?.audio.volume ?? 0
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
    function onVolumeChanged() { portUpdateProcess.running = true }
    function onMutedChanged() { portUpdateProcess.running = true }
  }

    Process {
    id: portUpdateProcess
    // This is a condensed version of your bash script logic
    command: ["sh", "-c", "pactl list sinks | awk -v tgt=\"$(pactl get-default-sink)\" '$0 ~ \"Name: \"tgt {f=1} f && /Active Port:/ {print $3; exit} /^$/ {f=0}'"]    
    running: true

    stdout: StdioCollector {
      onStreamFinished: { 
        root.activePortName = this.text.trim().toLowerCase();
      }
    }
  }

  /*
  Connections { // Protection against sudden volume changes
    target: sink?.audio ?? null
    property bool lastReady: false
    property real lastVolume: 0
    function onVolumeChanged() {
      if (!Config.options.audio.protection.enable) return;
      const newVolume = sink.audio.volume;
      // when resuming from suspend, we should not write volume to avoid pipewire volume reset issues
      if (isNaN(newVolume) || newVolume === undefined || newVolume === null) {
        lastReady = false;
        lastVolume = 0;
        return;
      }
      if (!lastReady) {
        lastVolume = newVolume;
        lastReady = true;
        return;
      }
      const maxAllowedIncrease = Config.options.audio.protection.maxAllowedIncrease / 100; 
      const maxAllowed = Config.options.audio.protection.maxAllowed / 100;

      if (newVolume - lastVolume > maxAllowedIncrease) {
        sink.audio.volume = lastVolume;
        root.sinkProtectionTriggered(Translation.tr("Illegal increment"));
      } else if (newVolume > maxAllowed || newVolume > root.hardMaxValue) {
        root.sinkProtectionTriggered(Translation.tr("Exceeded max allowed"));
        sink.audio.volume = Math.min(lastVolume, maxAllowed);
      }
      lastVolume = sink.audio.volume;
    }
  }

  function playSystemSound(soundName) {
    const ogaPath = `/usr/share/sounds/${root.audioTheme}/stereo/${soundName}.oga`;
    const oggPath = `/usr/share/sounds/${root.audioTheme}/stereo/${soundName}.ogg`;

    // Try playing .oga first
    let command = [
      "ffplay",
      "-nodisp",
      "-autoexit",
      ogaPath
    ];
    Quickshell.execDetached(command);

    // Also try playing .ogg (ffplay will just fail silently if file doesn't exist)
    command = [
      "ffplay",
      "-nodisp",
      "-autoexit",
      oggPath
    ];
    Quickshell.execDetached(command);
  }*/
}

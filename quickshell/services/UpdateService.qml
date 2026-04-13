pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io


Singleton {
  id: root

  property int count: 0

  Process {
    id: updateProcess
      command: [
        "sh",
        "-c",
        "echo $(( $(checkupdates 2>/dev/null | wc -l) + $(yay -Qum --refresh 2>/dev/null | wc -l) ))"
      ]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        root.count = parseInt(this.text.trim())|| 0;
      }
    }
  }

  Process {
    id: runUpdateScript
    running: false
    command: ["sh", "-c", "kitty --class peridot-floating -e $HOME/.config/peridot/scripts/installupdates.sh"]
  }

  function runUpdate(){
    runUpdateScript.running = true
  }

  function checkUpdates(){
    updateProcess.running = true
  }

  Timer {
    interval: 1000 * 60 * 5 // 5 minutes in miliseconds
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {updateProcess.running = true}
  }
}

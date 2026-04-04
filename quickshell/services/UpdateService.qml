pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io


Singleton {
  id: root

  property int count: 0
  property string currentStatus: "none"

  Process {
    id: updateProcess
    command: ["sh", "-c", "yay -Qu | wc -l"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        root.count = parseInt(this.text.trim()) || 0;
        if (root.count > 100) root.currentStatus = "red";
        else if (root.count > 50) root.currentStatus = "yellow";
        else if (root.count > 0) root.currentStatus = "green";
        else root.currentStatus = "none";
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

  Timer {
    interval: 1000*60*15 // 15 minutes in miliseconds
    running: true
    repeat: true
    onTriggered: updateProcess.running = true
  }
}

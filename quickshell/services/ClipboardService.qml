pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root
  property alias model: clipModel

  // Search
  property string searchQuery: ""
  property var historyArray: []
  property var searchResults: []

  ListModel {
    id: clipModel
  }

  // Temporary model to build the list before swapping, preventing the UI from flashing blank during updates.
  ListModel {
    id: tempModel
  }

  // Debounce timer: wait 100ms after a copy event to ensure cliphist has finished writing to its database before we read.
  Timer {
    id: debounceTimer
    interval: 100
    onTriggered: {
      searchResults = []
      fetchProcess.running = false
      fetchProcess.running = true
    }
  }

  // Tailing Implementation: Watches for clipboard changes natively
  Process {
    id: watcher
    command: ["wl-paste", "--watch", "echo", "update"]
    running: true
    stdout: SplitParser {
      onRead: data => {
        debounceTimer.restart()
      }
    }
  }

  Process {
    id: fetchProcess
    command: ["cliphist", "list"]
    running: true
    
    stdout: SplitParser {
      onRead: data => {
        // cliphist outputs in the format: <ID>\t<CONTENT>
        let firstTab = data.indexOf("\t")
        if (firstTab !== -1) {
          let id = data.substring(0, firstTab)
          let content = data.substring(firstTab + 1)
          searchResults.push({ "clipId": id, "clipContent": content })
        }
      }
    }
    
    onExited: {
      historyArray = searchResults
      applyFilter()
    }
  }

  Process {
    id: wipeHistory
    running: false
    command: ["sh", "-c", "cliphist wipe"]

    onExited: {
      // Clear the internal data arrays
      historyArray = []
      searchResults = []
      
      applyFilter()
    }
  }

  Process {
    id: copyProcess
    running: false
  }

  function copyItem(id, text) {
    let clipLine = id + "\t" + text
    
    // Pass argument "$1" clipLine to prevent shell injection.
    // Using printf '%s' instead of echo -e ensures special characters in the copied 
    copyProcess.command = [
        "sh", 
        "-c", 
        "printf '%s' \"$1\" | cliphist decode | wl-copy", 
        "--", 
        clipLine
    ]
    
    // Restart the process with the new command
    copyProcess.running = false
    copyProcess.running = true
  }

  function applyFilter() {
    clipModel.clear()
    let query = searchQuery.toLowerCase()
    
    for (let i = 0; i < historyArray.length; i++) {
      let item = historyArray[i]
      // If search is empty, or the item contains the query (case-insensitive)
      if (query === "" || item.clipContent.toLowerCase().includes(query)) {
        clipModel.append({ "clipId": item.clipId, "clipContent": item.clipContent })
      }
    }
  }

  function deleteHistory() {
    wipeHistory.running = true
  }

  // Automatically re-filter whenever the search query changes
  onSearchQueryChanged: applyFilter()
}
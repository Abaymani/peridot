import QtQuick
import Quickshell
import QtQuick.Layouts
import qs
import qs.services
import qs.programs.controlcenter

PanelWindow {
  id: overlayWindow
  
  // TODO: move placement to config
  anchors {
    bottom: true
    right: true
  }
  margins {
    bottom: 20
    right: 20
  }
  
  aboveWindows: true
  exclusionMode: ExclusionMode.Ignore

  color: "transparent"

  // TODO: move width to config
  implicitWidth: 350
  implicitHeight: popupList.contentHeight

  ListView {
    id: popupList
    anchors.fill: parent
    spacing: 10
    interactive: false //disable scroll
    
    model: Notifications.popupModel
    verticalLayoutDirection: ListView.BottomToTop // TODO: should depend on anchor top/bottom
    
    delegate: NotificationItem {
      isPopup: true
    }
    
    // TODO: make customizable
    add: Transition {
      ParallelAnimation {
        NumberAnimation { property: "opacity"; from: 1; to: 1; duration: 300 }
        NumberAnimation { property: "x"; from: overlayWindow.width + 200; to: 0; duration: 300; easing.type: Easing.OutCubic }
      }
    }
    remove: Transition {
      ParallelAnimation {
        NumberAnimation { property: "opacity"; to: 0; duration: 300 }
        NumberAnimation { property: "x"; to: overlayWindow.width; duration: 300 }
      }
    }
    displaced: Transition {
      NumberAnimation { property: "y"; duration: 300; easing.type: Easing.OutCubic }
    }
  }
}
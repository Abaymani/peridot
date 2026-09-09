import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.common.looks as Looks
import qs.widgets

RowLayout {
  id: trayRoot
  Layout.fillWidth: false

  Repeater {
    model: SystemTray.items

    delegate: Rectangle {
      id: itemRect
      width: Looks.Fonts.size + 8
      height: Looks.Fonts.size + 8
      color: "transparent"
      radius: 4

      // Attached here, not on the popup: QsWindow resolves the window of the
      // item it is attached to, and MenuPopup is itself a window.
      readonly property var hostWindow: QsWindow.window

      IconImage {
        anchors.centerIn: parent
        width: parent.width 
        height: parent.height 
        
        source: modelData.icon
      }

      MenuPopup {
        id: trayMenu
        menuHandle: modelData.menu
        anchorItem: itemRect
        anchorWindow: itemRect.hostWindow
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        
        onEntered: itemRect.color = "#22ffffff"
        onExited: itemRect.color = "transparent"

        onClicked: (mouse) => {
          if (mouse.button === Qt.LeftButton) {
            modelData.activate();
          }
          else if (mouse.button === Qt.RightButton) {
            if (modelData.hasMenu) {
              trayMenu.visible = true;
            }
          }
        }
      }
    }
  }
}

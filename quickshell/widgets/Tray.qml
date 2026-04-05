import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../common/looks" as Looks

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

      IconImage {
        anchors.centerIn: parent
        width: parent.width - 2
        height: parent.height - 2
        
        source: modelData.icon
      }

      QsMenuAnchor {
        id: trayMenuAnchor
        menu: modelData.menu 
        
        anchor.window: rootWindow
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
              var pos = trayRoot.mapToItem(rootWindow.contentItem, 0, 0);
              
              trayMenuAnchor.anchor.rect = Qt.rect(
                pos.x, 
                pos.y, 
                trayRoot.width, 
                trayRoot.height
              );
              
              trayMenuAnchor.open();
            }
          }
        }
      }
    }
  }
}
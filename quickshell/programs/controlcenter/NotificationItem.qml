import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services
import qs

Rectangle {
  required property string notifId
  property var notifObject: Notifications.getNotification(notifId)
  property var modelData: notifObject.notif
  property var timeReceived: notifObject.timeReceived

  width: ListView.view.width
  height: col.implicitHeight + 20
  color: Looks.Colors.md3.surface_container
  gradient: Settings.gradientBgEnabled 
    ? Looks.Gradients.library[Settings.activeGradient].createObject()
    : null
  radius: Looks.Decorations.decor.radius
  
  Column {
    id: col
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 10
    spacing: 5
    
    RowLayout {
      width: parent.width

      Text {
        Layout.fillWidth: true
        text: modelData.summary
        font.family: Looks.Fonts.family
        font.pixelSize: Looks.Fonts.size + 2
        font.weight: Font.Bold
        color: Settings.textColorOnContainer
        elide: Text.ElideRight
        width: parent.width
      }

      Text {
        text: Qt.formatTime(new Date(timeReceived), "hh:mm")
        font.family: Looks.Fonts.family
        font.pixelSize: Looks.Fonts.size -1
        font.italic: true
        color: Settings.textColorOnContainer
        elide: Text.ElideRight
        width: parent.width
      }
    }

    Text {
      text: modelData.body
      font.family: Looks.Fonts.family
      font.pixelSize: Looks.Fonts.size
      font.weight: Looks.Fonts.weight
      color: Settings.textColorOnContainer
      wrapMode: Text.WordWrap
      width: parent.width
      visible: modelData.body !== ""
    }
  }
  
  // Dismiss notification when clicked
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      Notifications.dismiss(notifId)
    }
  }
}
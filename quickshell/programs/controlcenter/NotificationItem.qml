import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.common.functions
import qs.services
import qs

Rectangle {
  required property string notifId
  property var notifObject: Notifications.getNotification(notifId)
  property var modelData: notifObject.notif
  property var timeReceived: notifObject.timeReceived

  width: ListView.view.width
  height: mainLayout.implicitHeight + 20
  color: Looks.Colors.md3.surface_container
  gradient: Settings.gradientBgEnabled 
    ? Looks.Gradients.library[Settings.activeGradient].createObject()
    : null
  radius: Looks.Decorations.decor.radius

  RowLayout {
    id: mainLayout
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 10
    spacing: 12

    Item {
      Layout.alignment: Qt.AlignTop
      Layout.preferredWidth: 36
      Layout.preferredHeight: 36
      
      // Hide the whole container in case no appropriate image exists
      visible: mainImage.source.toString() !== "" || badgeIcon.source.toString() !== ""

      // Main Image
      Image {
        id: mainImage
        anchors.fill: parent
        // Use the attached image first, fallback to the standard icon
        source: modelData.image || (modelData.appIcon ? Quickshell.iconPath(modelData.appIcon) : "")
        fillMode: Image.PreserveAspectFit
      }

      // AppIcon
      Rectangle {
        id: badgeContainer
        anchors.top: parent.top
        anchors.left: parent.left

        // slightly outside the main image
        anchors.topMargin: -4
        anchors.leftMargin: -4
        
        width: 20
        height: 20
        radius: 10
        color: "transparent"
        
        // Only show badge if distinct app icon and has a main image.
        // Hide the badge if they are the same.
        visible: mainImage.source.toString() !== "" && 
                 badgeIcon.source.toString() !== "" && 
                 mainImage.source.toString() !== badgeIcon.source.toString()

        Image {
          id: badgeIcon
          anchors.fill: parent
          source: modelData.appIcon ? Quickshell.iconPath(modelData.appIcon) : ""
          fillMode: Image.PreserveAspectFit
        }
      }
    }
    

    ColumnLayout {
      spacing: 5
      Layout.fillWidth: true
      
      RowLayout {
      Layout.fillWidth: true

        Text {
          Layout.fillWidth: true
          Layout.minimumWidth: 0
          text: modelData.summary
          font.family: Looks.Fonts.family
          font.pixelSize: Looks.Fonts.size
          font.weight: Font.Bold
          color: Settings.textColorOnContainer
          elide: Text.ElideRight
        }

        Text {
          text: TimeUtils.formatRelativeTime(new Date(timeReceived), Time.time)
          font.family: Looks.Fonts.family
          font.pixelSize: Looks.Fonts.size -1
          font.italic: true
          color: Settings.textColorOnContainer
          elide: Text.ElideRight
        }
      }

      Text {
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        text: modelData.body
        font.family: Looks.Fonts.family
        font.pixelSize: Looks.Fonts.size
        font.weight: Looks.Fonts.weight
        color: Settings.textColorOnContainer
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight
        visible: modelData.body !== ""
      }
    }
  }
  
  
  // (TEMP) Dismiss notification when clicked
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      Notifications.dismiss(notifId)
    }
  }
}
import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.common.functions
import qs.services
import qs.widgets
import qs

Rectangle {
  required property string notifId
  property var notifObject: Notifications.getNotification(notifId)
  property var modelData: notifObject.notif
  property var timeReceived: notifObject.timeReceived
  property var isPopup: false

  width: ListView.view.width
  height: mainLayout.implicitHeight + 20
  color: Looks.Colors.md3.secondary_container
  gradient: Settings.gradientBgEnabled 
    ? Looks.Gradients.library[Settings.activeGradient].createObject()
    : null
  radius: Looks.Decorations.decor.radius

  HoverHandler {
    id: cardHover
  }

  RowLayout {
    id: mainLayout
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.topMargin: 10
    anchors.bottomMargin: 10
    spacing: 8

    Item {
      Layout.alignment: Qt.AlignTop
      Layout.preferredWidth: 36
      Layout.preferredHeight: 36
      Layout.leftMargin: 10
      Layout.rightMargin: -10
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
      Layout.fillWidth: true
      Layout.leftMargin: 10
      Layout.rightMargin: 10
      Layout.alignment: Qt.AlignTop
      
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
          visible: !isPopup
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
        text: modelData.body
        font.family: Looks.Fonts.family
        font.pixelSize: Looks.Fonts.size-3
        font.weight: Looks.Fonts.weight
        color: Settings.textColorOnContainer
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight
        visible: modelData.body !== ""
      }
      
      RowLayout {
        id: actionRow
        property bool showActions: !isPopup && cardHover.hovered

        opacity: showActions ? 1.0 : 0.0
        visible: opacity > 0
        clip: true

        Layout.fillWidth: true
        Layout.preferredHeight: showActions ? implicitHeight : 0
        Layout.topMargin: 4
        Layout.leftMargin: -2
        Layout.rightMargin: -4
        
        Behavior on opacity {
          NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        Behavior on Layout.preferredHeight {
          NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        ListView {
          id: actionList
          Layout.fillWidth: true
          Layout.preferredHeight: Looks.Decorations.decor.elementHeight
          
          orientation: ListView.Horizontal
          spacing: 8
          
          model: modelData.actions 
          
          delegate: Item { 
            required property var modelData
            width: innerButton.width
            height: innerButton.height
            Button {
              id: innerButton
              color: Looks.Colors.md3.surface_container
              fontSizeModifier: -1
              buttonText: parent.modelData.text 
              onClicked: parent.modelData.invoke()
            }
          }
        }

        Button {
          color: Looks.Colors.md3.surface_container
          buttonText: ""
          onClicked: Notifications.dismiss(notifId)
        }
      }
    }

    Button {
      visible: isPopup
      color: Looks.Colors.md3.surface_container
      Layout.rightMargin: 10
      buttonText: ""
      onClicked:Notifications.dismiss(notifId)
    }
  }
}
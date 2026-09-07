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
  property var modelData: notifObject.data
  property var timeReceived: notifObject.timeReceived
  property bool isLive: notifObject.notif !== null
  property var isPopup: false
  // Actions are dropped when restored from disk, so hasActions only ever
  // applies to live notifications.
  readonly property bool hasActions: isLive && modelData.actions.length > 0

  // Falls back to parent.width for grouped notifications (a Repeater child,
  // not a ListView delegate).
  width: ListView.view?.width ?? parent.width
  Layout.fillWidth: true

  // Layouts size non-fillHeight children from implicitHeight, while ListView
  // reads height directly (which defaults to implicitHeight) - this satisfies both.
  implicitHeight: mainLayout.implicitHeight + 20
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
      visible: mainImage.source.toString() !== "" || badgeIcon.source.toString() !== ""

      Image {
        id: mainImage
        anchors.fill: parent
        source: modelData.image || (modelData.appIcon ? Quickshell.iconPath(modelData.appIcon) : "")
        fillMode: Image.PreserveAspectFit
      }

      Rectangle {
        id: badgeContainer
        anchors.top: parent.top
        anchors.left: parent.left

        // negative margins sit it slightly outside the main image
        anchors.topMargin: -4
        anchors.leftMargin: -4
        
        width: 20
        height: 20
        radius: 10
        color: "transparent"
        
        // Hide the badge when it's the same icon as the main image
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
      spacing: 0
      Layout.leftMargin: 10
      Layout.rightMargin: 10
      Layout.alignment: Qt.AlignTop
      
      RowLayout {
      Layout.fillWidth: true

        Looks.ClearText {
          Layout.fillWidth: true
          Layout.minimumWidth: 0
          text: modelData.summary
          font.weight: Font.Bold
          color: Settings.textColorOnContainer
          elide: Text.ElideRight
        }

        Looks.ClearText {
          visible: !isPopup
          text: TimeUtils.formatRelativeTime(new Date(timeReceived), Time.time)
          font.pixelSize: Looks.Fonts.size -1
          font.italic: true
          color: Settings.textColorOnContainer
          elide: Text.ElideRight
        }

        // Inline dismiss for notifications with nothing to act on, in
        // place of the actionRow reveal below.
        Button {
          buttonText: ""
          widthPadding: 10
          readonly property bool show: !isPopup && !hasActions && cardHover.hovered
          fontSizeModifier: 4

          opacity: show ? 1.0 : 0.0
          visible: opacity > 0
          clip: true

          Layout.preferredWidth: show ? implicitWidth : 0
          Layout.preferredHeight: show ? Looks.Decorations.decor.elementHeight -9 : 0

          Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
          }
          Behavior on Layout.preferredWidth {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
          }
          Behavior on Layout.preferredHeight {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
          }

          onClicked: Notifications.dismiss(notifId)
        }
      }

      Looks.ClearText {
        Layout.fillWidth: true
        text: modelData.body
        font.pixelSize: Looks.Fonts.size-2
        color: Settings.textColorOnContainer
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight
        visible: modelData.body !== ""
      }
      
      RowLayout {
        id: actionRow
        property bool showActions: !isPopup && hasActions && cardHover.hovered

        opacity: showActions ? 1.0 : 0.0
        visible: opacity > 0
        clip: true

        Layout.fillWidth: true
        Layout.preferredHeight: showActions ? implicitHeight : 0
        Layout.topMargin: showActions ? 9 : 0
        Layout.leftMargin: -2
        Layout.rightMargin: -4
        
        Behavior on opacity {
          NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        Behavior on Layout.preferredHeight {
          NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        Behavior on Layout.topMargin {
          NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        ListView {
          id: actionList
          Layout.fillWidth: true
          Layout.preferredHeight: Looks.Decorations.decor.elementHeight
          
          orientation: ListView.Horizontal
          spacing: 8

          // Actions only exist on the live DBus notification, not persisted ones.
          model: isLive ? modelData.actions : []

          delegate: Item {
            required property var modelData
            width: innerButton.width
            height: innerButton.height
            Button {
              id: innerButton
              fontSizeModifier: -1
              buttonText: parent.modelData.text
              onClicked: Notifications.invokeAction(notifId, parent.modelData.identifier)
            }
          }
        }

        Button {
          buttonText: ""
          onClicked: Notifications.dismiss(notifId)
        }
      }
    }

    Button {
      visible: isPopup
      Layout.rightMargin: 10
      buttonText: ""
      onClicked:Notifications.dismiss(notifId)
    }
  }
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs

Scope {
  id: clipboardRoot

  PanelWindow {
    id: root
    visible: GlobalStates.isClipboardOpen 
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

    WlrLayershell.layer: WlrLayer.Overlay 
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusiveZone: 0
    
    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }
    color: "transparent"

    //click anywhere outside the list to close
    Rectangle {
      anchors.fill: parent
      color: "transparent"
      
      MouseArea {
        anchors.fill: parent
        onClicked: GlobalStates.isClipboardOpen = false
      }
    }

    Rectangle {
      width: 500
      height: 700
      anchors.centerIn: parent
      color: Looks.Colors.md3.secondary_container
      gradient: Settings.gradientBgEnabled 
        ? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject() 
        : null
      radius: Looks.Decorations.decor.radius

      MouseArea {
        anchors.fill: parent
        // Prevents the click from reaching the background MouseArea
        propagateComposedEvents: false 
        onClicked: (mouse) => { mouse.accepted = true }
      }
      
      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        RowLayout {
          Text {
              text: "Clipboard"
              font.family: Looks.Fonts.family
              font.pixelSize: Looks.Fonts.size + 8
              font.weight: Looks.Fonts.weight
              color: Settings.textColorOnContainer
          }

          Item {Layout.fillWidth: true}

          Button {
            buttonText: "󰗨"
            onClicked: ClipboardService.deleteHistory()
          }
        }


        TextField {
          id: searchInput
          Layout.fillWidth: true
          Layout.preferredHeight: 28
          leftPadding: 10
          rightPadding: 10
          placeholderText: "Search..."
          placeholderTextColor: Looks.Colors.palette.neutral70
          color: Settings.textColorOnLight
          font.family: Looks.Fonts.family
          font.pixelSize: Looks.Fonts.size
          
          onTextChanged: ClipboardService.searchQuery = text

          background: Rectangle {
            color: Looks.Colors.md3.inverse_surface
            gradient: Settings.gradientBgEnabled 
              ? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject()
              : null
            radius: Looks.Decorations.decor.radius
            border.width: 1
            border.color: searchInput.activeFocus ? Looks.Colors.md3.primary : '#00000000' 
          }
        }

        RowLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 8

          ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            id: listView
            model: ClipboardService.model
            spacing: 8

            ScrollBar.vertical: ScrollBar { 
              parent: listView.parent
              Layout.fillHeight: true
              visible: size < 1.0
              policy: ScrollBar.AlwaysOn
              active: true 
            }

            delegate: Rectangle {
              width: ListView.view.width
              height: delegateText.implicitHeight + 20
              color: Looks.Colors.md3.surface_container
              gradient: Settings.gradientBgEnabled 
                ? Looks.Gradients.library[Settings.activeGradient].createObject()
                : null
              radius: Looks.Decorations.decor.radius
              
              RowLayout{
                anchors.fill: parent
                anchors.margins: 8

                Text {
                  id: delegateId

                  font.family: Looks.Fonts.family
                  font.pixelSize: Looks.Fonts.size
                  text: clipId
                  color: Settings.textColorOnContainer
                  elide: Text.ElideRight
                  maximumLineCount: 3
                  wrapMode: Text.WordWrap
                  verticalAlignment: Text.AlignVCenter
                }

                Looks.Seperator { verticalPadding: 1}

                Text {
                  id: delegateText
                  Layout.fillWidth: true
                  verticalAlignment: Text.AlignVCenter
                  leftPadding: 10

                  font.family: Looks.Fonts.family
                  font.pixelSize: Looks.Fonts.size

                  text: clipContent
                  color: Settings.textColorOnContainer
                  elide: Text.ElideRight
                  maximumLineCount: 3
                  wrapMode: Text.WordWrap
                  textFormat: Text.PlainText
                  
                }
                
              }
              MouseArea {
                id: itemMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  ClipboardService.copyItem(clipId, clipContent)
                  GlobalStates.isClipboardOpen = false // Hide the overlay after copying
                }
              }
            }
          }
        }
      }
    }
  }
}
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.common.looks as Looks
import qs.services as Services
import qs.widgets
import qs

Rectangle {
  id: root
  height: Looks.Decorations.decor.elementHeight
  implicitWidth: mainLayout.implicitWidth + 20
  radius: Looks.Decorations.decor.radius
  color: Looks.Colors.md3.secondary_container
  gradient: Settings.gradientBgEnabled 
    ? Looks.Gradients.library[Settings.activeGradient].createObject()
    : null

  property bool volReveal: false

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: root.volReveal = true
    onExited: root.volReveal = false
    

    RowLayout {
      id: mainLayout
      anchors.centerIn: parent
      spacing: 0

      // --- VOLUME SLIDER CONTAINER ---
      Item {
        id: sliderContainer
        clip: true // Essential: hides the slider when width is small
        Layout.preferredHeight: 20
        
        // Logic for sliding width
        Layout.preferredWidth: !root.volReveal ? 0 : 100
        opacity: root.volReveal ? 1 : 0

        Behavior on Layout.preferredWidth { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Slider {
          anchors.verticalCenter: parent.verticalCenter
          width: 100
          from: 0
          to: 1
          value: Services.Audio.volume
          onMoved: Services.Audio.setVolume(value)
        }
      }

      // --- PERCENTAGE TEXT CONTAINER ---
      Item {
        id: percentContainer
        clip: true
        Layout.preferredHeight: 20
        Layout.preferredWidth: !root.volReveal ? percentText.implicitWidth : 0
        opacity: !root.volReveal ? 1 : 0

        Behavior on Layout.preferredWidth { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Text {
          id: percentText
          anchors.centerIn: parent
          font.family: Looks.Fonts.family
          font.pixelSize: Looks.Fonts.size - 2
          color: Settings.textColorOnContainer
          renderType: Text.NativeRendering
          text: Services.Audio.sink ? Math.round(Services.Audio.volume * 100) + "%" : "N/A"
        }
      }

      Looks.Seperator {
        Layout.leftMargin: 8 
        Layout.rightMargin: 8
        color: Settings.textColorOnContainer
      }

      Text {
        font.family: Looks.Fonts.family
        font.pixelSize: Looks.Fonts.size
        color: Services.Audio.sink?.audio.muted ? Settings.textColorOnContainer : Settings.textColorOnContainer
        renderType: Text.NativeRendering
        text: {
          if (!Services.Audio.sink) return "󰖡"; // N/A or Error icon
          if (Services.Audio.muted) return "󰖁"; // Muted icon

          const desc = (Services.Audio.sink.description || "").toLowerCase();
          const formFactor = (Services.Audio.sink.properties["device.form_factor"] || "").toLowerCase();
          const isHeadphone = desc.includes("headphone") || desc.includes("headset") || formFactor === "headphone" || formFactor === "headset";

          if (isHeadphone) return "󰋋"; // Headphone icon
          return "󰕾"; // High

        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton | Qt.RightButton

          onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {Quickshell.execDetached(["hyprctl", "dispatch", "exec", "pavucontrol"])}
            else if (mouse.button === Qt.RightButton) {Services.Audio.toggleMute()}
          }
        }
      }
    }
  }
}
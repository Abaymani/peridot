import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common.looks as Looks
import qs.common.functions
import qs.widgets
import qs.services
import qs

// Profile card: picture, username and uptime at the top, lock and power
// buttons at the bottom. Sized to span the quick-tools row and the dashboard
// box beside it (see ControlCenter.qml).
Rectangle {
  id: root

  clip: true
  color: Settings.gradientBgEnabled
    ? ColorUtils.setAlphaColor(Looks.Colors.md3.secondary, 0.5)
    : Looks.Colors.md3.surface_container
  gradient: Settings.gradientBgEnabled
    ? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject()
    : null
  radius: Looks.Decorations.decor.radius

  RowLayout {
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 8
    spacing: 6

    CircleImage {
      Layout.alignment: Qt.AlignTop
      diameter: 32
      source: Settings.profilePicture !== "" ? "file://" + Settings.profilePicture : ""
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignTop
      spacing: 2

      Looks.ClearText {
        Layout.fillWidth: true
        text: Quickshell.env("USER")
        color: Settings.textColorOnContainer
        font.pixelSize: Looks.Fonts.size + 2
        font.weight: Font.Bold
        elide: Text.ElideRight
      }

      Looks.ClearText {
        Layout.fillWidth: true
        text: Session.uptime
        font.pixelSize: Looks.Fonts.size - 1
        font.italic: true
        color: Settings.textColorOnContainer
        elide: Text.ElideRight
      }
    }
  }

  BtnGroup {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 8
    onPrimaryBg: true
    options: ["\u{f033e}", "\u{f0425}"]
    onNewClick: index => {
      GlobalStates.isControlCenterOpen = false
      if (index === 0) Session.lock()
      else GlobalStates.isPowerMenuOpen = true
    }
  }
}

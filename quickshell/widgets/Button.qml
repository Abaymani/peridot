import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.common.looks as Looks
import qs.common.functions
import qs

Rectangle {
  id: root
  signal clicked()

  required property string buttonText
  property bool toggleButton: false
  property bool checked: false
  property bool enabled: true
  property bool onPrimaryBg: false

  property int widthPadding: 20
  property int fontSizeModifier: 8
  property color textColor: Settings.textColorOnContainer
  property int h_centerOffset: 0

  color: Settings.gradientBgEnabled
    ? ColorUtils.setAlphaColor(Looks.Colors.md3.secondary, 0.5)
    : onPrimaryBg
      ? Looks.Colors.md3.secondary_container
      : Looks.Colors.md3.surface_container
  implicitWidth: btnText.implicitWidth + widthPadding
  opacity: !enabled ? 0.4 : toggleButton ? (checked ? 1 : 0.4) : 1
  radius: Looks.Decorations.decor.radius
  height: Looks.Decorations.decor.elementHeight

  Behavior on opacity {
    NumberAnimation {
      duration: 100
      easing.type: Easing.InOutQuad
    }
  }

  // Hover + click feedback, kept below the label so it never obscures the
  // text. Tinted with textColor rather than a fixed color so it reads
  // correctly against the button's fill either way - flat surface color or
  // gradient - since textColor is already chosen to contrast with both.
  //
  // Masked to root's exact (possibly per-corner, see BtnGroup) rounded
  // shape rather than just `clip: true`, since plain clipping only clips to
  // the bounding rect and would show square corners under a grown ripple.
  Item {
    id: feedbackLayer
    anchors.fill: parent
    layer.enabled: true
    visible: false

    Rectangle {
      anchors.fill: parent
      color: root.textColor
      opacity: mouseArea.containsMouse && root.enabled ? 0.08 : 0

      Behavior on opacity {
        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
      }
    }
  }

  Rectangle {
    id: feedbackMask
    anchors.fill: parent
    radius: root.radius
    topLeftRadius: root.topLeftRadius
    topRightRadius: root.topRightRadius
    bottomLeftRadius: root.bottomLeftRadius
    bottomRightRadius: root.bottomRightRadius
    layer.enabled: true
    visible: false
  }

  MultiEffect {
    anchors.fill: parent
    source: feedbackLayer
    maskEnabled: true
    maskSource: feedbackMask
  }

  Component {
    id: rippleComponent

    Rectangle {
      id: ripple
      required property real clickX
      required property real clickY
      property real targetDiameter: Math.max(root.width, root.height) * 2

      x: clickX - width / 2
      y: clickY - height / 2
      width: 0
      height: 0
      radius: width / 2
      color: root.textColor
      opacity: 0.22

      ParallelAnimation {
        running: true
        NumberAnimation { target: ripple; properties: "width,height"; to: ripple.targetDiameter; duration: 450; easing.type: Easing.OutQuad }
        NumberAnimation { target: ripple; property: "opacity"; to: 0; duration: 450; easing.type: Easing.OutQuad }
        onStopped: ripple.destroy()
      }
    }
  }

  Looks.ClearText {
    id: btnText
    anchors.centerIn: parent
    anchors.horizontalCenterOffset: h_centerOffset
    font.pixelSize: Looks.Fonts.size + fontSizeModifier
    text: buttonText
    color: textColor
  }

    MouseArea {
      id: mouseArea
      visible: root.enabled
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true

      onClicked: (mouse) => {
        rippleComponent.createObject(feedbackLayer, { clickX: mouse.x, clickY: mouse.y })
        root.clicked()
      }
  }
}

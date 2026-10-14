import QtQuick
import Qt5Compat.GraphicalEffects
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

  // Hover + click feedback after end-4's RippleButton (dots-hyprland): a
  // background that takes the hover color and holds the ripple, masked to
  // root's (possibly per-corner, see BtnGroup) rounded shape by an always-on
  // layer. The ripple starts on press, grows toward the farthest corner and
  // fades once released. Its look and timing follow the old ripple: a crisp
  // 22% circle over 450ms.
  //
  // Known issue: in the full shell this layer stops refreshing after a while
  // (hover and ripple show late or freeze). See the layer-free version.
  readonly property int rippleDuration: 450

  Rectangle {
    id: feedbackBackground
    anchors.fill: parent
    radius: root.radius
    topLeftRadius: root.topLeftRadius
    topRightRadius: root.topRightRadius
    bottomLeftRadius: root.bottomLeftRadius
    bottomRightRadius: root.bottomRightRadius
    // end-4's hover color is 8% of the way from the surface to its text color.
    color: ColorUtils.setAlphaColor(root.textColor, mouseArea.containsMouse && root.enabled ? 0.08 : 0)

    Behavior on color {
      ColorAnimation { duration: 200; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.34, 0.80, 0.34, 1.00, 1, 1] }
    }

    layer.enabled: true
    layer.effect: OpacityMask {
      maskSource: Rectangle {
        width: feedbackBackground.width
        height: feedbackBackground.height
        radius: root.radius
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
      }
    }

    Item {
      id: ripple
      property real size: 0
      width: size
      height: size
      opacity: 0
      visible: size > 0

      // The gradient's 0.5 is the item's edge, so this is a solid circle.
      RadialGradient {
        anchors.fill: parent
        gradient: Gradient {
          GradientStop { position: 0.0; color: ColorUtils.setAlphaColor(root.textColor, 0.22) }
          GradientStop { position: 0.49; color: ColorUtils.setAlphaColor(root.textColor, 0.22) }
          GradientStop { position: 0.5; color: ColorUtils.setAlphaColor(root.textColor, 0) }
        }
      }

      transform: Translate {
        x: -ripple.width / 2
        y: -ripple.height / 2
      }
    }
  }

  function startRipple(x: real, y: real): void {
    rippleGrow.centerX = x
    rippleGrow.centerY = y
    rippleGrow.reach = Math.max(
      Math.hypot(x, y),
      Math.hypot(root.width - x, y),
      Math.hypot(x, root.height - y),
      Math.hypot(root.width - x, root.height - y))
    rippleFade.complete()
    rippleGrow.restart()
  }

  SequentialAnimation {
    id: rippleGrow
    property real centerX
    property real centerY
    property real reach

    PropertyAction { target: ripple; property: "x"; value: rippleGrow.centerX }
    PropertyAction { target: ripple; property: "y"; value: rippleGrow.centerY }
    PropertyAction { target: ripple; property: "opacity"; value: 1 }
    NumberAnimation {
      target: ripple
      property: "size"
      from: 0
      to: rippleGrow.reach * 2
      duration: root.rippleDuration
      easing.type: Easing.OutQuad
    }
  }

  NumberAnimation {
    id: rippleFade
    target: ripple
    property: "opacity"
    to: 0
    duration: root.rippleDuration
    easing.type: Easing.OutQuad
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

      onPressed: (mouse) => root.startRipple(mouse.x, mouse.y)
      onReleased: rippleFade.restart()
      onCanceled: rippleFade.restart()
      onClicked: root.clicked()
  }
}

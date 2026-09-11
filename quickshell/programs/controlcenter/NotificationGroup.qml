import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common.looks as Looks
import qs.common.functions
import qs.services
import qs.widgets
import qs

// One app's notifications in the control center. Several stack up: the newest
// on top, up to two more peeking out below it, and a count of the rest.
// Hovering or pinning fans the stack out into a plain list under a header with
// the group's name, count, pin and clear buttons.
Item {
  id: root

  required property string appName

  readonly property var group: Notifications.groupsByAppName[root.appName]
  readonly property var notifIds: group ? group.notifIds : []
  readonly property int count: notifIds.length
  readonly property bool stacked: count > 1

  readonly property bool pinned: Notifications.pinnedAppNames.includes(root.appName)
  property bool hoverExpanded: false
  readonly property bool expanded: stacked && (pinned || hoverExpanded)
  // 0 = stacked, 1 = list. Drives every card's position, size and fade.
  property real progress: expanded ? 1 : 0
  Behavior on progress {
    NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
  }

  readonly property int peek: 6
  property Item topCard: null
  readonly property real topHeight: topCard ? topCard.implicitHeight : 0
  readonly property real collapsedHeight: topHeight + peek * Math.max(0, Math.min(count - 1, 2))
  // Room the header takes above the cards once they've fanned out.
  readonly property real headerSpace: header.implicitHeight + cards.spacing
  readonly property real expandedHeight: headerSpace + cards.implicitHeight

  function mix(a, b, t) { return a + (b - a) * t }

  // Falls back to parent.width when not a direct ListView delegate.
  width: ListView.view?.width ?? parent.width
  implicitHeight: mix(collapsedHeight, expandedHeight, progress)

  // Hover intent: a pointer passing over on its way elsewhere doesn't fan the
  // stack out, and leaving briefly doesn't snap it shut.
  HoverHandler {
    enabled: root.stacked
    onHoveredChanged: {
      if (hovered) {
        collapseTimer.stop()
        expandTimer.restart()
      } else {
        expandTimer.stop()
        collapseTimer.restart()
      }
    }
  }

  Timer {
    id: expandTimer
    interval: 150
    onTriggered: root.hoverExpanded = true
  }

  Timer {
    id: collapseTimer
    interval: 300
    onTriggered: root.hoverExpanded = false
  }

  // The group's own controls, revealed in the room the cards make as they
  // slide down.
  Item {
    width: parent.width
    height: Math.max(0, cards.y - cards.spacing)
    visible: root.progress > 0
    opacity: root.progress
    clip: true

    RowLayout {
      id: header
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      spacing: 6

      Image {
        Layout.preferredWidth: 16
        Layout.preferredHeight: 16
        Layout.leftMargin: 4
        source: root.group && root.group.appIcon ? Quickshell.iconPath(root.group.appIcon) : ""
        fillMode: Image.PreserveAspectFit
        visible: source.toString() !== ""
      }

      Looks.ClearText {
        Layout.fillWidth: true
        text: root.appName + "  ·  " + root.count
        font.pixelSize: Looks.Fonts.size - 1
        opacity: 0.6
        color: Settings.textColorOnContainer
        elide: Text.ElideRight
      }

      Button {
        toggleButton: true
        checked: root.pinned
        buttonText: "\u{f0403}"
        fontSizeModifier: -1
        widthPadding: 14
        onClicked: Notifications.togglePinned(root.appName)
      }

      Button {
        buttonText: "\u{f06cc}"
        fontSizeModifier: -1
        widthPadding: 14
        onClicked: Notifications.dismissGroup(root.appName)
      }
    }
  }

  // Lays the cards out as the expanded list; while stacked, each is moved back
  // up behind the top one.
  Column {
    id: cards
    // Slides down to make room for the header as the group fans out.
    y: root.headerSpace * root.progress
    width: parent.width
    spacing: 6

    Repeater {
      model: root.notifIds

      // Repeater's own `modelData` would shadow NotificationItem's, so the id
      // is looked up by `index` instead.
      delegate: Item {
        id: slot
        required property int index
        readonly property int depth: Math.min(index, 2)
        readonly property real cardScale: root.mix(1 - 0.05 * depth, 1, root.progress)
        // Bottom edges move in a straight line: from `peek` below the card in
        // front (stacked) to their place in the list (expanded).
        readonly property real bottomY: root.mix(root.topHeight + root.peek * depth, y + height, root.progress)
        readonly property real frontBottomY: root.mix(root.topHeight + root.peek * Math.min(index - 1, 2),
                                                      y - cards.spacing, root.progress)
        // The part (unscaled) still under the card in front - cut away, or the
        // translucent cards would show through each other.
        readonly property real covered: index === 0 ? 0
          : Math.min(height, Math.max(0, (frontBottomY - (bottomY - height * cardScale)) / cardScale))

        width: cards.width
        // Back cards take the top card's height while stacked.
        height: index === 0 ? card.implicitHeight : root.mix(root.topHeight, card.implicitHeight, root.progress)
        z: -index
        opacity: index === 0 ? 1
          : index <= 2 ? root.mix(depth === 1 ? 0.8 : 0.55, 1, root.progress)
          : root.progress
        // Keeps the hidden buttons on back cards from being clicked through the peek.
        enabled: index === 0 || root.progress === 1

        transform: [
          Scale {
            origin.x: slot.width / 2
            origin.y: slot.height
            xScale: slot.cardScale
            yScale: slot.cardScale
          },
          Translate { y: slot.bottomY - (slot.y + slot.height) }
        ]

        Item {
          y: slot.covered
          width: slot.width
          height: slot.height - slot.covered
          clip: true

          NotificationItem {
            id: card
            y: -slot.covered
            width: slot.width
            height: slot.height
            notifId: root.notifIds[slot.index]
            // Back cards hide their text until the group has mostly fanned out.
            contentOpacity: slot.index === 0 ? 1 : Math.max(0, (root.progress - 0.4) / 0.6)
          }
        }

        Component.onCompleted: if (index === 0) root.topCard = card
      }
    }
  }

  // How many more are behind the top card.
  Rectangle {
    visible: root.stacked && opacity > 0
    opacity: 1 - root.progress
    anchors.right: parent.right
    anchors.rightMargin: 10
    y: cards.y + root.topHeight - height / 2
    width: countLabel.implicitWidth + 12
    height: 16
    radius: height / 2
    color: Settings.gradientBgEnabled
      ? ColorUtils.setAlphaColor(Looks.Colors.md3.secondary, 0.5)
      : Looks.Colors.md3.surface_container

    Looks.ClearText {
      id: countLabel
      anchors.centerIn: parent
      text: "+" + (root.count - 1)
      font.pixelSize: Looks.Fonts.size - 2
      font.weight: Font.Bold
      color: Settings.textColorOnContainer
    }
  }
}

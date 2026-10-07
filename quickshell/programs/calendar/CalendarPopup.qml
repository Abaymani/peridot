import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.widgets
import qs.common.looks as Looks
import qs.common.functions

// A card popped up from something in the calendar, like the tray menus: its
// own popup surface, so Hyprland blurs what's behind it (blur_popups),
// the calendar included. Below the target, or beside it.
PopupWindow {
  id: root

  property Item target: null
  property bool beside: false
  property int cardWidth: 270
  property int gap: 6
  default property alias content: column.data

  function showFor(item: Item): void {
    target = item;
    if (visible) anchor.updateAnchor();
    else visible = true;
  }

  color: "transparent"
  implicitWidth: card.width
  implicitHeight: card.height

  anchor.item: target
  anchor.edges: beside ? Edges.Right : Edges.Bottom
  anchor.gravity: beside ? Edges.Right : Edges.Bottom
  anchor.adjustment: beside
    ? (PopupAdjustment.FlipX | PopupAdjustment.SlideY)
    : (PopupAdjustment.SlideX | PopupAdjustment.FlipY)

  // Anchor rects aren't reactive; this runs just before the anchor is used.
  // The gap is added to the side the card comes out of (on a flip too).
  Connections {
    target: root.anchor

    function onAnchoring(): void {
      if (!root.target) return;
      root.anchor.rect = root.beside
        ? Qt.rect(-root.gap, 0, root.target.width + root.gap * 2, root.target.height)
        : Qt.rect(0, -root.gap, root.target.width, root.target.height + root.gap * 2);
    }
  }

  PopupCard {
    id: card
    width: root.cardWidth
    height: column.implicitHeight + 24
    // An edge on the glass look only; flat surfaces go without.
    border.width: Settings.gradientBgEnabled ? 1 : 0
    border.color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, 0.12)

    ColumnLayout {
      id: column
      x: 12
      y: 12
      width: parent.width - 24
      spacing: 6
    }
  }
}

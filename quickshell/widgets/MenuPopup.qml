pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.common.looks as Looks
import qs.common.functions
import qs

// Themed replacement for QsMenuAnchor, which renders a Qt Widgets QMenu styled
// by qt6ct rather than QML. QsMenuOpener exposes the same DBus menu as data, so
// we can draw it ourselves.
//
// Recurses for submenus through submenuLoader's url - QML rejects a type that
// references itself by name.
PopupWindow {
  id: root

  // A tray item's `menu`, or the QsMenuEntry of the parent row for a submenu.
  property QsMenuHandle menuHandle: null
  property Item anchorItem: null
  // Root menus only; submenus anchor to their row instead.
  property var anchorWindow: null
  property bool isSubmenu: false
  // Top of the chain, so an entry at any depth can close all of it.
  property var rootMenu: root
  // Space between the bar and a root menu.
  property int gap: 4

  property int padding: 6
  property int minWidth: 170
  property int maxWidth: 420
  // Hover dwell before a submenu opens, so crossing rows on the way to an open
  // one doesn't swap it out from under the pointer.
  property int submenuDelay: 180

  color: "transparent"

  implicitWidth: Math.max(root.minWidth, Math.min(root.maxWidth, content.implicitWidth + root.padding * 2))
  implicitHeight: content.implicitHeight + root.padding * 2

  // No `grabFocus`: an xdg popup grab only routes input to surfaces that took
  // it themselves, which leaves submenus dead to the pointer. The root holds a
  // single HyprlandFocusGrab over the whole chain instead.

  anchor.edges: root.isSubmenu ? (Edges.Top | Edges.Right) : (Edges.Bottom | Edges.Left)
  // Down-right gravity pins the popup's top-left to the anchor point, so it
  // grows in place as contents arrive over DBus rather than jumping.
  anchor.gravity: Edges.Bottom | Edges.Right
  anchor.adjustment: root.isSubmenu
    ? (PopupAdjustment.FlipX | PopupAdjustment.SlideY)
    : (PopupAdjustment.SlideX | PopupAdjustment.SlideY)
  // Margins are removed from the anchor rect, so a negative top grows it upward
  // - here aligning a submenu's first row with the parent row.
  anchor.margins.top: root.isSubmenu ? -root.padding : 0

  // anchor.window and anchor.item clear each other, so only one may ever write.
  Binding {
    target: root.anchor
    property: "window"
    value: root.anchorWindow
    when: !root.isSubmenu && root.anchorWindow !== null
  }

  Binding {
    target: root.anchor
    property: "item"
    value: root.anchorItem
    when: root.isSubmenu && root.anchorItem !== null
  }

  // Anchor rects aren't reactive; `anchoring` fires just before the anchor is
  // used, when mapToItem is current. Anchoring to the bar window rather than the
  // icon drops the menu from the bar's bottom edge, still aligned to the icon.
  Connections {
    target: root.anchor
    enabled: !root.isSubmenu

    function onAnchoring() {
      const window = root.anchorWindow;
      const item = root.anchorItem;
      if (!window || !item) return;

      const pos = item.mapToItem(window.contentItem, 0, 0);
      root.anchor.rect = Qt.rect(pos.x, 0, item.width, window.contentItem.height + root.gap);
    }
  }

  // Holding a menu is what makes the tray app populate it over DBus, so only do
  // so while shown. Keyed on `visible` since the grab can close us directly.
  QsMenuOpener {
    id: opener
    menu: root.visible ? root.menuHandle : null
  }

  readonly property var entries: opener.children ? opener.children.values : []

  // Shared column for icons and check marks, dropped when nothing needs it.
  readonly property bool hasLeadingColumn: {
    for (let i = 0; i < root.entries.length; i++) {
      const entry = root.entries[i];
      if (entry.buttonType !== QsMenuButtonType.None || entry.icon !== "") return true;
    }
    return false;
  }

  // At most one submenu per level.
  property int openIndex: -1
  property Item openAnchor: null

  function showSubmenu(index: int, entry: var, item: Item): void {
    root.openIndex = index;
    root.openAnchor = item;

    if (index < 0 || !entry || !item) {
      submenuLoader.active = false;
      root.rootMenu.refreshGrab();
      return;
    }

    // Initial properties, so the child is configured before it completes.
    submenuLoader.setSource(Qt.resolvedUrl("MenuPopup.qml"), {
      menuHandle: entry,
      anchorItem: item,
      isSubmenu: true,
      rootMenu: root.rootMenu,
      padding: root.padding,
      minWidth: root.minWidth,
      maxWidth: root.maxWidth,
      submenuDelay: root.submenuDelay,
      visible: true
    });
    submenuLoader.active = true;
    root.rootMenu.refreshGrab();
  }

  function requestSubmenu(index: int, entry: var, item: Item): void {
    const wanted = (entry && entry.enabled && entry.hasChildren) ? index : -1;
    if (wanted === root.openIndex) {
      submenuTimer.stop();
      return;
    }

    submenuTimer.pendingIndex = wanted;
    submenuTimer.pendingEntry = wanted < 0 ? null : entry;
    submenuTimer.pendingAnchor = wanted < 0 ? null : item;
    submenuTimer.restart();
  }

  // The grab must whitelist every window, or a click on a submenu reads as a
  // click outside and dismisses everything.
  function windowChain(): var {
    const child = submenuLoader.item;
    return child ? [root].concat(child.windowChain()) : [root];
  }

  function refreshGrab(): void {
    if (root.isSubmenu) {
      root.rootMenu.refreshGrab();
      return;
    }
    root.grabWindows = root.windowChain();
  }

  property var grabWindows: [root]

  HyprlandFocusGrab {
    windows: root.grabWindows
    // Waits on the backing window so the grab has a surface to whitelist;
    // submenu surfaces that appear later are picked up on their own.
    active: root.backingWindowVisible && !root.isSubmenu
    onCleared: root.dismiss()
  }

  function dismiss(): void {
    submenuTimer.stop();
    root.showSubmenu(-1, null, null);
    root.visible = false;
  }

  Timer {
    id: submenuTimer
    interval: root.submenuDelay

    property int pendingIndex: -1
    property var pendingEntry: null
    property Item pendingAnchor: null

    onTriggered: root.showSubmenu(submenuTimer.pendingIndex, submenuTimer.pendingEntry, submenuTimer.pendingAnchor)
  }

  // Collapses the chain when the grab closes us without going through dismiss().
  onVisibleChanged: {
    if (!root.visible) {
      submenuTimer.stop();
      root.showSubmenu(-1, null, null);
    }
  }

  Loader {
    id: submenuLoader
    active: false

    // In case the item lands after showSubmenu() returns.
    onLoaded: root.rootMenu.refreshGrab()
  }

  Rectangle {
    anchors.fill: parent
    radius: Looks.Decorations.decor.radius
    color: Looks.Colors.md3.secondary_container
    gradient: Settings.gradientBgEnabled
      ? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject()
      : null
    border.width: 1
    border.color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, 0.12)

    BackdropFloor {}

    ColumnLayout {
      id: content
      anchors.fill: parent
      anchors.margins: root.padding
      spacing: 2

      Repeater {
        model: opener.children

        delegate: Item {
          id: entryRow

          required property var modelData
          required property int index

          readonly property bool isSeparator: entryRow.modelData.isSeparator
          readonly property bool interactive: !entryRow.isSeparator && entryRow.modelData.enabled

          Layout.fillWidth: true
          implicitWidth: entryRow.isSeparator ? 0 : rowContent.implicitWidth + 16
          implicitHeight: entryRow.isSeparator
            ? 7
            : Math.max(Looks.Decorations.decor.elementHeight, rowContent.implicitHeight + 6)

          // Tinted with the text color so it reads on a flat fill and a gradient alike.
          Rectangle {
            anchors.fill: parent
            visible: !entryRow.isSeparator
            radius: Math.max(0, Looks.Decorations.decor.radius - root.padding)
            color: Settings.textColorOnContainer
            opacity: entryRow.interactive && (hoverArea.containsMouse || root.openIndex === entryRow.index) ? 0.12 : 0

            Behavior on opacity {
              NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
            }
          }

          Rectangle {
            visible: entryRow.isSeparator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 1
            color: Looks.Colors.palette.neutral100
            opacity: 0.25
          }

          RowLayout {
            id: rowContent
            visible: !entryRow.isSeparator
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8
            opacity: entryRow.interactive ? 1 : 0.4

            Item {
              visible: root.hasLeadingColumn
              Layout.preferredWidth: Looks.Fonts.size + 4
              Layout.preferredHeight: Looks.Fonts.size + 4
              Layout.alignment: Qt.AlignVCenter

              IconImage {
                anchors.fill: parent
                visible: entryRow.modelData.buttonType === QsMenuButtonType.None && entryRow.modelData.icon !== ""
                source: entryRow.modelData.icon
              }

              Looks.ClearText {
                anchors.centerIn: parent
                visible: entryRow.modelData.buttonType !== QsMenuButtonType.None
                color: Settings.textColorOnContainer
                text: entryRow.modelData.buttonType === QsMenuButtonType.RadioButton ? "●" : "✓"
                opacity: entryRow.modelData.checkState === Qt.Checked
                  ? 1
                  : entryRow.modelData.checkState === Qt.PartiallyChecked ? 0.45 : 0
              }
            }

            Looks.ClearText {
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignVCenter
              // Quickshell already strips the DBusMenu mnemonic underscores.
              text: entryRow.modelData.text
              color: Settings.textColorOnContainer
              elide: Text.ElideRight
              verticalAlignment: Text.AlignVCenter
            }

            Looks.ClearText {
              visible: entryRow.modelData.hasChildren
              Layout.alignment: Qt.AlignVCenter
              text: "▸"
              color: Settings.textColorOnContainer
              opacity: 0.7
            }
          }

          MouseArea {
            id: hoverArea
            anchors.fill: parent
            enabled: !entryRow.isSeparator
            hoverEnabled: true
            cursorShape: entryRow.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor

            // Only `entered`, never `exited` - moving into a submenu must not close it.
            onEntered: root.requestSubmenu(entryRow.index, entryRow.modelData, entryRow)

            onClicked: {
              if (!entryRow.interactive) return;

              if (entryRow.modelData.hasChildren) {
                submenuTimer.stop();
                root.showSubmenu(entryRow.index, entryRow.modelData, entryRow);
                return;
              }

              entryRow.modelData.triggered();
              root.rootMenu.dismiss();
            }
          }
        }
      }
    }
  }
}

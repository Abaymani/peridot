import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs

ColumnLayout {
  id: root

  required property string appName

  readonly property var group: Notifications.groupsByAppName[root.appName]
  readonly property var notifIds: group ? group.notifIds : []
  readonly property int count: notifIds.length
  readonly property bool multiple: count > 1

  property bool expanded: false

  readonly property var visibleNotifIds: multiple && !expanded ? notifIds.slice(0, 2) : notifIds

  // Falls back to parent.width when not a direct ListView delegate.
  width: ListView.view?.width ?? parent.width
  Layout.fillWidth: true
  spacing: 6

  RowLayout {
    Layout.fillWidth: true
    spacing: 6
    visible: root.multiple

    Image {
      Layout.preferredWidth: 16
      Layout.preferredHeight: 16
      source: root.group && root.group.appIcon ? Quickshell.iconPath(root.group.appIcon) : ""
      fillMode: Image.PreserveAspectFit
      visible: source.toString() !== ""
    }

    Looks.ClearText {
      Layout.fillWidth: true
      text: (root.group ? root.group.appName : "") + "  ·  " + root.count
      font.pixelSize: Looks.Fonts.size - 1
      opacity: 0.6
      color: Settings.textColorOnContainer
      elide: Text.ElideRight
    }

    Button {
      buttonText: root.expanded ? "\u{f0143}" : "\u{f0140}"
      fontSizeModifier: -3
      widthPadding: 10
      onClicked: root.expanded = !root.expanded
    }
  }

  Repeater {
    model: root.visibleNotifIds

    // Repeater's own `modelData` would shadow NotificationItem's, so index
    // visibleNotifIds by `index` instead.
    delegate: NotificationItem {
      required property int index
      notifId: root.visibleNotifIds[index]
      // Indented while grouped to set it apart from the header above.
      Layout.leftMargin: root.multiple ? 12 : 0
    }
  }
}

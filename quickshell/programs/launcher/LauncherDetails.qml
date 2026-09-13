import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.common.functions
import qs.services
import qs.widgets
import qs

// The launcher's details pane: the selected app's description, categories,
// desktop actions and bookmark toggle, or the selected file's preview, size
// and date.
Rectangle {
  id: root

  // { app: DesktopEntry } or { file: a FileSearch result }, or null.
  property var target: null
  readonly property var app: target && target.app ? target.app : null
  readonly property var file: target && target.file ? target.file : null
  readonly property bool bookmarked: app !== null && AppBookmarks.has(app.id)
  readonly property bool preview: file !== null && file.isImage
  readonly property bool described: file !== null && FileSearch.info.path === file.path

  // Open was pressed; Qt.ControlModifier means "open the file's folder".
  signal openRequested(int modifiers)
  signal actionTriggered(var action)

  radius: Looks.Decorations.decor.radius
  color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral0, 0.15)
  gradient: Settings.gradientBgEnabled
    ? Looks.Gradients.library[Settings.activebackgroundGradient].createObject()
    : null

  onFileChanged: if (file && !file.isDir) FileSearch.describe(file.path)

  // Faded out rather than hidden when nothing is selected. Offscreen, the
  // pane stayed blank - with its layout and text right - when it appeared in
  // the same moment its target was set, which is why LauncherView keeps
  // `target` current while the pane is closed. Fading also keeps the content
  // from reappearing that way after a search with no matches.
  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 14
    spacing: 10
    opacity: root.target !== null ? 1 : 0
    enabled: root.target !== null

    EntryIcon {
      Layout.alignment: Qt.AlignHCenter
      Layout.topMargin: root.preview ? 0 : 20
      Layout.preferredWidth: root.preview ? parent.width : size
      Layout.preferredHeight: root.preview ? Math.round(parent.width * 0.625) : size
      size: 64
      radius: root.preview ? Looks.Decorations.decor.radius - 2 : 16
      icon: root.app ? root.app.icon : ""
      image: root.preview ? root.file.path : ""
      glyph: root.file ? FileSearch.glyphFor(root.file) : "\u{f08c6}"
    }

    Looks.ClearText {
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignHCenter
      text: root.app ? root.app.name : root.file ? root.file.name : ""
      font.pixelSize: Looks.Fonts.size + 5
      font.weight: Font.Bold
      wrapMode: Text.Wrap
      maximumLineCount: 2
      elide: Text.ElideRight
      color: Settings.textColorOnContainer
    }

    Looks.ClearText {
      Layout.fillWidth: true
      visible: text !== ""
      horizontalAlignment: Text.AlignHCenter
      text: root.app ? (root.app.comment || Apps.subtitle(root.app)) : root.file ? root.file.dir : ""
      wrapMode: Text.Wrap
      maximumLineCount: 3
      elide: Text.ElideRight
      opacity: 0.7
      color: Settings.textColorOnContainer
    }

    Flow {
      Layout.fillWidth: true
      spacing: 6

      Repeater {
        model: root.app
          ? (root.app.runInTerminal ? ["Terminal"] : [])
            .concat(Array.from(root.app.categories).filter(c => !/^(GTK|GNOME|Qt|KDE|X-.*)$/.test(c)))
            .slice(0, 3)
          : root.file && root.file.isDir ? ["Folder"]
          : root.described ? [FileSearch.formatSize(FileSearch.info.size), Qt.formatDate(FileSearch.info.modified, "d MMM yyyy")]
          : []

        delegate: Rectangle {
          required property var modelData
          implicitWidth: chip.implicitWidth + 16
          implicitHeight: 20
          radius: 10
          color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, 0.12)

          Looks.ClearText {
            id: chip
            anchors.centerIn: parent
            text: modelData
            font.pixelSize: Looks.Fonts.size - 2
            color: Settings.textColorOnContainer
          }
        }
      }
    }

    Item { Layout.fillHeight: true }

    // The app's desktop actions, e.g. a browser's "New Private Window".
    Repeater {
      model: root.app ? Array.from(root.app.actions).slice(0, 4) : []

      delegate: Item {
        id: action
        required property var modelData
        Layout.fillWidth: true
        implicitHeight: 26

        Rectangle {
          anchors.fill: parent
          radius: Looks.Decorations.decor.radius - 4
          color: Settings.textColorOnContainer
          opacity: actionArea.containsMouse ? 0.08 : 0
        }

        Looks.ClearText {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: 6
          anchors.verticalCenter: parent.verticalCenter
          text: "\u{f0142}  " + action.modelData.name
          elide: Text.ElideRight
          color: Settings.textColorOnContainer
        }

        MouseArea {
          id: actionArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.actionTriggered(action.modelData)
        }
      }
    }

    Looks.ClearText {
      Layout.fillWidth: true
      visible: root.app !== null && !root.bookmarked && AppBookmarks.full
      horizontalAlignment: Text.AlignHCenter
      text: "Bookmarks are full (" + AppBookmarks.max + ")"
      font.pixelSize: Looks.Fonts.size - 2
      opacity: 0.6
      color: Settings.textColorOnContainer
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 6

      Button {
        Layout.fillWidth: true
        Layout.preferredHeight: 32
        buttonText: "\u{f0311}  Open"
        fontSizeModifier: 0
        onClicked: root.openRequested(0)
      }

      Button {
        Layout.preferredHeight: 32
        visible: root.file !== null
        buttonText: "\u{f0770}"
        fontSizeModifier: 3
        widthPadding: 24
        onClicked: root.openRequested(Qt.ControlModifier)
      }

      Button {
        Layout.preferredHeight: 32
        visible: root.app !== null
        toggleButton: true
        checked: root.bookmarked
        enabled: root.bookmarked || !AppBookmarks.full
        buttonText: root.bookmarked ? "\u{f00c0}" : "\u{f00c3}"
        fontSizeModifier: 3
        widthPadding: 24
        onClicked: AppBookmarks.toggle(root.app.id)
      }
    }
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs

// The wallpaper picker's contents: header, carousel and footer. Enter or a
// click on the middle card sets that wallpaper and closes the picker; R sets
// a random one.
Item {
  id: root

  signal closeRequested()

  readonly property var focusedEntry: carousel.currentEntry
  // Kept through a rescan, which can add or drop images around it.
  property string focusedPath: ""

  implicitWidth: 1480
  implicitHeight: content.implicitHeight + 36

  // Called each time the picker opens.
  function reset(): void {
    focusedPath = ""
    carousel.jumpTo(Wallpapers.currentIndex)
    Wallpapers.rescan()
    forceActiveFocus()
  }

  function apply(entry): void {
    if (!entry) return
    Wallpapers.apply(entry.path)
    root.closeRequested()
  }

  function applyRandom(): void {
    Wallpapers.applyRandom()
    root.closeRequested()
  }

  function openSettings(): void {
    root.closeRequested()
    GlobalStates.openSettings("Wallpaper")
  }

  onFocusedEntryChanged: if (focusedEntry) focusedPath = focusedEntry.path

  Connections {
    target: Wallpapers

    function onWallpapersChanged() {
      const path = root.focusedPath || Wallpapers.current
      carousel.jumpTo(Wallpapers.wallpapers.findIndex(entry => entry.path === path))
    }
  }

  Keys.onPressed: event => {
    switch (event.key) {
    case Qt.Key_Left: carousel.move(-1); break
    case Qt.Key_Right: carousel.move(1); break
    case Qt.Key_PageUp: carousel.move(-5); break
    case Qt.Key_PageDown: carousel.move(5); break
    case Qt.Key_Home: carousel.select(0); break
    case Qt.Key_End: carousel.select(carousel.count - 1); break
    case Qt.Key_Return:
    case Qt.Key_Enter: root.apply(carousel.currentEntry); break
    case Qt.Key_R: root.applyRandom(); break
    case Qt.Key_Escape: root.closeRequested(); break
    default: return
    }
    event.accepted = true
  }

  ColumnLayout {
    id: content
    x: 18
    y: 18
    width: parent.width - 36
    spacing: 14

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      Looks.ClearText {
        text: "Wallpapers"
        font.pixelSize: Looks.Fonts.size + 3
        font.weight: Font.Bold
        color: Settings.textColorOnContainer
      }

      KeyCap {
        visible: carousel.count > 0
        text: (carousel.currentIndex + 1) + " / " + carousel.count
      }

      Looks.ClearText {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        text: "\u{f024b}  " + Wallpapers.tildePath(Wallpapers.folder)
        elide: Text.ElideMiddle
        font.pixelSize: Looks.Fonts.size - 1
        opacity: 0.65
        color: Settings.textColorOnContainer
      }

      Button {
        Layout.preferredHeight: Looks.Decorations.decor.elementHeight
        buttonText: "\u{f049d}  Random"
        fontSizeModifier: 0
        widthPadding: 24
        enabled: carousel.count > 1
        onClicked: root.applyRandom()
      }

      Button {
        Layout.preferredHeight: Looks.Decorations.decor.elementHeight
        buttonText: "\u{f0493}"
        fontSizeModifier: 2
        widthPadding: 16
        onClicked: root.openSettings()
      }
    }

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: carousel.implicitHeight

      WallpaperCarousel {
        id: carousel
        anchors.fill: parent
        model: Wallpapers.wallpapers
        currentPath: Wallpapers.current
        onActivated: index => root.apply(model[index])
      }

      ColumnLayout {
        anchors.centerIn: parent
        visible: carousel.count === 0
        spacing: 10

        Looks.ClearText {
          Layout.alignment: Qt.AlignHCenter
          text: "\u{f0e09}"
          font.pixelSize: 40
          opacity: 0.5
          color: Settings.textColorOnContainer
        }

        RowLayout {
          Layout.alignment: Qt.AlignHCenter
          spacing: 2

          Looks.ClearText {
            text: !Wallpapers.scanning
              ? "No images in " + Wallpapers.tildePath(Wallpapers.folder)
              : Wallpapers.scanTotal > 0
                ? "Making thumbnails, " + Wallpapers.scanDone + " of " + Wallpapers.scanTotal
                : "Looking for images"
            color: Settings.textColorOnContainer
          }

          LoadingDots {
            visible: Wallpapers.scanning
          }
        }

        Button {
          Layout.alignment: Qt.AlignHCenter
          visible: !Wallpapers.scanning
          buttonText: "Choose a folder..."
          fontSizeModifier: -1
          onClicked: root.openSettings()
        }
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 16

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Looks.ClearText {
          Layout.fillWidth: true
          text: root.focusedEntry?.name ?? ""
          elide: Text.ElideMiddle
          font.pixelSize: Looks.Fonts.size + 1
          font.weight: Font.Bold
          color: Settings.textColorOnContainer
        }

        Looks.ClearText {
          Layout.fillWidth: true
          text: Wallpapers.describe(root.focusedEntry)
            + (root.focusedEntry?.path === Wallpapers.current ? " · in use" : "")
          elide: Text.ElideRight
          font.pixelSize: Looks.Fonts.size - 1
          opacity: 0.65
          color: Settings.textColorOnContainer
        }
      }

      KeyHints {
        keys: [["←→", "browse"], ["↵", "apply"], ["R", "random"], ["Esc", "close"]]
      }
    }
  }
}

pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: font

  readonly property string family: "Iosevka"
  readonly property int size: 14
  readonly property int weight: Font.Normal
}
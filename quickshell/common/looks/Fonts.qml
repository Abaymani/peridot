pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: font

  readonly property string family: "JetBrainsMono Nerd Font"
  readonly property int size: 12
  readonly property int weight: Font.Normal
}
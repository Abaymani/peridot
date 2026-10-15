import QtQuick
import Quickshell

LazyLoader {
  property bool when: false

  onWhenChanged: if (when) active = true
  Component.onCompleted: if (when) active = true
}

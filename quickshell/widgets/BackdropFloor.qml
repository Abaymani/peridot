import QtQuick
import qs

// Settings.backdropFloor under a translucent surface's own gradient. Give it to
// surfaces that sit directly on whatever is behind the shell (window and panel
// backgrounds, popups, bar pills) - the negative z draws it under the parent's
// fill. Nested containers already sit on a floored surface; skip them.
Rectangle {
    property bool active: true

    anchors.fill: parent
    z: -1
    radius: parent.radius
    visible: active && Settings.gradientBgEnabled
    color: Settings.backdropFloor
}

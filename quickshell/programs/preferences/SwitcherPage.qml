import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.widgets
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    readonly property var previewModes: ["live", "still", "off"]

    Looks.ClearText {
        text: "Workspace switcher"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    SettingsRow {
        label: "Window previews"
        description: "Live keeps previews playing while the switcher is open. Still captures one frame when it opens, which is lighter on the GPU. Off shows only app icons."

        RadioBtnGroup {
            onPrimaryBg: true
            options: ["Live", "Still", "Off"]
            selectedIndex: Math.max(0, root.previewModes.indexOf(Settings.switcherPreviews))
            fontSizeModifier: -1
            onSelectionChanged: (idx) => Settings.switcherPreviews = root.previewModes[idx]
        }
    }

    SettingsRow {
        label: "Keys"
        description: "Hold Alt and press Tab to step through workspaces 1-6 (Shift+Tab goes back), then release Alt to switch. Click a workspace or window to go to it, or drag a window onto another workspace to move it there."
    }

    Item { Layout.fillHeight: true }
}

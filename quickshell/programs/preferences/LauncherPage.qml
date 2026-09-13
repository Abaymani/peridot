import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    Looks.ClearText {
        text: "Launcher"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    SettingsRow {
        label: "Details pane"
        description: "Shows the selected app's actions, or a preview of the selected file, beside the results. The launcher's own toggle saves straight away."

        Button {
            toggleButton: true
            checked: Settings.launcherDetailsPane
            buttonText: checked ? "On" : "Off"
            fontSizeModifier: -1
            onClicked: Settings.launcherDetailsPane = !Settings.launcherDetailsPane
        }
    }

    SettingsRow {
        label: "File search folders"
        description: FileSearch.roots.map(p => p.replace(FileSearch.home, "~")).join(", ")
            + ". These are your XDG user folders; hidden files and node_modules are skipped."
    }

    Item { Layout.fillHeight: true }
}

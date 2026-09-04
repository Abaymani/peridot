import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.common.looks as Looks
import qs.widgets
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    Looks.ClearText {
        text: "Profile"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 16

        CircleImage {
            diameter: 72
            source: Settings.profilePicture !== "" ? "file://" + Settings.profilePicture : ""
        }

        ColumnLayout {
            spacing: 8

            RowLayout {
                spacing: 8

                Button {
                    buttonText: "Browse..."
                    fontSizeModifier: -1
                    onClicked: pickerProc.running = true
                }

                Button {
                    buttonText: "Clear"
                    fontSizeModifier: -1
                    enabled: Settings.profilePicture !== ""
                    onClicked: Settings.profilePicture = ""
                }
            }

            Looks.ClearText {
                Layout.maximumWidth: 300
                text: Settings.profilePicture !== "" ? Settings.profilePicture : "No picture set - using placeholder."
                font.pixelSize: Looks.Fonts.size - 2
                opacity: 0.65
                color: Settings.textColorOnContainer
                elide: Text.ElideMiddle
            }
        }
    }

    Process {
        id: pickerProc
        command: ["zenity", "--file-selection", "--title=Choose profile picture", "--file-filter=Images | *.png *.jpg *.jpeg *.webp *.bmp *.gif"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const path = this.text.trim()
                if (path !== "") Settings.profilePicture = path
            }
        }
    }

    Item { Layout.fillHeight: true }
}

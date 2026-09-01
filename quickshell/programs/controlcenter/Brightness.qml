import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.widgets
import qs.common.looks as Looks

Pill {
    id: root
    property bool hovering: false

    Process {
        id: brilloProc
        command: ["sh", "-c", "brillo -G"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {brightnessSlider.value = this.text}
        }
    }

    IpcHandler {
        target: "brightness"
        function update(val: real): void {
            brightnessSlider.value = val/100
        }
    }

    MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: root.hovering = true
    onExited: root.hovering = false

        RowLayout {
            id: mainLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 8
            spacing: 8

            Slider {
                id: brightnessSlider
                Layout.fillWidth: true
                trackWidth: 15
                from: 0
                to: 1

                onMoved: {
                    let percent = Math.round(value * 100);
                    Quickshell.execDetached(["brillo", "-u", "200000", "-S", percent.toString()]);
                    brightnessSlider.value = value
                }
            }

            Looks.ClearText {
                text: root.hovering ? (Math.round(brightnessSlider.value *100) + "%").padStart(4, ' ') : "󰃟"
                leftPadding: root.hovering ? 0 : 3
                rightPadding: root.hovering ? 0 : 3
                font.pixelSize: root.hovering ? Looks.Fonts.size-2 :  Looks.Fonts.size + 5
                color: Settings.textColorOnContainer
            }
        }
    }
}

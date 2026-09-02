import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs

// A single "label (+ optional description) on the left, one control on the
// right" settings entry. Declare the control as a normal child, e.g.:
//   SettingsRow { label: "Foo"; Button { ... } }
RowLayout {
    id: root

    property string label: ""
    property string description: ""

    Layout.fillWidth: true
    spacing: 16

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Looks.ClearText {
            Layout.fillWidth: true
            text: root.label
            color: Settings.textColorOnContainer
            elide: Text.ElideRight
        }

        Looks.ClearText {
            Layout.fillWidth: true
            text: root.description
            visible: root.description !== ""
            font.pixelSize: Looks.Fonts.size - 2
            opacity: 0.65
            color: Settings.textColorOnContainer
            wrapMode: Text.WordWrap
        }
    }
}

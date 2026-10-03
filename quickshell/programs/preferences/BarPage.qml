import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common.looks as Looks
import qs.programs.bar
import qs.widgets
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    readonly property var zoneNames: ({ left: "Left", center: "Center", right: "Right", hidden: "Hidden" })
    readonly property var memoryModes: ["amount", "percent", "hidden"]

    function preview(format, part) {
        return format === ""
            ? "Empty, so the " + part + " is hidden."
            : "Shows as “" + Qt.formatDateTime(previewClock.date, format) + "”."
    }

    SystemClock {
        id: previewClock
        precision: SystemClock.Seconds
    }

    Looks.ClearText {
        text: "Bar"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    SettingsRow {
        label: "Widgets"
        description: "Where each widget sits on the bar, or whether it's hidden. The arrows order a section from left to right. The bar shows changes right away; Save keeps them."

        Button {
            buttonText: "Reset"
            fontSizeModifier: -1
            onClicked: BarWidgets.reset()
        }
    }

    Repeater {
        model: BarWidgets.zones

        ColumnLayout {
            id: zone
            required property string modelData
            readonly property var widgets: BarWidgets.layout[modelData]

            Layout.fillWidth: true
            spacing: 10

            SectionLabel {
                leftPadding: 0
                text: root.zoneNames[zone.modelData]
            }

            Looks.ClearText {
                visible: zone.widgets.length === 0
                text: zone.modelData === "hidden" ? "Every widget is on the bar." : "Nothing here."
                font.pixelSize: Looks.Fonts.size - 1
                opacity: 0.5
                color: Settings.textColorOnContainer
            }

            Repeater {
                model: zone.widgets

                RowLayout {
                    id: row
                    required property string modelData
                    required property int index
                    readonly property var widget: BarWidgets.find(modelData)

                    Layout.fillWidth: true
                    spacing: 10

                    Looks.ClearText {
                        Layout.preferredWidth: 24
                        horizontalAlignment: Text.AlignHCenter
                        text: row.widget.glyph
                        font.pixelSize: Looks.Fonts.size + 4
                        color: Settings.textColorOnContainer
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Looks.ClearText {
                            Layout.fillWidth: true
                            text: row.widget.name
                            elide: Text.ElideRight
                            color: Settings.textColorOnContainer
                        }

                        Looks.ClearText {
                            Layout.fillWidth: true
                            text: row.widget.description
                            font.pixelSize: Looks.Fonts.size - 2
                            opacity: 0.65
                            wrapMode: Text.WordWrap
                            color: Settings.textColorOnContainer
                        }
                    }

                    // Hidden widgets have no order.
                    Button {
                        visible: zone.modelData !== "hidden"
                        buttonText: "\u{f0143}"
                        fontSizeModifier: -1
                        widthPadding: 14
                        enabled: row.index > 0
                        onClicked: BarWidgets.shift(row.modelData, -1)
                    }

                    Button {
                        visible: zone.modelData !== "hidden"
                        buttonText: "\u{f0140}"
                        fontSizeModifier: -1
                        widthPadding: 14
                        enabled: row.index < zone.widgets.length - 1
                        onClicked: BarWidgets.shift(row.modelData, 1)
                    }

                    RadioBtnGroup {
                        onPrimaryBg: true
                        options: BarWidgets.zones.map(name => root.zoneNames[name])
                        selectedIndex: BarWidgets.zones.indexOf(zone.modelData)
                        fontSizeModifier: -1
                        onSelectionChanged: (idx) => {
                            if (BarWidgets.zones[idx] !== zone.modelData) BarWidgets.moveTo(row.modelData, BarWidgets.zones[idx])
                        }
                    }
                }
            }
        }
    }

    Looks.ClearText {
        Layout.topMargin: 8
        text: "Widget options"
        font.pixelSize: Looks.Fonts.size + 4
        color: Settings.textColorOnContainer
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        SectionLabel {
            leftPadding: 0
            text: "Clock"
        }

        SettingsRow {
            label: "Date format"
            description: root.preview(Settings.barDateFormat, "date")

            TextBox {
                Layout.preferredWidth: 180
                text: Settings.barDateFormat
                placeholderText: "hidden"
                onTextEdited: Settings.barDateFormat = text
            }
        }

        SettingsRow {
            label: "Time format"
            description: root.preview(Settings.barTimeFormat, "time")

            TextBox {
                Layout.preferredWidth: 180
                text: Settings.barTimeFormat
                placeholderText: "hidden"
                onTextEdited: Settings.barTimeFormat = text
            }
        }

        Looks.ClearText {
            Layout.fillWidth: true
            text: "Codes: d dd day, ddd dddd weekday, M MM month, MMM MMMM month name, yy yyyy year, "
                + "HH 24-hour, hh with AP 12-hour, mm minutes, ss seconds. Text in 'single quotes' shows as typed."
            wrapMode: Text.WordWrap
            font.pixelSize: Looks.Fonts.size - 2
            opacity: 0.65
            color: Settings.textColorOnContainer
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        SectionLabel {
            leftPadding: 0
            text: "Network"
        }

        SettingsRow {
            label: "Status"
            description: "The connection's icon and Wi-Fi name, or Wired."

            Button {
                toggleButton: true
                checked: Settings.barNetworkStatus
                buttonText: checked ? "On" : "Off"
                fontSizeModifier: -1
                onClicked: Settings.barNetworkStatus = !Settings.barNetworkStatus
            }
        }

        SettingsRow {
            label: "Speed"
            description: "Download and upload speeds. With both off, the widget hides."

            Button {
                toggleButton: true
                checked: Settings.barNetworkSpeed
                buttonText: checked ? "On" : "Off"
                fontSizeModifier: -1
                onClicked: Settings.barNetworkSpeed = !Settings.barNetworkSpeed
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        SectionLabel {
            leftPadding: 0
            text: "Resources"
        }

        SettingsRow {
            label: "Memory"
            description: "Memory in use, as gigabytes of the total or as a percentage."

            RadioBtnGroup {
                onPrimaryBg: true
                options: ["Used / total", "Percent", "Hidden"]
                selectedIndex: Math.max(0, root.memoryModes.indexOf(Settings.barMemoryDisplay))
                fontSizeModifier: -1
                onSelectionChanged: (idx) => Settings.barMemoryDisplay = root.memoryModes[idx]
            }
        }

        SettingsRow {
            label: "CPU"
            description: "CPU usage. With memory hidden too, the widget hides."

            Button {
                toggleButton: true
                checked: Settings.barCpuUsage
                buttonText: checked ? "On" : "Off"
                fontSizeModifier: -1
                onClicked: Settings.barCpuUsage = !Settings.barCpuUsage
            }
        }
    }

    Item { Layout.fillHeight: true }
}

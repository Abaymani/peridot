import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    readonly property var scalings: ["fill", "fit", "center", "stretch"]
    readonly property var transitions: [
        {id: "none", name: "None", hint: "Switches instantly."},
        {id: "simple", name: "Simple", hint: "A plain crossfade."},
        {id: "fade", name: "Fade", hint: "A crossfade that eases in and out."},
        {id: "wipe", name: "Wipe", hint: "A straight edge sweeps across, at the angle below."},
        {id: "wave", name: "Wave", hint: "A wavy edge sweeps across, at the angle below."},
        {id: "grow", name: "Grow", hint: "A circle grows from the middle."},
        {id: "outer", name: "Outer", hint: "A circle shrinks into the middle."},
        {id: "any", name: "Any", hint: "A circle grows from a random spot."},
        {id: "random", name: "Random", hint: "A different effect every time."}
    ]
    readonly property int transitionIndex: transitions.findIndex(t => t.id === Settings.wallpaperTransition)
    readonly property bool usesAngle: ["wipe", "wave"].includes(Settings.wallpaperTransition)
    readonly property bool usesFillColor: ["fit", "center"].includes(Settings.wallpaperScaling)
    readonly property var backends: Wallpapers.installedBackends.length > 0 ? Wallpapers.installedBackends : [Settings.wallpaperBackend]

    Looks.ClearText {
        text: "Wallpaper"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 16

        ClippingRectangle {
            implicitWidth: 192
            implicitHeight: 108
            radius: Looks.Decorations.decor.radius
            color: Looks.Colors.md3.surface_container_lowest

            Image {
                anchors.fill: parent
                source: Wallpapers.currentEntry ? Wallpapers.fileUrl(Wallpapers.currentEntry.thumbnail) : ""
                sourceSize: Qt.size(384, 216)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Looks.ClearText {
                Layout.fillWidth: true
                text: Wallpapers.currentEntry?.name
                    ?? (Settings.currentWallpaper !== "" ? Settings.currentWallpaper.split("/").pop() : "No wallpaper set")
                elide: Text.ElideMiddle
                font.pixelSize: Looks.Fonts.size + 1
                font.weight: Font.Bold
                color: Settings.textColorOnContainer
            }

            Looks.ClearText {
                Layout.fillWidth: true
                text: Wallpapers.currentEntry
                    ? Wallpapers.describe(Wallpapers.currentEntry)
                    : Settings.currentWallpaper !== "" ? "Not in the wallpaper folder" : ""
                elide: Text.ElideRight
                font.pixelSize: Looks.Fonts.size - 1
                opacity: 0.65
                color: Settings.textColorOnContainer
            }

            RowLayout {
                Layout.topMargin: 10
                spacing: 8

                Button {
                    buttonText: "\u{f0e09}  Choose..."
                    fontSizeModifier: -1
                    onPrimaryBg: true
                    onClicked: GlobalStates.isWallpaperPickerOpen = true
                }

                Button {
                    buttonText: "\u{f049d}  Random"
                    fontSizeModifier: -1
                    enabled: Wallpapers.wallpapers.length > 1
                    onClicked: Wallpapers.applyRandom()
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        SectionLabel {
            leftPadding: 0
            text: "Library"
        }

        SettingsRow {
            label: "Folder"
            description: Wallpapers.tildePath(Wallpapers.folder) + " · " + (Wallpapers.scanning && Wallpapers.wallpapers.length === 0
                ? "looking for images..."
                : Wallpapers.wallpapers.length + (Wallpapers.wallpapers.length === 1 ? " image" : " images"))

            Button {
                buttonText: "Browse..."
                fontSizeModifier: -1
                onClicked: folderPicker.running = true
            }
        }

        SettingsRow {
            label: "Include subfolders"
            description: "Also show images in folders inside it."

            Button {
                toggleButton: true
                checked: Settings.wallpaperSubfolders
                buttonText: checked ? "On" : "Off"
                fontSizeModifier: -1
                onClicked: Settings.wallpaperSubfolders = !Settings.wallpaperSubfolders
            }
        }

        SettingsRow {
            label: "Order"

            RadioBtnGroup {
                onPrimaryBg: true
                fontSizeModifier: -1
                options: ["Name", "Newest first"]
                selectedIndex: Settings.wallpaperOrder === "newest" ? 1 : 0
                onSelectionChanged: idx => Settings.wallpaperOrder = idx === 1 ? "newest" : "name"
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        SectionLabel {
            leftPadding: 0
            text: "Display"
        }

        SettingsRow {
            label: "Backend"
            description: Wallpapers.installedBackends.length === 0
                ? "Neither awww nor swww is installed."
                : Wallpapers.installedBackends.length === 1
                    ? "awww and swww are supported. Only " + Wallpapers.installedBackends[0] + " is installed."
                    : "awww and swww are supported."

            Dropdown {
                model: root.backends
                currentIndex: root.backends.indexOf(Settings.wallpaperBackend)
                onActivated: idx => Settings.wallpaperBackend = root.backends[idx]
            }
        }

        SettingsRow {
            label: "Scaling"
            description: "Fill crops the image to cover the screen. Fit and Center leave bars in the fill color."

            RadioBtnGroup {
                onPrimaryBg: true
                fontSizeModifier: -1
                options: ["Fill", "Fit", "Center", "Stretch"]
                selectedIndex: Math.max(0, root.scalings.indexOf(Settings.wallpaperScaling))
                onSelectionChanged: idx => Settings.wallpaperScaling = root.scalings[idx]
            }
        }

        SettingsRow {
            label: "Fill color"
            description: "Around the image when it's fitted or centered."
            enabled: root.usesFillColor
            opacity: enabled ? 1 : 0.5

            Rectangle {
                implicitWidth: Looks.Decorations.decor.elementHeight
                implicitHeight: Looks.Decorations.decor.elementHeight
                radius: Looks.Decorations.decor.radius
                color: Settings.wallpaperFillColor
            }

            TextBox {
                Layout.preferredWidth: 96
                text: Settings.wallpaperFillColor
                onTextEdited: if (/^#[0-9a-fA-F]{6}$/.test(text)) Settings.wallpaperFillColor = text.toLowerCase()
            }
        }

        SettingsRow {
            label: "Monitors"
            description: "Where a new wallpaper goes."

            RadioBtnGroup {
                onPrimaryBg: true
                fontSizeModifier: -1
                options: ["All", "Focused"]
                selectedIndex: Settings.wallpaperMonitors === "focused" ? 1 : 0
                onSelectionChanged: idx => Settings.wallpaperMonitors = idx === 1 ? "focused" : "all"
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        SectionLabel {
            leftPadding: 0
            text: "Transition"
        }

        SettingsRow {
            label: "Effect"
            description: root.transitions[root.transitionIndex]?.hint ?? ""

            Dropdown {
                model: root.transitions.map(t => t.name)
                currentIndex: root.transitionIndex
                onActivated: idx => Settings.wallpaperTransition = root.transitions[idx].id
            }
        }

        SettingsRow {
            label: "Duration: " + Settings.wallpaperTransitionDuration.toFixed(1) + " s"

            Slider {
                Layout.preferredWidth: 160
                from: 0.2
                to: 5
                stepSize: 0.1
                value: Settings.wallpaperTransitionDuration
                tooltipContent: value.toFixed(1) + " s"
                onMoved: Settings.wallpaperTransitionDuration = Math.round(value * 10) / 10
            }
        }

        SettingsRow {
            label: "Frame rate"

            RadioBtnGroup {
                onPrimaryBg: true
                fontSizeModifier: -1
                options: ["30", "60", "120"]
                selectedIndex: Math.max(0, [30, 60, 120].indexOf(Settings.wallpaperTransitionFps))
                onSelectionChanged: idx => Settings.wallpaperTransitionFps = [30, 60, 120][idx]
            }
        }

        SettingsRow {
            label: "Angle: " + Settings.wallpaperTransitionAngle + "°"
            description: "For Wipe and Wave. 0° sweeps right to left, 90° top to bottom."
            enabled: root.usesAngle
            opacity: enabled ? 1 : 0.5

            Slider {
                Layout.preferredWidth: 160
                from: 0
                to: 360
                stepSize: 15
                value: Settings.wallpaperTransitionAngle
                tooltipContent: Math.round(value) + "°"
                onMoved: Settings.wallpaperTransitionAngle = Math.round(value)
            }
        }
    }

    Process {
        id: folderPicker
        command: ["zenity", "--file-selection", "--directory", "--title=Choose the wallpaper folder",
            "--filename=" + Wallpapers.folder + "/"]

        stdout: StdioCollector {
            onStreamFinished: {
                const path = this.text.trim()
                if (path !== "") Settings.wallpaperFolder = Wallpapers.tildePath(path)
            }
        }
    }

    Item { Layout.fillHeight: true }
}

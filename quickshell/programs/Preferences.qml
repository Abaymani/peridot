import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import qs
import qs.common.looks as Looks
import qs.widgets
import qs.services as Services
import qs.programs.preferences

Scope {
    id: preferencesRoot

    Window {
        id: window
        visible: GlobalStates.isSettingsOpen
        width: 880
        height: 600
        minimumWidth: 640
        minimumHeight: 420
        maximumWidth: 1000
        // title is matched by the "peridot-settings-rule" window rule in
        // hypr/windowrules.lua (float + size) - keep the two in sync.
        title: "Peridot Settings"
        color: "transparent"

        property var sections: [
            {
                name: "Shell",
                items: [
                    {name: "Appearance", icon: "\u{f174a}", page: appearancePageComponent},
                    {name: "Power", icon: "\u{f1905}", page: powerPageComponent},
                    {name: "Audio", icon: "\u{f057e}", page: audioPageComponent}
                ]
            },
            {
                name: "Hyprland",
                items: [
                    {name: "Decorations", icon: "", page: hyprlandDecorationsPageComponent},
                    {name: "Input", icon: "", page: hyprlandInputPageComponent}
                ]
            }
        ]
        property var selectedCategory: sections[0].items[0]

        Component { id: appearancePageComponent; AppearancePage {} }
        Component { id: powerPageComponent; PowerPage {} }
        Component { id: hyprlandDecorationsPageComponent; HyprlandDecorationsPage {} }
        Component { id: hyprlandInputPageComponent; HyprlandInputPage {} }
        Component { id: audioPageComponent; AudioPage {} }

        // Forces the active page to be recreated from scratch, giving every
        // control inside it a fresh binding to Settings. Needed because
        // controls like Slider/ComboBox/RadioBtnGroup write to their own
        // bound property internally (e.g. on drag), which severs a plain
        // declarative binding - revert() alone wouldn't visually update them.
        function refreshActivePage() {
            pageLoader.active = false;
            pageLoader.active = true;
        }

        Rectangle {
            anchors.fill: parent
            color: Looks.Colors.md3.background
            gradient: Settings.gradientBgEnabled
                ? Looks.Gradients.library[Settings.activebackgroundGradient].createObject()
                : null

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // --- Sidebar ---
                ColumnLayout {
                    id: sidebar
                    Layout.preferredWidth: 200
                    Layout.minimumWidth: 200
                    Layout.maximumWidth: 200
                    Layout.fillHeight: true
                    Layout.margins: 12
                    spacing: 4

                    Looks.ClearText {
                        text: "Settings"
                        font.pixelSize: Looks.Fonts.size + 8
                        color: Settings.textColorOnContainer
                        Layout.bottomMargin: 8
                        Layout.leftMargin: 8
                    }

                    Repeater {
                        model: window.sections

                        delegate: ColumnLayout {
                            id: sectionDelegate
                            required property var modelData

                            Layout.fillWidth: true
                            spacing: 4

                            Looks.ClearText {
                                Layout.topMargin: 8
                                Layout.leftMargin: 8
                                text: sectionDelegate.modelData.name.toUpperCase()
                                font.pixelSize: Looks.Fonts.size - 1
                                opacity: 0.5
                                color: Settings.textColorOnContainer
                            }

                            Repeater {
                                model: sectionDelegate.modelData.items

                                delegate: Rectangle {
                                    id: categoryDelegate
                                    required property var modelData
                                    readonly property bool isSelected: window.selectedCategory === categoryDelegate.modelData

                                    Layout.fillWidth: true
                                    implicitHeight: Looks.Decorations.decor.elementHeight + 10
                                    radius: Looks.Decorations.decor.radius
                                    color: isSelected ? Looks.Colors.md3.secondary_container : "transparent"
                                    gradient: (isSelected && Settings.gradientBgEnabled)
                                        ? Looks.Gradients.library[Settings.activeGradient].createObject()
                                        : null

                                    Item {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10

                                        // Icon gets a hard, fixed-size box (not a Layout
                                        // preference, which different glyphs' own implicit
                                        // widths can override) so the label below always
                                        // starts at the same x regardless of glyph width.
                                        Looks.ClearText {
                                            id: iconText
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 24
                                            horizontalAlignment: Text.AlignHCenter
                                            text: categoryDelegate.modelData.icon
                                            color: Settings.textColorOnContainer
                                        }
                                        Looks.ClearText {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 34
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: categoryDelegate.modelData.name
                                            color: Settings.textColorOnContainer
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: window.selectedCategory = categoryDelegate.modelData
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

                Looks.Separator { verticalPadding: 1.0 }

                // --- Content ---
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 20
                        spacing: 8

                        Flickable {
                            id: contentFlickable
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            contentWidth: pageLoader.width
                            contentHeight: pageLoader.height

                            Loader {
                                id: pageLoader
                                width: contentFlickable.width
                                sourceComponent: window.selectedCategory.page
                            }

                            ScrollBar.vertical: ScrollBar {
                                parent: contentFlickable.parent
                                Layout.fillHeight: true
                                visible: size < 1.0
                                policy: ScrollBar.AlwaysOn
                                active: true
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 12
                        spacing: 8

                        Item { Layout.fillWidth: true }

                        Button {
                            buttonText: "Revert"
                            fontSizeModifier: -1
                            onClicked: {
                                Settings.revert();
                                Services.HyprlandDecorations.revert();
                                Services.HyprlandInput.revert();
                                pageRefreshTimer.restart();
                            }
                        }

                        Button {
                            buttonText: "Save"
                            fontSizeModifier: -1
                            onPrimaryBg: true
                            onClicked: {
                                Settings.save();
                                Services.HyprlandDecorations.save();
                                Services.HyprlandInput.save();
                            }
                        }
                    }
                }
            }
        }

        Timer {
            id: pageRefreshTimer
            interval: 50
            onTriggered: window.refreshActivePage()
        }
    }
}

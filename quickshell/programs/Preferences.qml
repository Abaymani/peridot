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
        // Closing the window through any means other than this binding (WM
        // close, a keybind, etc.) writes `visible` directly, which severs
        // the binding above - without this, isSettingsOpen would stay stuck
        // on true and the next toggle press would silently do nothing.
        // Closing, by any means, also discards unsaved changes.
        onVisibleChanged: {
            GlobalStates.isSettingsOpen = visible;
            if (!visible) revertAll();
        }
        width: 880
        height: 600
        minimumWidth: 640
        minimumHeight: 420
        maximumWidth: 1000
        // title is matched by the "peridot-settings-rule" window rule in
        // hypr/windowrules.lua (float + size) - keep the two in sync.
        title: "Peridot Settings"
        color: "transparent"

        // Each page names the SettingsStore it edits; Save, Revert, the unsaved
        // count and discard-on-close go through these. `keys`: for pages sharing
        // a store, the settings that page edits (drives its unsaved dot).
        property var sections: [
            {
                name: "Shell",
                items: [
                    {name: "Profile", icon: "\u{f0004}", page: profilePageComponent,
                        store: Settings.store, keys: ["profilePicture"]},
                    {name: "Appearance", icon: "\u{f174a}", page: appearancePageComponent,
                        store: Settings.store, keys: ["gradientBgEnabled", "isDarkMode", "activeGradient", "activeSecondaryGradient",
                            "activebackgroundGradient", "backdropFloorOpacity", "darkControlFill", "scrollSpeedMultiplier",
                            "matugenSourceColorIndex"]},
                    {name: "Power", icon: "\u{f1905}", page: powerPageComponent,
                        store: Settings.store, keys: ["userOverridePowerProfile", "onBatteryPowerProfile", "onChargerPowerProfile"]},
                    {name: "Audio", icon: "\u{f057e}", page: audioPageComponent,
                        store: Settings.store, keys: ["audioIncrement"]}
                ]
            },
            {
                name: "Hyprland",
                items: [
                    {name: "Decorations", icon: "\u{f53f}", page: hyprlandDecorationsPageComponent,
                        store: Services.HyprlandDecorations.store},
                    {name: "Input", icon: "\u{f11c}", page: hyprlandInputPageComponent,
                        store: Services.HyprlandInput.store}
                ]
            }
        ]
        property var selectedCategory: sections[0].items[0]

        readonly property var stores: {
            const result = [];
            for (const section of sections)
                for (const item of section.items)
                    if (!result.includes(item.store)) result.push(item.store);
            return result;
        }
        readonly property int unsavedCount: stores.reduce((count, store) => count + store.unsavedKeys.length, 0)

        function saveAll(): void {
            for (const store of stores)
                if (store.unsavedKeys.length > 0) store.save();
        }

        function revertAll(): void {
            for (const store of stores)
                store.revert();
            refreshActivePage();
        }

        Component { id: profilePageComponent; ProfilePage {} }
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
                ? Looks.Gradients.library[Settings.activeSecondaryGradient].createObject()
                : null

            BackdropFloor {}

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

                                delegate: Item {
                                    id: categoryDelegate
                                    required property var modelData
                                    readonly property bool isSelected: window.selectedCategory.page === categoryDelegate.modelData.page
                                    readonly property bool hasUnsaved: {
                                        const unsaved = categoryDelegate.modelData.store.unsavedKeys;
                                        const keys = categoryDelegate.modelData.keys;
                                        return keys ? unsaved.some(key => keys.includes(key)) : unsaved.length > 0;
                                    }

                                    Layout.fillWidth: true
                                    implicitHeight: Looks.Decorations.decor.elementHeight + 10

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: Looks.Decorations.decor.radius
                                        color: Looks.Colors.md3.secondary_container
                                        gradient: Settings.gradientBgEnabled
                                            ? Looks.Gradients.library[Settings.activeGradient].createObject()
                                            : null
                                        opacity: categoryDelegate.isSelected ? 1 : 0

                                        Behavior on opacity {
                                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                                        }
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: Looks.Decorations.decor.radius
                                        color: Settings.textColorOnContainer
                                        opacity: hoverArea.containsMouse ? 0.08 : 0

                                        Behavior on opacity {
                                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                                        }
                                    }

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

                                        Rectangle {
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 6
                                            height: 6
                                            radius: 3
                                            color: Looks.Colors.md3.tertiary
                                            visible: categoryDelegate.hasUnsaved
                                        }
                                    }

                                    MouseArea {
                                        id: hoverArea
                                        anchors.fill: parent
                                        hoverEnabled: true
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

                        Item {
                            id: flickableContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Flickable {
                                id: contentFlickable
                                anchors.fill: parent
                                clip: true
                                contentWidth: pageLoader.width
                                contentHeight: pageLoader.height

                                Loader {
                                    id: pageLoader
                                    width: contentFlickable.width
                                    sourceComponent: window.selectedCategory.page
                                }

                                ScrollBar.vertical: ScrollBar {
                                    parent: flickableContainer.parent
                                    Layout.fillHeight: true
                                    visible: size < 1.0
                                    policy: ScrollBar.AlwaysOn
                                    active: true
                                }
                            }

                            FastScrollArea {
                                anchors.fill: parent
                                target: contentFlickable
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 12
                        spacing: 8

                        Looks.ClearText {
                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                            text: window.unsavedCount === 0
                                ? "All changes saved"
                                : window.unsavedCount + " unsaved change" + (window.unsavedCount === 1 ? "" : "s")
                            font.pixelSize: Looks.Fonts.size - 1
                            opacity: 0.65
                            color: Settings.textColorOnContainer
                        }

                        Button {
                            buttonText: "Revert"
                            fontSizeModifier: -1
                            enabled: window.unsavedCount > 0
                            onClicked: window.revertAll()
                        }

                        Button {
                            buttonText: "Save"
                            fontSizeModifier: -1
                            onPrimaryBg: true
                            enabled: window.unsavedCount > 0
                            onClicked: window.saveAll()
                        }
                    }
                }
            }
        }
    }
}

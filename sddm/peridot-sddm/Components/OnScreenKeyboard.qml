import QtQuick
import "KeyboardLayouts.js" as KeyboardLayouts

// The login screen's on-screen keyboard: the shell's layouts and look
// (KeyboardLayouts.js is linked in from peridot's quickshell config), typing
// straight into `target` - the password field - rather than sending key
// codes, so the system keyboard layout doesn't matter here. Dead keys type
// their accent as-is; keys that mean nothing in a password field are dimmed.
Item {
    id: root

    property var target: null
    property string layoutId: ""
    property color colSurface: "#221e24"
    property color colSecondary: "#d0c1da"
    property color colPrimary: "#dabaf9"
    property color colText: "#ccc4cf"
    property bool gradientEnabled: true
    property int radius: 12
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 12

    signal closeRequested()

    readonly property var layouts: KeyboardLayouts.layouts
    readonly property var layout: KeyboardLayouts.byId(layoutId)
    // 0: off, 1: the next key, 2: caps lock (letters only, like the real one).
    property int shiftState: 0
    property bool altGr: false
    property double lastShiftTap: 0

    readonly property int gap: 5
    readonly property int keyHeight: 44
    // The width of a 1-unit key.
    readonly property real unit: (width - 20 - 14 * gap) / 15

    implicitWidth: 1000
    implicitHeight: column.implicitHeight + 20

    function isLetter(key) {
        return key.kind === "char" && key.label.toUpperCase() !== key.label.toLowerCase()
    }

    function shifted(key) {
        return shiftState === 1 || (shiftState === 2 && isLetter(key))
    }

    // What a character key types right now.
    function charFor(key) {
        if (altGr && key.altgr !== undefined) return key.altgr
        if (shifted(key)) return key.shift !== undefined ? key.shift : key.label.toUpperCase()
        return key.label
    }

    // Whether `key` does anything in a password field: characters, the shift
    // keys, AltGr, Esc (clears), Backspace, Enter, Space and left/right.
    function usable(key) {
        return ["char", "shift", "caps", "altgr"].indexOf(key.kind) >= 0
            || [1, 14, 28, 57, 105, 106].indexOf(key.code) >= 0
    }

    function tap(key) {
        if (!target) return
        if (key.kind === "shift") {
            var now = Date.now()
            // A second tap within 300 ms turns on caps lock.
            shiftState = shiftState === 1 && now - lastShiftTap < 300 ? 2 : shiftState === 0 ? 1 : 0
            lastShiftTap = now
        } else if (key.kind === "caps") {
            shiftState = shiftState === 2 ? 0 : 2
        } else if (key.kind === "altgr") {
            altGr = !altGr
        } else if (key.kind === "char" || key.code === 57) {
            target.insert(target.cursorPosition, key.code === 57 ? " " : charFor(key))
            altGr = false
            if (shiftState === 1) shiftState = 0
        } else if (key.code === 14) {
            if (target.cursorPosition > 0) target.remove(target.cursorPosition - 1, target.cursorPosition)
        } else if (key.code === 28) {
            target.accepted()
        } else if (key.code === 1) {
            target.text = ""
        } else if (key.code === 105) {
            target.cursorPosition = Math.max(0, target.cursorPosition - 1)
        } else if (key.code === 106) {
            target.cursorPosition = Math.min(target.length, target.cursorPosition + 1)
        }
        target.forceActiveFocus()
    }

    // The theme's toolbar look: surface colour, or its secondary-to-primary
    // gradient.
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.colSurface
        gradient: root.gradientEnabled ? cardGradient : null

        Gradient {
            id: cardGradient
            orientation: Gradient.Horizontal
            GradientStop { position: 0.5; color: Qt.rgba(root.colSecondary.r, root.colSecondary.g, root.colSecondary.b, 0.3) }
            GradientStop { position: 1.0; color: Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.5) }
        }
    }

    Column {
        id: column
        x: 10
        y: 10
        width: root.width - 20
        spacing: root.gap

        Item {
            width: parent.width
            height: 28

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "\u{f030c}  Keyboard"
                color: root.colText
                opacity: 0.7
                font.family: root.fontFamily
                font.pixelSize: root.fontSize - 1
                renderType: Text.NativeRendering
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Repeater {
                    // Layout switch, then close.
                    model: [root.layout.short, "\u{f0156}"]

                    delegate: Rectangle {
                        id: headerButton
                        required property string modelData
                        required property int index
                        width: headerLabel.implicitWidth + 28
                        height: 24
                        radius: height / 2
                        color: headerMouse.containsMouse
                            ? Qt.rgba(root.colSecondary.r, root.colSecondary.g, root.colSecondary.b, 0.55)
                            : Qt.rgba(root.colSecondary.r, root.colSecondary.g, root.colSecondary.b, 0.35)

                        Text {
                            id: headerLabel
                            anchors.centerIn: parent
                            text: headerButton.modelData
                            color: root.colText
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 1
                            renderType: Text.NativeRendering
                        }

                        MouseArea {
                            id: headerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (headerButton.index === 0) {
                                    var at = root.layouts.indexOf(root.layout)
                                    root.layoutId = root.layouts[(at + 1) % root.layouts.length].id
                                    root.altGr = false
                                } else {
                                    root.closeRequested()
                                }
                            }
                        }
                    }
                }
            }
        }

        Repeater {
            model: root.layout.rows

            delegate: Row {
                id: keyRow
                required property var modelData
                spacing: root.gap

                Repeater {
                    model: keyRow.modelData

                    delegate: OskKey {
                        required property var modelData
                        readonly property real units: modelData.width || 1
                        readonly property bool isChar: modelData.kind === "char"
                        readonly property bool showsAltGr: isChar && root.altGr && modelData.altgr !== undefined

                        key: modelData
                        width: root.unit * units + root.gap * (units - 1)
                        height: root.keyHeight
                        rowHeight: root.keyHeight
                        rowGap: root.gap
                        mainLabel: modelData.code === 57 ? root.layout.name
                            : isChar ? root.charFor(modelData)
                            : modelData.label
                        shiftLabel: isChar && modelData.shift !== undefined && !showsAltGr
                            ? (root.shifted(modelData) ? modelData.label : modelData.shift) : ""
                        altGrLabel: isChar && modelData.altgr !== undefined && !showsAltGr ? modelData.altgr : ""
                        latched: modelData.kind === "shift" ? root.shiftState > 0
                            : modelData.kind === "caps" ? root.shiftState === 2
                            : modelData.kind === "altgr" ? root.altGr
                            : false
                        usable: root.usable(modelData)
                        colSecondary: root.colSecondary
                        colPrimary: root.colPrimary
                        colText: root.colText
                        cornerRadius: root.radius + 4
                        fontFamily: root.fontFamily
                        fontSize: root.fontSize
                        onTapped: root.tap(modelData)
                    }
                }
            }
        }
    }
}

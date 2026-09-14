import QtQuick

// One key of the login screen's on-screen keyboard (see OnScreenKeyboard.qml)
// with peridot's key look: rounded, a quieter fill for special keys, and a
// character's Shift and AltGr forms small in the corners. Backspace and the
// arrows repeat while held.
Item {
    id: root

    required property var key
    property string mainLabel: key.label
    property string shiftLabel: ""
    property string altGrLabel: ""
    property bool latched: false
    // Keys that do nothing in a password field are dimmed.
    property bool usable: true
    // One key row's height and the gap between rows: a tall key (ISO Enter)
    // also covers the slot below it.
    property real rowHeight: height
    property real rowGap: 0

    property color colSecondary: "#d0c1da"
    property color colPrimary: "#dabaf9"
    property color colText: "#ccc4cf"
    property real cornerRadius: 16
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 12

    readonly property bool special: key.kind !== "char"
    readonly property bool repeats: key.code === 14 || key.code === 105 || key.code === 106

    signal tapped()

    visible: key.kind !== "gap"
    opacity: usable ? 1 : 0.35

    Rectangle {
        width: parent.width
        height: root.key.tall ? root.rowHeight * 2 + root.rowGap : parent.height
        radius: Math.min(root.cornerRadius, root.rowHeight / 2)
        scale: mouse.pressed ? 0.94 : 1
        color: root.latched
            ? Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.55)
            : Qt.rgba(root.colSecondary.r, root.colSecondary.g, root.colSecondary.b, root.special ? 0.22 : 0.4)
        border.width: root.latched ? 1 : 0
        border.color: Qt.rgba(1, 1, 1, 0.35)

        Behavior on scale {
            NumberAnimation { duration: 60 }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: root.colText
            opacity: mouse.pressed ? 0.18 : mouse.containsMouse ? 0.06 : 0
        }

        Text {
            anchors.centerIn: parent
            text: root.mainLabel
            color: root.colText
            font.family: root.fontFamily
            font.pixelSize: root.special ? root.fontSize - 1 : root.fontSize + 5
            renderType: Text.NativeRendering
        }

        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 9
            anchors.topMargin: 5
            visible: root.shiftLabel !== ""
            text: root.shiftLabel
            color: root.colText
            opacity: 0.55
            font.family: root.fontFamily
            font.pixelSize: root.fontSize - 2
            renderType: Text.NativeRendering
        }

        Text {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 9
            anchors.bottomMargin: 5
            visible: root.altGrLabel !== ""
            text: root.altGrLabel
            color: root.colText
            opacity: 0.55
            font.family: root.fontFamily
            font.pixelSize: root.fontSize - 2
            renderType: Text.NativeRendering
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            enabled: root.usable
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: {
                root.tapped()
                if (root.repeats) repeat.start()
            }
            onReleased: repeat.stop()
            onCanceled: repeat.stop()
        }

        Timer {
            id: repeat
            interval: 400
            repeat: true
            onTriggered: {
                interval = 50
                root.tapped()
            }
            onRunningChanged: if (!running) interval = 400
        }
    }
}

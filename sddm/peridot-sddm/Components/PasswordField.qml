import QtQuick
import QtQuick.Controls

TextField {
    id: root

    property color colText: "#cbc5ca"
    property color colPlaceholder: "#948f94"
    property color colAccent: "#bac9d1"
    property color colError: "#ffb4ab"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 15
    property bool failed: false

    function loginFailed() {
        failed = true
        text = ""
        shakeAnim.restart()
        failedTimer.restart()
    }

    Timer {
        id: failedTimer
        interval: 2000
        onTriggered: root.failed = false
    }

    implicitWidth: 280
    implicitHeight: 52
    padding: 16
    leftPadding: 44
    rightPadding: 44

    color: "transparent"
    horizontalAlignment: TextInput.AlignHCenter
    // QQC2's Basic style placeholderText doesn't render at all combined with center alignment, drawn manually below instead.
    // autoScroll assumes left-aligned scrolling text and otherwise fights center alignment too, pushing the real text out of 
    // the visible area.
    autoScroll: false
    cursorDelegate: Item {}
    echoMode: TextInput.Password
    inputMethodHints: Qt.ImhSensitiveData

    font {
        family: root.fontFamily
        pixelSize: root.fontSize
        hintingPreference: Font.PreferFullHinting
    }
    renderType: Text.NativeRendering

    background: Rectangle {
        color: "transparent"
        radius: height / 2
        border.width: 2
        border.color: root.failed ? root.colError : root.colAccent

        Behavior on border.color {
            ColorAnimation { duration: 200 }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.text.length === 0
        text: root.failed ? "Incorrect password" : "Enter password"
        color: root.colPlaceholder
        font: root.font
        renderType: Text.NativeRendering
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        x: (parent.width - width) / 2
        spacing: 8

        Behavior on x {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Repeater {
            model: root.text.length

            Rectangle {
                required property int index
                width: 9
                height: 9
                radius: width / 2
                color: root.failed ? root.colError : root.colText

                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }

    // Inline confirm icon instead of a separate button
    Text {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        font.family: root.fontFamily
        font.pixelSize: 18
        text: "\u{f0055}"
        color: root.failed ? root.colError : root.colAccent

        Behavior on color { ColorAnimation { duration: 200 } }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -10
            cursorShape: Qt.PointingHandCursor
            onClicked: root.accepted()
        }
    }

    // Shake animation on wrong password
    transform: Translate { id: shakeTranslate; x: 0 }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: shakeTranslate; property: "x"; to: -30; duration: 50 }
        NumberAnimation { target: shakeTranslate; property: "x"; to: 30; duration: 50 }
        NumberAnimation { target: shakeTranslate; property: "x"; to: -15; duration: 40 }
        NumberAnimation { target: shakeTranslate; property: "x"; to: 15; duration: 40 }
        NumberAnimation { target: shakeTranslate; property: "x"; to: 0; duration: 30 }
    }
}

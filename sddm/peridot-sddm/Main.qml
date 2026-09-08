import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import "Components"

Item {
    id: root
    width: Screen.width
    height: Screen.height

    // ---- Color properties (defaults, overridden by peridot's colors.json) ----
    property color colBackground: "#151218"
    property color colSurfaceContainer: "#221e24"
    property color colOnSurfaceVariant: "#ccc4cf"
    property color colPrimary: "#dabaf9"
    property color colOnPrimary: "#3e2459"
    property color colPrimaryContainer: "#553b71"
    property color colSecondary: "#d0c1da"
    property color colError: "#ffb4ab"
    property color colLayer0: "#151218"
    property color colSubtext: "#968e98"

    // ---- Config properties ----
    property string wallpaperPath: config.Background || "Backgrounds/pond_shed.png"
    property int blurRadius: parseInt(config.BlurRadius) || 36
    property bool blurEnabled: config.BlurEnabled !== "false"
    property real blurExtraZoom: parseFloat(config.BlurExtraZoom) || 1.1
    property real blurOverlayOpacity: parseFloat(config.BlurOverlayOpacity) || 0.22
    property string clockFontFamily: config.ClockFontFamily || "JetBrainsMono Nerd Font"
    property int clockFontSize: parseInt(config.ClockFontSize) || 64
    // 100 = Thin, matching hyprlock's "JetBrainsMono Nerd Font Thin".
    property int clockFontWeight: parseInt(config.ClockFontWeight) || 100
    property string fontFamily: config.FontFamily || "JetBrainsMono Nerd Font"
    property int fontSize: parseInt(config.FontSize) || 12
    // Matches peridot shell's decor.json radius (read live below) - used by
    // the suspend/power/reboot icon buttons only.
    property int decorRadius: 12
    // Matches peridot shell's Settings.gradientBgEnabled (read live below).
    property bool gradientBgEnabled: true

    // ---- State ----
    property int currentUserIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property string currentUserName: userModel.lastUser || getUserName(currentUserIndex)
    property int currentSessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

    // ---- Toolbar appear animation ----
    property real toolbarScale: 0.9
    property real toolbarOpacity: 0

    // ---- Virtual keyboard state ----
    property bool virtualKeyboardVisible: false
    property bool hasPhysicalKeyboard: true

    Behavior on toolbarScale {
        NumberAnimation {
            duration: 500
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.38, 1.21, 0.22, 1.00, 1, 1]
        }
    }
    Behavior on toolbarOpacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.34, 0.80, 0.34, 1.00, 1, 1]
        }
    }

    Component.onCompleted: {
        try { loadColors() } catch(e) { console.log("loadColors error:", e) }
        try { loadWallpaper() } catch(e) { console.log("loadWallpaper error:", e) }
        root.hasPhysicalKeyboard = detectPhysicalKeyboard()
        if (!root.hasPhysicalKeyboard) {
            root.virtualKeyboardVisible = true
        }
        // Set preferred keyboard layout based on detected language
        try {
            var preferredLang = (config.Language || Qt.locale().name).substring(0, 2).toLowerCase()
            if (keyboard.layouts && keyboard.layouts.length > 1) {
                for (var i = 0; i < keyboard.layouts.length; i++) {
                    if (keyboard.layouts[i].shortName.toLowerCase() === preferredLang) {
                        keyboard.currentLayout = i
                        break
                    }
                }
            }
        } catch(e) {}
        toolbarScale = 1
        toolbarOpacity = 1
        passwordField.forceActiveFocus()
    }

    // ---- Wallpaper loading ----
    // Reads the active wallpaper path from a plain-text file - by default the
    // same file waypaper's post_command rewrites on every wallpaper change
    // (see peridot's waypaper/config.ini), so this stays current automatically.
    // Overridable with WallpaperPathFile in theme.conf.
    function loadWallpaper() {
        var user = root.currentUserName || "armin"
        var home = "/home/" + user

        var plainPath = (config.WallpaperPathFile || "").trim()
        if (plainPath === "")
            plainPath = home + "/.config/peridot/settings/current_wallpaper.txt"

        var text = readFileContent(plainPath).trim()
        if (text !== "")
            root.wallpaperPath = text
    }

    function readFileContent(path) {
        try {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", path.startsWith("/") ? "file://" + path : Qt.resolvedUrl(path), false)
            xhr.send()
            if ((xhr.status === 200 || xhr.status === 0) && xhr.responseText.trim() !== "")
                return xhr.responseText
        } catch(e) {}
        return ""
    }

    function loadColors() {
        // Try peridot's live shell colors first (regenerated by matugen on
        // every wallpaper change - see MatugenService.qml).
        var user = root.currentUserName || "armin"
        var matugenPath = "/home/" + user + "/.config/quickshell/common/looks/colors.json"
        var text = readFileContent(matugenPath)

        // Fallback to theme-local colors file
        if (text === "") {
            var colorsFile = config.ColorsFile || "colors.json"
            text = readFileContent(colorsFile)
        }

        if (text !== "") parseColorsJson(text)

        // Corner radius from the same shell (decor.json lives alongside
        // colors.json) - only the suspend/power/reboot icon buttons use this;
        // the toolbar pills and password field are always full pills (see
        // Toolbar's own default cornerRadius and PasswordField's radius).
        var decorPath = "/home/" + user + "/.config/quickshell/common/looks/decor.json"
        var decorText = readFileContent(decorPath)
        if (decorText !== "") {
            try {
                var decorJson = JSON.parse(decorText)
                if (decorJson.decor && decorJson.decor.radius)
                    root.decorRadius = decorJson.decor.radius
            } catch(e) {}
        }

        // Whether the shell's panels/cards currently use a gradient fill or
        // a flat one (see peridot's Settings.qml/gradientBgEnabled).
        var settingsPath = "/home/" + user + "/.config/peridot/settings/settings.json"
        var settingsText = readFileContent(settingsPath)
        if (settingsText !== "") {
            try {
                var settingsJson = JSON.parse(settingsText)
                if (settingsJson.gradientBgEnabled !== undefined)
                    root.gradientBgEnabled = settingsJson.gradientBgEnabled
            } catch(e) {}
        }
    }

    function parseColorsJson(text) {
        var json = JSON.parse(text)
        // peridot's colors.json nests roles under "md3"; the theme's own
        // bundled fallback colors.json is flat - support both.
        var m3 = json.md3 || json
        var map = {
            "background": "colBackground",
            "surface_container": "colSurfaceContainer",
            "on_surface_variant": "colOnSurfaceVariant",
            "primary": "colPrimary",
            "on_primary": "colOnPrimary",
            "primary_container": "colPrimaryContainer",
            "secondary": "colSecondary",
            "error": "colError"
        }
        for (var key in map) {
            if (m3[key]) {
                try { root[map[key]] = m3[key] } catch(e) {}
            }
        }
        // Derived colors
        if (m3["surface"]) root.colLayer0 = m3["surface"]
        if (m3["outline"]) root.colSubtext = m3["outline"]
    }

    // ---- Helper: read Name= from a .desktop file ----
    function readDesktopName(filePath) {
        var text = readFileContent(filePath)
        if (text === "") return ""
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.indexOf("Name=") === 0) {
                return line.substring(5).trim()
            }
        }
        return ""
    }

    // ---- Helper: get session name from model ----
    function getSessionName(idx) {
        if (idx < 0 || idx >= sessionModel.count) return "Session"
        var modelIdx = sessionModel.index(idx, 0)
        // Try multiple roles to find the best human-readable name
        // SDDM SessionModel roles vary by version:
        //   Qt.DisplayRole, UserRole+1 (file), UserRole+2 (name), UserRole+3 (comment)
        var roles = [Qt.UserRole + 2, Qt.DisplayRole, Qt.UserRole + 1]
        var name = ""
        var filePath = ""
        for (var i = 0; i < roles.length; i++) {
            var val = sessionModel.data(modelIdx, roles[i])
            if (val && String(val) !== "") {
                var s = String(val)
                // Remember file path for .desktop fallback
                if (s.indexOf("/") !== -1 || s.indexOf(".desktop") !== -1)
                    filePath = s
                // Skip generic type names like "wayland-session", "x11-session"
                if (s.indexOf("-session") === -1) {
                    name = s
                    break
                }
                if (name === "") name = s
            }
        }
        // Fallback: read Name= from the .desktop file
        if ((!name || name.indexOf("-session") !== -1) && filePath !== "") {
            var desktopPath = filePath
            if (!desktopPath.startsWith("/")) {
                // Try standard session directories
                var dirs = ["/usr/share/wayland-sessions/", "/usr/share/xsessions/"]
                for (var d = 0; d < dirs.length; d++) {
                    var dn = readDesktopName(dirs[d] + desktopPath)
                    if (dn !== "") { name = dn; break }
                }
            } else {
                var dn = readDesktopName(desktopPath)
                if (dn !== "") name = dn
            }
        }
        if (!name || name === "") return "Session"
        // If still looks like a path, extract a clean name
        if (name.indexOf("/") !== -1) {
            var parts = name.split("/").filter(function(p) { return p.length > 0 })
            name = parts[parts.length - 1] || "Session"
            name = name.replace(/\.[^.]+$/, "")
        }
        return name
    }

    // ---- Helper: get user name from model ----
    function getUserName(idx) {
        if (idx < 0 || idx >= userModel.count) return "User"
        // Try RealName first (UserRole+2), then Name (UserRole+1), then DisplayRole
        var name = userModel.data(userModel.index(idx, 0), Qt.UserRole + 2)
        if (!name || name === "")
            name = userModel.data(userModel.index(idx, 0), Qt.UserRole + 1)
        if (!name || name === "")
            name = userModel.data(userModel.index(idx, 0), Qt.DisplayRole)
        return name || "User"
    }

    // ---- Helper: detect physical keyboard ----
    function detectPhysicalKeyboard() {
        var content = readFileContent("/proc/bus/input/devices")
        if (content === "") return true // assume present if can't read
        // Split into device blocks and look for a real keyboard:
        // Real keyboards have EV=120013 and a "leds" handler (Caps Lock/Num Lock LEDs)
        var blocks = content.split("\n\n")
        for (var i = 0; i < blocks.length; i++) {
            var block = blocks[i]
            if (/EV=120013/i.test(block) && /Handlers=.*\bleds\b/.test(block)) {
                return true
            }
        }
        return false
    }

    // ---- Helper: get keyboard layout short name ----
    function getKeyboardLayout() {
        try {
            var idx = keyboard.currentLayout
            if (keyboard.layouts && keyboard.layouts[idx])
                return keyboard.layouts[idx].shortName.toUpperCase()
        } catch(e) {}
        return ""
    }

    // ========== BACKGROUND ==========
    Rectangle {
        anchors.fill: parent
        color: root.colBackground
    }

    Item {
        anchors.fill: parent
        clip: true

        Image {
            id: wallpaper
            anchors.centerIn: parent
            width: parent.width * (root.blurEnabled ? root.blurExtraZoom : 1.0)
            height: parent.height * (root.blurEnabled ? root.blurExtraZoom : 1.0)
            source: root.wallpaperPath.startsWith("/") ? "file://" + root.wallpaperPath : Qt.resolvedUrl(root.wallpaperPath)
            fillMode: Image.PreserveAspectCrop
        }

        GaussianBlur {
            visible: root.blurEnabled
            anchors.fill: wallpaper
            source: wallpaper
            radius: root.blurRadius
            samples: Math.min(root.blurRadius * 2 + 1, 201)
        }

        // Dark overlay on blurred wallpaper
        Rectangle {
            anchors.fill: parent
            color: root.colLayer0
            opacity: root.blurOverlayOpacity
            visible: root.blurEnabled
        }

        // Faint noise dither - GaussianBlur quantizes smooth gradients into
        // visible bands (most obvious in flat sky-like areas); a subtle
        // per-pixel noise layer breaks that up without being visible itself.
        Image {
            anchors.fill: parent
            visible: root.blurEnabled
            source: "Backgrounds/noise.png"
            fillMode: Image.Tile
            opacity: 0.05
        }
    }

    // ========== CLICK TO FOCUS ==========
    MouseArea {
        anchors.fill: parent
        onClicked: passwordField.forceActiveFocus()
    }

    // ========== CLOCK (plain date + time, positioned like hyprlock's labels) ==========
    // hyprlock positions each label independently (valign=top, position=(0,Y))
    // rather than stacking them - per hyprlock's own posFromHVAlign formula,
    // a top-aligned widget's top edge sits at -Y pixels from the screen top,
    // regardless of the widget's own size. TIME uses Y=-100 (100px from top),
    // DATE uses Y=-200 (200px from top) - DATE further down puts it *below*
    // TIME, matching hyprlock's actual on-screen result.
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 100
        scale: root.toolbarScale
        opacity: root.toolbarOpacity
        text: Qt.formatTime(clockTimer.now, "hh:mm")
        color: root.colPrimary
        font.family: root.clockFontFamily
        font.pixelSize: root.clockFontSize
        font.weight: root.clockFontWeight
        renderType: Text.NativeRendering
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 200
        scale: root.toolbarScale
        opacity: root.toolbarOpacity
        // Matches hyprlock's `date +"%A, %d %B %Y"` exactly - %d is
        // zero-padded, hence "dd" not "d".
        text: Qt.formatDate(clockTimer.now, "dddd, dd MMMM yyyy")
        color: root.colPrimary
        font.family: root.clockFontFamily
        font.pixelSize: 25
        font.weight: root.clockFontWeight
        renderType: Text.NativeRendering
    }

    Timer {
        id: clockTimer
        property date now: new Date()
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: now = new Date()
    }

    // ========== PASSWORD (centered, transparent pill - see hyprlock's input-field) ==========
    PasswordField {
        id: passwordField
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -20
        colText: root.colPrimary
        colPlaceholder: root.colSubtext
        colAccent: root.colPrimary
        colError: root.colError
        fontFamily: root.fontFamily
        fontSize: root.fontSize
        scale: root.toolbarScale
        opacity: root.toolbarOpacity
        onAccepted: {
            sddm.login(root.currentUserName, passwordField.text, root.currentSessionIndex)
        }
    }

    // ========== LEFT TOOLBAR (user + keyboard layout) ==========
    Toolbar {
        id: leftIsland
        anchors {
            right: parent.horizontalCenter
            bottom: parent.bottom
            rightMargin: 5
            bottomMargin: 20
        }
        colBackground: root.colSurfaceContainer
        // No cornerRadius override - falls back to Toolbar's own default
        // (height / 2), a full pill matching the password field's shape.
        gradientEnabled: root.gradientBgEnabled
        gradientStartColor: Qt.rgba(root.colSecondary.r, root.colSecondary.g, root.colSecondary.b, 0.3)
        gradientEndColor: Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.5)
        scale: root.toolbarScale
        opacity: root.toolbarOpacity

        UserSelector {
            Layout.fillHeight: true
            Layout.leftMargin: 2
            Layout.rightMargin: 4
            currentIndex: root.currentUserIndex
            userCount: userModel.count
            userName: root.currentUserName
            colText: root.colOnSurfaceVariant
            fontFamily: root.fontFamily
            fontSize: root.fontSize
            onUserChanged: function(idx) {
                root.currentUserIndex = idx
                root.currentUserName = root.getUserName(idx)
            }
        }

        SessionSelector {
            Layout.fillHeight: true
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            currentIndex: root.currentSessionIndex
            sessionCount: sessionModel.count
            sessionName: root.getSessionName(root.currentSessionIndex)
            colText: root.colOnSurfaceVariant
            fontFamily: root.fontFamily
            fontSize: root.fontSize
            onSessionChanged: function(idx) {
                root.currentSessionIndex = idx
            }
        }

    }

    // ========== RIGHT TOOLBAR (session + power buttons) ==========
    Toolbar {
        id: rightIsland
        anchors {
            left: parent.horizontalCenter
            bottom: parent.bottom
            leftMargin: 5
            bottomMargin: 20
        }
        colBackground: root.colSurfaceContainer
        // No cornerRadius override - falls back to Toolbar's own default
        // (height / 2), a full pill matching the password field's shape.
        gradientEnabled: root.gradientBgEnabled
        gradientStartColor: Qt.rgba(root.colSecondary.r, root.colSecondary.g, root.colSecondary.b, 0.3)
        gradientEndColor: Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.5)
        scale: root.toolbarScale
        opacity: root.toolbarOpacity

        // Keyboard: click toggles virtual keyboard, scroll cycles layout
        Item {
            Layout.fillHeight: true
            implicitWidth: kbRow.implicitWidth + 16
            clip: false

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: root.virtualKeyboardVisible
                    ? (kbMouse.containsMouse ? Qt.lighter(root.colPrimaryContainer, 1.1) : root.colPrimaryContainer)
                    : (kbMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
                Behavior on color { ColorAnimation { duration: 80 } }
            }

            Item {
                id: kbRow
                anchors.centerIn: parent
                implicitWidth: 22
                implicitHeight: 22
                clip: false

                Text {
                    anchors.centerIn: parent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    text: "\u{f030c}"
                    color: root.colOnSurfaceVariant
                    renderType: Text.NativeRendering
                }

                Rectangle {
                    id: kbBadge
                    property string lang: root.getKeyboardLayout()
                    visible: true
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: -10
                    anchors.topMargin: -8
                    width: Math.max(kbBadgeText.implicitWidth + 6, height)
                    height: 15
                    radius: 7
                    color: root.colPrimary
                    z: 10

                    Text {
                        id: kbBadgeText
                        anchors.centerIn: parent
                        text: kbBadge.lang !== "" ? kbBadge.lang : "KB"
                        color: root.colOnPrimary
                        font.family: root.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                        renderType: Text.NativeRendering
                    }
                }
            }

            MouseArea {
                id: kbMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton) {
                        keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
                    } else {
                        root.virtualKeyboardVisible = !root.virtualKeyboardVisible
                        passwordField.forceActiveFocus()
                    }
                }
                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0) {
                        keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
                    } else if (wheel.angleDelta.y < 0) {
                        keyboard.currentLayout = (keyboard.currentLayout - 1 + keyboard.layouts.length) % keyboard.layouts.length
                    }
                }
            }

            scale: kbMouse.pressed ? 0.92 : 1.0
            Behavior on scale { NumberAnimation { duration: 80 } }
        }

        ToolbarButton {
            iconText: "\u{f0594}"
            iconColor: root.colOnSurfaceVariant
            cornerRadius: root.decorRadius
            onClicked: sddm.suspend()
        }

        ToolbarButton {
            iconText: "\u{f0425}"
            iconColor: root.colOnSurfaceVariant
            cornerRadius: root.decorRadius
            onClicked: sddm.powerOff()
        }

        ToolbarButton {
            iconText: "\u{f0709}"
            iconColor: root.colOnSurfaceVariant
            cornerRadius: root.decorRadius
            onClicked: sddm.reboot()
        }
    }

    // ========== SDDM CONNECTIONS ==========
    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.loginFailed()
        }
        function onLoginSucceeded() {}
    }

    // ========== KEYBOARD SHORTCUTS ==========
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            passwordField.text = ""
        }
        passwordField.forceActiveFocus()
    }

    // ========== VIRTUAL KEYBOARD ==========
    Loader {
        id: virtualKeyboardLoader
        source: "Components/VirtualKeyboard.qml"
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.5
        y: parent.height

        onItemChanged: {
            if (item) {
                item.activated = Qt.binding(function() { return root.virtualKeyboardVisible })
                // Sync back: if user closes via Qt's built-in hide button
                item.activeChanged.connect(function() {
                    if (!item.active && root.virtualKeyboardVisible) {
                        root.virtualKeyboardVisible = false
                    }
                })
            }
        }

        state: root.virtualKeyboardVisible ? "visible" : "hidden"
        states: [
            State {
                name: "hidden"
                PropertyChanges { target: virtualKeyboardLoader; y: root.height }
            },
            State {
                name: "visible"
                PropertyChanges {
                    target: virtualKeyboardLoader
                    y: root.height - virtualKeyboardLoader.height
                }
            }
        ]
        transitions: Transition {
            NumberAnimation {
                property: "y"
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }
}

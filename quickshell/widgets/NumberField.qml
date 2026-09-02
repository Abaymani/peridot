import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.common.looks as Looks
import qs.common.functions
import qs

// Pill-shaped numeric input with two integrated step buttons, styled to
// match the plain TextField pattern (e.g. the keyboard layout field). Meant
// as a swap-in replacement for Slider in settings rows: same from/to/
// stepSize/value API, plus decimals (0 = integer field). Validates
// keystrokes live (IntValidator/DoubleValidator, bounded to from/to) rather
// than only checking on commit, and re-clamps/re-formats on every commit.
Rectangle {
    id: root

    property real from: 0
    property real to: 100
    property real stepSize: 1
    property int decimals: 0
    property real value: from

    signal moved()

    implicitWidth: 60
    implicitHeight: Looks.Decorations.decor.elementHeight
    radius: Looks.Decorations.decor.radius
    color: Settings.gradientBgEnabled
        ? ColorUtils.setAlphaColor(Looks.Colors.md3.secondary, 0.5)
        : Looks.Colors.md3.secondary_container
    border.width: 1
    border.color: input.activeFocus ? Looks.Colors.md3.primary : "#00000000"

    function clamp(v: real): real {
        return Math.min(root.to, Math.max(root.from, v));
    }

    // Applies a new value (clamping to range) and always resyncs the
    // displayed text - including when the clamped value equals the current
    // one, so invalid/uncommitted typed text (e.g. "abc", or "999" clamped
    // back down) snaps back to the real value instead of being left showing
    // something that was never actually applied.
    function setValue(v: real): void {
        const clamped = clamp(v);
        const changed = clamped !== root.value;
        root.value = clamped;
        input.text = root.value.toFixed(root.decimals);
        if (changed)
            root.moved();
    }

    function increment(): void {
        setValue(root.value + root.stepSize);
    }

    function decrement(): void {
        setValue(root.value - root.stepSize);
    }

    IntValidator {
        id: intValidator
        bottom: root.from
        top: root.to
    }

    DoubleValidator {
        id: doubleValidator
        bottom: root.from
        top: root.to
        decimals: root.decimals
        notation: DoubleValidator.StandardNotation
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        TextField {
            id: input
            Layout.fillWidth: true
            Layout.fillHeight: true
            leftPadding: 10
            rightPadding: 10
            verticalAlignment: Text.AlignVCenter
            color: Settings.textColorOnContainer
            font.family: Looks.Fonts.family
            font.pixelSize: Looks.Fonts.size
            selectByMouse: true

            background: Item {}

            text: root.value.toFixed(root.decimals)
            validator: root.decimals > 0 ? doubleValidator : intValidator

            onEditingFinished: {
                const parsed = parseFloat(text);
                root.setValue(isNaN(parsed) ? root.value : parsed);
                focus = false;
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 20
            Layout.fillHeight: true
            Layout.rightMargin: 4
            spacing: 1

            Looks.ClearText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: ""
                font.pixelSize: Looks.Fonts.size
                opacity: root.value >= root.to ? 0.3 : 1.0
                color: Settings.textColorOnContainer

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.increment()
                }
            }

            Looks.ClearText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: ""
                font.pixelSize: Looks.Fonts.size
                opacity: root.value <= root.from ? 0.3 : 1.0
                color: Settings.textColorOnContainer

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.decrement()
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import qs.common.looks as Looks
import qs.common.functions
import qs

// Themed drop-in replacement for QtQuick.Controls' ComboBox - same API
// (model / currentIndex / onActivated), styled to match Button.qml's
// coloring so it reads as the same family of control as everything else
// on a settings page.
ComboBox {
    id: root

    implicitWidth: 220
    implicitHeight: Looks.Decorations.decor.elementHeight

    background: Rectangle {
        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight
        radius: Looks.Decorations.decor.radius
        color: Settings.gradientBgEnabled
            ? ColorUtils.setAlphaColor(Looks.Colors.md3.secondary, 0.5)
            : Looks.Colors.md3.secondary_container
    }

    contentItem: Looks.ClearText {
        text: root.displayText
        leftPadding: 10
        rightPadding: 24
        verticalAlignment: Text.AlignVCenter
        color: Settings.textColorOnContainer
        elide: Text.ElideRight
    }

    indicator: Looks.ClearText {
        x: root.width - width - 10
        y: root.topPadding + (root.availableHeight - height) / 2
        text: "▾"
        color: Settings.textColorOnContainer
        font.pixelSize: Looks.Fonts.size +4
    }

    popup: Popup {
        y: root.height + 4
        width: root.width
        implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
        padding: 4

        contentItem: ListView {
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            clip: true
        }

        background: Rectangle {
            color: Looks.Colors.md3.surface_container
            radius: Looks.Decorations.decor.radius
            border.width: 1
            border.color: Looks.Colors.md3.outline_variant
        }
    }

    delegate: ItemDelegate {
        id: delegateItem
        required property var modelData
        required property int index
        width: ListView.view.width

        highlighted: root.highlightedIndex === delegateItem.index

        contentItem: Looks.ClearText {
            text: delegateItem.modelData
            leftPadding: 10
            verticalAlignment: Text.AlignVCenter
            color: Settings.textColorOnContainer
        }

        background: Rectangle {
            color: delegateItem.highlighted ? Looks.Colors.md3.secondary_container : "transparent"
            radius: Looks.Decorations.decor.radius
        }
    }
}

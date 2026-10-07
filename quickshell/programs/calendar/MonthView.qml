import QtQuick
import qs
import qs.services
import qs.common.looks as Looks
import qs.common.functions
import "../../common/CalendarDates.js" as Dates

// A month, Monday first: week numbers down the left, then a cell per day
// with a dot per calendar that has events that day.
Item {
  id: root

  property date month: Dates.firstOfMonth(new Date())
  // The day whose popup is open, if any.
  property string selectedKey: ""

  signal dayClicked(date day, Item cell)

  readonly property int weekColumn: 26
  readonly property int cellWidth: 44
  readonly property int cellHeight: 40
  readonly property int headerHeight: 20
  readonly property var weeks: Dates.monthWeeks(month)
  readonly property string todayKey: Dates.key(Time.time)

  implicitWidth: weekColumn + 7 * cellWidth
  implicitHeight: headerHeight + weeks.length * cellHeight

  // Mo Tu ... in the locale's language, after the week column.
  Repeater {
    model: 8

    delegate: Looks.ClearText {
      required property int index
      x: index === 0 ? 0 : root.weekColumn + (index - 1) * root.cellWidth
      width: index === 0 ? root.weekColumn : root.cellWidth
      horizontalAlignment: Text.AlignHCenter
      text: index === 0 ? "Wk" : Qt.locale().dayName(index % 7, Locale.ShortFormat).slice(0, 2)
      font.pixelSize: Looks.Fonts.size - 2
      font.weight: Font.Bold
      font.letterSpacing: 1
      font.capitalization: Font.AllUppercase
      opacity: 0.55
      color: Settings.textColorOnContainer
    }
  }

  Repeater {
    model: root.weeks

    delegate: Looks.ClearText {
      required property var modelData
      required property int index
      y: root.headerHeight + index * root.cellHeight
      width: root.weekColumn
      height: root.cellHeight
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      text: modelData.number
      font.pixelSize: Looks.Fonts.size - 2
      opacity: 0.55
      color: Settings.textColorOnContainer
    }
  }

  Repeater {
    model: root.weeks.length * 7

    delegate: Item {
      id: cell
      required property int index
      readonly property date day: Dates.addDays(root.weeks[Math.floor(index / 7)].start, index % 7)
      readonly property string key: Dates.key(day)
      readonly property bool inMonth: day.getMonth() === root.month.getMonth()
      readonly property bool isToday: key === root.todayKey

      x: root.weekColumn + (index % 7) * root.cellWidth
      y: root.headerHeight + Math.floor(index / 7) * root.cellHeight
      width: root.cellWidth
      height: root.cellHeight

      // Selected: the launcher's selected-row look. Hover: Button's tint.
      Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Looks.Decorations.decor.radius - 2
        visible: cell.key === root.selectedKey
        color: Looks.Colors.md3.surface_container
        gradient: Settings.gradientBgEnabled
          ? Looks.Gradients.library[Settings.activeGradient].createObject()
          : null
        border.width: Settings.gradientBgEnabled ? 1 : 0
        border.color: ColorUtils.setAlphaColor(Looks.Colors.palette.neutral100, 0.25)
      }

      Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Looks.Decorations.decor.radius - 2
        color: Settings.textColorOnContainer
        opacity: cellArea.containsMouse && cell.key !== root.selectedKey ? 0.08 : 0

        Behavior on opacity {
          NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }
      }

      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 4
        width: 26
        height: 26
        radius: 13
        color: cell.isToday ? Looks.Colors.md3.primary : "transparent"

        Looks.ClearText {
          anchors.centerIn: parent
          text: cell.day.getDate()
          font.weight: cell.isToday ? Font.Bold : Looks.Fonts.weight
          color: cell.isToday ? Looks.Colors.md3.on_primary : Settings.textColorOnContainer
          opacity: cell.inMonth || cell.isToday ? 1 : 0.35
        }
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 32
        spacing: 3
        opacity: cell.inMonth ? 1 : 0.4

        Repeater {
          model: CalendarService.colorsOn(cell.day).slice(0, 3)

          delegate: Rectangle {
            required property string modelData
            width: 5
            height: 5
            radius: 2.5
            color: CalendarStyle.accent(modelData)
          }
        }
      }

      MouseArea {
        id: cellArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.dayClicked(cell.day, cell)
      }
    }
  }
}

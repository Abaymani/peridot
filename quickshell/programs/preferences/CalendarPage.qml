import QtQuick
import QtQuick.Layouts
import qs.common.looks as Looks
import qs.services
import qs.widgets
import qs.programs.calendar
import qs

ColumnLayout {
    id: root
    width: parent.width
    spacing: 24

    // Calendars are replaced whole, so the store sees the change.
    function update(index: int, changes: var): void {
        const list = CalendarService.calendars.map(c => Object.assign({}, c));
        Object.assign(list[index], changes);
        CalendarService.calendars = list;
    }

    function add(): void {
        CalendarService.calendars = CalendarService.calendars.concat([{
            id: Date.now().toString(36) + Math.random().toString(36).slice(2, 6),
            name: "Calendar " + (CalendarService.calendars.length + 1),
            url: "",
            color: CalendarService.nextColor(),
            enabled: true
        }]);
    }

    function remove(index: int): void {
        CalendarService.calendars = CalendarService.calendars.filter((c, i) => i !== index);
    }

    function statusOf(calendar): string {
        if ((calendar.url ?? "").trim() === "") return "Paste the calendar's iCal address.";
        if (calendar.enabled === false) return "Off, so it's hidden and not synced.";
        const saved = (CalendarService.store.savedValues.calendars ?? []).find(c => c.id === calendar.id);
        if (!saved || saved.url !== calendar.url || saved.enabled === false) return "Save to sync it.";
        const report = CalendarService.report.calendars?.[calendar.id];
        if (CalendarService.report.error) return CalendarService.report.error;
        if (!report) return CalendarService.syncing ? "Syncing…" : "Not synced yet.";
        if (!report.ok) return report.error;
        return report.count + (report.count === 1 ? " event" : " events") + " in the last year and the next 18 months.";
    }

    Looks.ClearText {
        text: "Calendar"
        font.pixelSize: Looks.Fonts.size + 8
        color: Settings.textColorOnContainer
    }

    SettingsRow {
        label: "Calendars"
        description: "Shown in the calendar under the bar's clock. For a Google calendar, paste its secret address "
            + "from Google Calendar › Settings › the calendar › Integrate calendar › Secret address in iCal format. "
            + "Anyone with that address can read the calendar, so it's kept in calendars.json, which git ignores."

        Button {
            buttonText: "Add calendar"
            fontSizeModifier: -1
            onClicked: root.add()
        }
    }

    Looks.ClearText {
        visible: CalendarService.calendars.length === 0
        text: "No calendars yet."
        font.pixelSize: Looks.Fonts.size - 1
        opacity: 0.5
        color: Settings.textColorOnContainer
    }

    // By count, so typing in a field doesn't rebuild its row.
    Repeater {
        model: CalendarService.calendars.length

        ColumnLayout {
            id: entry
            required property int index
            readonly property var calendar: CalendarService.calendars[index] ?? ({})

            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Row {
                    spacing: 4

                    Repeater {
                        model: CalendarService.slots

                        delegate: Rectangle {
                            id: swatch
                            required property string modelData
                            readonly property bool chosen: entry.calendar.color === modelData

                            width: 18
                            height: 18
                            radius: 9
                            color: CalendarStyle.accent(modelData)
                            border.width: chosen ? 2 : 0
                            border.color: Settings.textColorOnContainer

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.update(entry.index, { color: swatch.modelData })
                            }
                        }
                    }
                }

                TextBox {
                    Layout.fillWidth: true
                    text: entry.calendar.name ?? ""
                    placeholderText: "Name"
                    onTextEdited: root.update(entry.index, { name: text })
                }

                Button {
                    toggleButton: true
                    checked: entry.calendar.enabled !== false
                    buttonText: checked ? "On" : "Off"
                    fontSizeModifier: -1
                    onClicked: root.update(entry.index, { enabled: !checked })
                }

                Button {
                    buttonText: "\u{f0a7a}"
                    fontSizeModifier: -1
                    widthPadding: 14
                    onClicked: root.remove(entry.index)
                }
            }

            TextBox {
                Layout.fillWidth: true
                text: entry.calendar.url ?? ""
                placeholderText: "https://calendar.google.com/calendar/ical/…/basic.ics"
                onTextEdited: root.update(entry.index, { url: text })
            }

            Looks.ClearText {
                Layout.fillWidth: true
                text: root.statusOf(entry.calendar)
                wrapMode: Text.WordWrap
                font.pixelSize: Looks.Fonts.size - 2
                opacity: 0.65
                color: Settings.textColorOnContainer
            }
        }
    }

    SettingsRow {
        label: "Sync every"
        description: "Minutes between syncs. The calendar also syncs when it opens, after a suspend, and when you save here."

        NumberField {
            from: 1
            to: 120
            value: CalendarService.refreshMinutes
            onMoved: CalendarService.refreshMinutes = value
        }
    }

    SettingsRow {
        label: "Sync now"
        description: CalendarService.statusText(Time.time)

        Button {
            buttonText: "Sync"
            fontSizeModifier: -1
            onClicked: CalendarService.sync()
        }
    }

    Item { Layout.fillHeight: true }
}

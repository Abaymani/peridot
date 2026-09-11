import QtQuick
import Quickshell
import Quickshell.Io

// A group of settings in one JSON file. Edits apply live; save() writes them,
// revert() restores the saved values, and unsavedKeys lists what differs.
//
// Declare the settings as a JsonAdapter inside, then list the store on its
// page in Preferences.qml:
//
//     readonly property SettingsStore store: SettingsStore {
//         path: Quickshell.env("HOME") + "/.config/peridot/settings/foo.json"
//         JsonAdapter { id: jsonAdapter; property int bar: 1 }
//     }
//
// Settings must be plain values (bool, int, real, string, or JSON in a var);
// nested JsonObjects aren't tracked.
QtObject {
    id: root

    required property string path

    default property JsonAdapter adapter

    readonly property var unsavedKeys: Object.keys(savedValues).filter(key => !same(adapter[key], savedValues[key]))

    // Always replaced, never mutated, so bindings on it update.
    property var savedValues: ({})

    // Emitted after save() and saveKey(). Build derived files from savedValues,
    // not live values, so unsaved previews never leak into them.
    signal saved()

    function save(): void {
        file.writeAdapter();
        captureAll();
        saved();
    }

    // Not file.reload(): Quickshell only re-applies a file whose bytes changed,
    // and unsaved changes live in the adapter, so they'd survive a reload.
    function revert(): void {
        for (const key in savedValues)
            adapter[key] = copy(savedValues[key]);
    }

    // Saves only `key`, leaving other unsaved changes pending - for quick
    // toggles outside the settings window (e.g. the control center).
    function saveKey(key: string): void {
        keyWriter.reload();
        const onDisk = JSON.parse(keyWriter.text() || "{}");
        onDisk[key] = adapter[key];
        file.skipNextReload = true;
        // Same formatting as writeAdapter(), so only this key's line changes.
        keyWriter.setText(JSON.stringify(onDisk, null, 4) + "\n");
        savedValues = Object.assign({}, savedValues, { [key]: copy(adapter[key]) });
        saved();
    }

    function captureAll(): void {
        const values = {};
        for (const key of settingNames())
            values[key] = copy(adapter[key]);
        savedValues = values;
    }

    // Object.keys() on a QObject also returns objectName, methods, signals and
    // nested QObjects; keep only plain settings.
    function settingNames(): var {
        return Object.keys(adapter).filter(key => {
            const value = adapter[key];
            return key !== "objectName"
                && typeof value !== "function"
                && !(value !== null && typeof value === "object" && "objectName" in value);
        });
    }

    function copy(value): var {
        return value !== null && typeof value === "object" ? JSON.parse(JSON.stringify(value)) : value;
    }

    function same(a, b): bool {
        return a === b || JSON.stringify(a) === JSON.stringify(b);
    }

    readonly property FileView file: FileView {
        path: root.path
        adapter: root.adapter
        watchChanges: true

        // Skips the reload saveKey()'s own write triggers, which would reset
        // unsaved settings to the file.
        property bool skipNextReload: false
        onFileChanged: {
            if (skipNextReload) {
                skipNextReload = false;
                return;
            }
            reload();
        }

        // The file is now the saved state. Read it, not the adapter: a reload
        // of unchanged bytes keeps unsaved changes in the adapter.
        onLoaded: {
            let onDisk;
            try {
                onDisk = JSON.parse(text());
            } catch (e) {
                return; // Invalid JSON; the adapter couldn't load it either.
            }
            const values = Object.assign({}, root.savedValues);
            for (const key of root.settingNames())
                if (key in onDisk) values[key] = root.copy(onDisk[key]);
            root.savedValues = values;
        }
    }

    // saveKey() writes through this adapter-less view: a FileView re-applies
    // what it writes to its adapter, which would drop other unsaved changes.
    readonly property FileView keyWriter: FileView {
        path: root.path
        // So text() right after reload() returns the file as it is now.
        blockAllReads: true
        // Nothing was written, so there's no reload to skip.
        onSaveFailed: root.file.skipNextReload = false
    }

    // Defaults count as saved until the file loads (or if there is none).
    Component.onCompleted: captureAll()
}

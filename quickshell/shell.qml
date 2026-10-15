//@ pragma UseQApplication
import Quickshell
import qs
import qs.widgets
import qs.programs

Scope {
	Bar {}
	ControlCenter {}
	NotificationOverlay {}
	Launcher {}
	Switcher {}

	// Rarely opened, so they're made the first time they're needed instead of
	// at startup. The settings window alone took about a third of the load.
	LoadOnFirstUse { when: GlobalStates.isCalendarOpen; Calendar {} }
	LoadOnFirstUse { when: GlobalStates.isEmojiPickerOpen; EmojiPicker {} }
	LoadOnFirstUse { when: GlobalStates.isPowerMenuOpen; PowerMenu {} }
	LoadOnFirstUse { when: GlobalStates.isWallpaperPickerOpen; WallpaperPicker {} }
	LoadOnFirstUse { when: GlobalStates.isOskOpen || GlobalStates.screenLocked; OnScreenKeyboard {} }
	LoadOnFirstUse { when: GlobalStates.isSettingsOpen; Preferences {} }
}



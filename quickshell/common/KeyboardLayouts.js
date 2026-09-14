.pragma library

// On-screen keyboard layouts, shared by the shell's keyboard (services/Osk,
// programs/osk) and the login screen's (sddm/peridot-sddm links this file
// into its Components).
//
// A layout is rows of keys, each row 15 units wide (`width` defaults to 1).
// A `tall` key also covers the slot below it, which the next row leaves as a
// "gap" - the ISO Enter.
//   kind   "char" types a character: `label` plain, `shift` with Shift (a
//          letter's capital if missing), `altgr` with AltGr. `dead` marks an
//          accent that combines with the next letter.
//          "shift" and "caps" set the shift state; "mod" is a sticky
//          modifier; "altgr" is the AltGr modifier, which also relabels
//          characters; "key" is any other key; "gap" is an empty slot.
//   code   the Linux input event code (linux/input-event-codes.h), which the
//          shell sends through ydotool. The characters are what XKB's `xkb`
//          layout makes of those codes, so the shell's keyboard only types
//          them right if ydotool's virtual keyboard uses that layout -
//          hypr/input.lua lists these layouts for it, in this order.

function char(label, code, extra) {
  return Object.assign({ label: label, code: code, kind: "char" }, extra || {})
}

// Letters from `labels`, on consecutive codes from `firstCode`.
function letters(labels, firstCode) {
  return labels.split("").map((label, i) => char(label, firstCode + i))
}

function bottomRow(rightAlt) {
  return [
    { label: "Ctrl", code: 29, kind: "mod", width: 1.25 },
    { label: "Super", code: 125, kind: "mod", width: 1.25 },
    { label: "Alt", code: 56, kind: "mod", width: 1.25 },
    { label: "", code: 57, kind: "key", width: 6.25 },
    rightAlt,
    { label: "Ctrl", code: 97, kind: "mod" },
    { label: "←", code: 105, kind: "key" },
    { label: "↓", code: 108, kind: "key" },
    { label: "→", code: 106, kind: "key" }
  ]
}

var functionRow = [
  { label: "Esc", code: 1, kind: "key" },
  { label: "F1", code: 59, kind: "key" }, { label: "F2", code: 60, kind: "key" },
  { label: "F3", code: 61, kind: "key" }, { label: "F4", code: 62, kind: "key" },
  { label: "F5", code: 63, kind: "key" }, { label: "F6", code: 64, kind: "key" },
  { label: "F7", code: 65, kind: "key" }, { label: "F8", code: 66, kind: "key" },
  { label: "F9", code: 67, kind: "key" }, { label: "F10", code: 68, kind: "key" },
  { label: "F11", code: 87, kind: "key" }, { label: "F12", code: 88, kind: "key" },
  { label: "PrtSc", code: 99, kind: "key" },
  { label: "Del", code: 111, kind: "key" }
]

// Swedish, on an ISO keyboard (XKB "se"): AltGr is right Alt.
var swedish = {
  id: "se",
  name: "Svenska",
  short: "SE",
  xkb: "se",
  altGr: 100,
  rows: [
    [
      char("§", 41, { shift: "½" }),
      char("1", 2, { shift: "!" }), char("2", 3, { shift: "\"", altgr: "@" }),
      char("3", 4, { shift: "#", altgr: "£" }), char("4", 5, { shift: "¤", altgr: "$" }),
      char("5", 6, { shift: "%", altgr: "€" }), char("6", 7, { shift: "&" }),
      char("7", 8, { shift: "/", altgr: "{" }), char("8", 9, { shift: "(", altgr: "[" }),
      char("9", 10, { shift: ")", altgr: "]" }), char("0", 11, { shift: "=", altgr: "}" }),
      char("+", 12, { shift: "?", altgr: "\\" }), char("´", 13, { shift: "`", dead: true }),
      { label: "⌫", code: 14, kind: "key", width: 2 }
    ],
    [{ label: "Tab", code: 15, kind: "key", width: 1.5 }]
      .concat(letters("qw", 16), [char("e", 18, { altgr: "€" })], letters("rtyuiop", 19))
      .concat([
        char("å", 26),
        char("¨", 27, { shift: "^", altgr: "~", dead: true }),
        { label: "Enter", code: 28, kind: "key", width: 1.5, tall: true }
      ]),
    [{ label: "Caps", code: 58, kind: "caps", width: 1.5 }]
      .concat(letters("asdfghjkl", 30))
      .concat([
        char("ö", 39, { altgr: "ø" }), char("ä", 40, { altgr: "æ" }), char("'", 43, { shift: "*" }),
        { label: "", code: 0, kind: "gap", width: 1.5 }
      ]),
    [{ label: "Shift", code: 42, kind: "shift", width: 1.25 }, char("<", 86, { shift: ">", altgr: "|" })]
      .concat(letters("zxcvbnm", 44))
      .concat([
        char(",", 51, { shift: ";" }), char(".", 52, { shift: ":" }), char("-", 53, { shift: "_" }),
        { label: "Shift", code: 54, kind: "shift", width: 1.75 },
        { label: "↑", code: 103, kind: "key" }
      ]),
    bottomRow({ label: "AltGr", code: 100, kind: "altgr" })
  ]
}

// US English, on an ANSI keyboard (XKB "us"): right Alt is plain Alt.
var english = {
  id: "us",
  name: "English (US)",
  short: "US",
  xkb: "us",
  rows: [
    [
      char("`", 41, { shift: "~" }),
      char("1", 2, { shift: "!" }), char("2", 3, { shift: "@" }), char("3", 4, { shift: "#" }),
      char("4", 5, { shift: "$" }), char("5", 6, { shift: "%" }), char("6", 7, { shift: "^" }),
      char("7", 8, { shift: "&" }), char("8", 9, { shift: "*" }), char("9", 10, { shift: "(" }),
      char("0", 11, { shift: ")" }), char("-", 12, { shift: "_" }), char("=", 13, { shift: "+" }),
      { label: "⌫", code: 14, kind: "key", width: 2 }
    ],
    [{ label: "Tab", code: 15, kind: "key", width: 1.5 }]
      .concat(letters("qwertyuiop", 16))
      .concat([char("[", 26, { shift: "{" }), char("]", 27, { shift: "}" }), char("\\", 43, { shift: "|", width: 1.5 })]),
    [{ label: "Caps", code: 58, kind: "caps", width: 1.75 }]
      .concat(letters("asdfghjkl", 30))
      .concat([char(";", 39, { shift: ":" }), char("'", 40, { shift: "\"" }), { label: "Enter", code: 28, kind: "key", width: 2.25 }]),
    [{ label: "Shift", code: 42, kind: "shift", width: 2.25 }]
      .concat(letters("zxcvbnm", 44))
      .concat([
        char(",", 51, { shift: "<" }), char(".", 52, { shift: ">" }), char("/", 53, { shift: "?" }),
        { label: "Shift", code: 54, kind: "shift", width: 1.75 },
        { label: "↑", code: 103, kind: "key" }
      ]),
    bottomRow({ label: "Alt", code: 100, kind: "mod" })
  ]
}

var layouts = [swedish, english]

// The layout with id `id`, or the first one.
function byId(id) {
  for (const layout of layouts)
    if (layout.id === id) return layout
  return layouts[0]
}

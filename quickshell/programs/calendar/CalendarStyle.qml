pragma Singleton

import QtQuick
import Quickshell
import qs
import qs.common.looks as Looks
import qs.common.functions

// Calendar colors on both of peridot's looks. Flat surfaces use matugen's
// container pair, like other flat surfaces; gradient ones put the container
// at 70% under the shell's white text, which stays legible on bright
// wallpapers where a light tint washes out.
Singleton {
  readonly property color line: ColorUtils.setAlphaColor(Settings.textColorOnContainer, 0.1)

  // The theme's primary roles stand in until matugen has made the calendar ones.
  function role(name: string, fallback: string): color {
    const value = Looks.Colors.md3[name];
    return value && value !== "transparent" ? value : Looks.Colors.md3[fallback];
  }

  function accent(slot: string): color {
    return role("cal_" + slot, "primary");
  }

  function chipFill(slot: string): color {
    const container = role("cal_" + slot + "_container", "primary_container");
    return Settings.gradientBgEnabled ? ColorUtils.setAlphaColor(container, 0.7) : container;
  }

  function chipText(slot: string): color {
    return Settings.gradientBgEnabled
      ? Settings.textColorOnContainer
      : role("on_cal_" + slot + "_container", "on_primary_container");
  }
}

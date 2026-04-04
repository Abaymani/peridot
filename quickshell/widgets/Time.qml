pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  readonly property date time: {
    clock.date
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
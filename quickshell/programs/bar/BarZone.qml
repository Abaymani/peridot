import QtQuick
import QtQuick.Layouts
import QtQml.Models

// A section of the bar: the widgets named in `widgets` (see BarWidgets), in order.
RowLayout {
  id: root

  property var widgets: []

  spacing: 8

  Repeater {
    model: root.widgets.map(id => ({ widget: id }))

    delegate: DelegateChooser {
      role: "widget"

      DelegateChoice { roleValue: "updates"; Updates { Layout.fillWidth: false } }
      DelegateChoice { roleValue: "workspaces"; Workspaces { Layout.fillWidth: false } }
      DelegateChoice { roleValue: "activeWindow"; ActiveWindow { Layout.fillWidth: false } }
      DelegateChoice { roleValue: "network"; NetworkWidget {} }
      DelegateChoice { roleValue: "resources"; ResourceMonitor {} }
      DelegateChoice { roleValue: "audio"; AudioControls {} }
      DelegateChoice { roleValue: "media"; Mpris { Layout.fillWidth: false } }
      DelegateChoice { roleValue: "tray"; Tray { Layout.alignment: Qt.AlignVCenter } }
      DelegateChoice { roleValue: "battery"; BatteryWidget {} }
      DelegateChoice { roleValue: "clock"; ClockWidget {} }
      DelegateChoice { roleValue: "power"; Logout {} }
    }
  }
}

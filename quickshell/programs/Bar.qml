import Quickshell
import QtQuick
import QtQuick.Layouts
import "../widgets" as Widgets
import "../common/looks" as Looks
import "../common/utils/functions.js" as Utils

Scope {
    id: root
    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: 4
                left: 10
                right: 10
            }

            implicitHeight: 25
            color: "transparent"   // must be transparent

            Rectangle {
                anchors.fill: parent
                radius: 10
								color: "transparent"
                clip: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 8

										Widgets.Workspaces { Layout.fillWidth: false }

                    Item { Layout.fillWidth: true }

                    Widgets.ClockWidget { }
                }
            }
        }
    }
}


pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
  id: root
  property alias model: notifcationModel
  property alias popupModel: popupListModel

  property var objectMap: ({})
  property int _idCounter: 0

  ListModel {
    id: notifcationModel
  }

  ListModel {
    id: popupListModel
  }

  Component {
    id: popupTimerComponent
    Timer {
      interval: 5000
      running: true
      repeat: false
      property string targetId: ""

      onTriggered: {
        for (let i = 0; i < popupListModel.count; i++) {
          if (popupListModel.get(i).notifId === targetId) {
            popupListModel.remove(i)
            break
          }
        }
        destroy()
      }
    }
  }

  NotificationServer {
    id: notificationServer
    
    actionsSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    imageSupported: true
    keepOnReload: true 

    onNotification: (notification) => {
      notification.tracked = true

      let internalId = (_idCounter++).toString()
      root.objectMap[internalId] = {
        "notif": notification,
        "timeReceived": Date.now()
      }

      // Insert to show newest notifications on top of others.
      notifcationModel.insert(0, {"notifId": internalId})

      if (!notification.lastGeneration) {
        popupListModel.insert(0, {"notifId": internalId})
        popupTimerComponent.createObject(root, {"targetId": internalId})
      }
      // Also remove notifications in our reversed list.
      notification.closed.connect(() => {
        // Remove from the visual list
        for (let i = 0; i < notifcationModel.count; i++) {
          if (notifcationModel.get(i).notifId === internalId) {
            notifcationModel.remove(i)
            break
          }
        }
        
        for (let i = 0; i < popupListModel.count; i++) {
          if (popupListModel.get(i).notifId === internalId) {
            popupListModel.remove(i)
            break
          }
        }

        delete root.objectMap[internalId]
      })
    }
  }

    function dismiss(internalId) {
      if (root.objectMap[internalId]) {
        root.objectMap[internalId].notif.dismiss() 
      }
    }
    
    function getNotification(internalId) {
      return root.objectMap[internalId]
    }
}
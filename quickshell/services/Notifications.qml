pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
  id: root
  property var notificationServer: notificationServer

  NotificationServer {
    id: notificationServer
    
    actionsSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    imageSupported: true
    keepOnReload: true 

    onNotification: (notification) => {
      notification.tracked = true
    }
  }
}
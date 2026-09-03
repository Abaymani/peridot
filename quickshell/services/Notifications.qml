pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs

Singleton {
  id: root
  property alias model: notificationModel
  property alias popupModel: popupListModel

  // objectMap[internalId] = { data: <plain serializable snapshot>, notif: <live Notification or null>, timeReceived }
  // `data` is what the UI reads (works the same whether the notification just
  // arrived this session or was restored from disk); `notif` is only present
  // for notifications received this session and is what lets dismiss()/action
  // invocation reach back into the real DBus notification.
  property var objectMap: ({})
  property int _idCounter: 0

  ListModel {
    id: notificationModel
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
      const timeReceived = Date.now()
      root.objectMap[internalId] = {
        "data": root.toRecord(notification, timeReceived),
        "notif": notification,
        "timeReceived": timeReceived
      }

      // Insert to show newest notifications on top of others.
      notificationModel.insert(0, {"notifId": internalId})
      root.persistNotifications()

      if (!notification.lastGeneration && !GlobalStates.doNotDisturb) {
        popupListModel.insert(0, {"notifId": internalId})
        popupTimerComponent.createObject(root, {"targetId": internalId})
      }
      // Also remove notifications in our reversed list.
      notification.closed.connect(() => {
        root.removeFromModels(internalId)
        delete root.objectMap[internalId]
        root.persistNotifications()
      })
    }
  }

  // Snapshots every field Quickshell's Notification exposes into a plain,
  // JSON-serializable object - this is what gets persisted to disk and what
  // the UI reads from (see NotificationItem.qml), so restored notifications
  // render identically to live ones. `tracked`/`lastGeneration` are DBus
  // session bookkeeping rather than notification content, so they're not
  // part of the snapshot.
  function toRecord(notification, timeReceived) {
    let safeHints = {}
    try {
      safeHints = JSON.parse(JSON.stringify(notification.hints || {}))
    } catch (e) {
      safeHints = {}
    }

    const actions = []
    for (let i = 0; i < notification.actions.length; i++) {
      actions.push({"identifier": notification.actions[i].identifier, "text": notification.actions[i].text})
    }

    return {
      "id": notification.id,
      "appName": notification.appName,
      "appIcon": notification.appIcon,
      "summary": notification.summary,
      "body": notification.body,
      "urgency": notification.urgency,
      "actions": actions,
      "hasActionIcons": notification.hasActionIcons,
      "resident": notification.resident,
      "transient": notification.transient,
      "desktopEntry": notification.desktopEntry,
      "image": notification.image,
      "hasInlineReply": notification.hasInlineReply,
      "inlineReplyPlaceholder": notification.inlineReplyPlaceholder,
      "hints": safeHints,
      "expireTimeout": notification.expireTimeout,
      "timeReceived": timeReceived
    }
  }

  function removeFromModels(internalId) {
    for (let i = 0; i < notificationModel.count; i++) {
      if (notificationModel.get(i).notifId === internalId) {
        notificationModel.remove(i)
        break
      }
    }

    for (let i = 0; i < popupListModel.count; i++) {
      if (popupListModel.get(i).notifId === internalId) {
        popupListModel.remove(i)
        break
      }
    }
  }

  function dismiss(internalId) {
    const entry = root.objectMap[internalId]
    if (!entry) return

    if (entry.notif) {
      // Triggers the real DBus dismissal; removal + persistence happens in
      // the closed handler above once the server confirms it.
      entry.notif.dismiss()
    } else {
      // Restored notification - there's no live backing to dismiss, so just
      // drop it here.
      root.removeFromModels(internalId)
      delete root.objectMap[internalId]
      root.persistNotifications()
    }
  }

  function invokeAction(internalId, identifier) {
    const entry = root.objectMap[internalId]
    if (!entry || !entry.notif) return

    const action = entry.notif.actions.find(a => a.identifier === identifier)
    if (action) action.invoke()
  }

  function getNotification(internalId) {
    return root.objectMap[internalId]
  }

  function clearNotifications() {
    const ids = Object.keys(root.objectMap)
    for (let i = 0; i < ids.length; i++) {
      root.dismiss(ids[i])
    }
  }

  // --- Persistence ---
  // Notifications survive quickshell/computer restarts until dismissed. The
  // JSON file is the single source of truth for restored notifications;
  // notificationModel is rebuilt from it (newest first, matching how live
  // notifications get inserted) on startup. If the file is missing/deleted,
  // JsonAdapter just falls back to its declared default (an empty list).
  function persistNotifications() {
    const records = []
    for (let i = 0; i < notificationModel.count; i++) {
      const entry = root.objectMap[notificationModel.get(i).notifId]
      if (entry) records.push(entry.data)
    }
    notificationsAdapter.notifications = records
    notificationsFile.writeAdapter()
  }

  function loadPersistedNotifications() {
    const records = notificationsAdapter.notifications || []
    for (let i = 0; i < records.length; i++) {
      const record = records[i]
      const internalId = (_idCounter++).toString()
      root.objectMap[internalId] = {
        "data": record,
        "notif": null,
        "timeReceived": record.timeReceived
      }
      notificationModel.append({"notifId": internalId})
    }
  }

  FileView {
    id: notificationsFile
    path: Quickshell.env("HOME") + "/.config/peridot/.cache/notifications.json"

    // FileView loads asynchronously - restoring on Component.onCompleted
    // would race the read and always find the adapter still empty. onLoaded
    // only fires once the file has actually been read (a missing file fires
    // onLoadFailed instead, which needs no handling since the adapter's
    // declared default - an empty list - already covers that case).
    onLoaded: root.loadPersistedNotifications()

    JsonAdapter {
      id: notificationsAdapter

      property var notifications: []
    }
  }
}

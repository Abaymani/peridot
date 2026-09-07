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

  // Recomputed in persistNotifications() and once after the initial disk
  // load. notifIds stays newest-first, matching notificationModel.
  property var groupsByAppName: ({})
  property var appNameList: []

  function updateGroups() {
    const groups = {}
    for (let i = 0; i < notificationModel.count; i++) {
      const notifId = notificationModel.get(i).notifId
      const entry = root.objectMap[notifId]
      if (!entry) continue

      const appName = entry.data.appName || ""
      if (!groups[appName]) {
        groups[appName] = {
          "appName": appName,
          "appIcon": entry.data.appIcon,
          "notifIds": [],
          "latestTime": entry.timeReceived
        }
      }
      groups[appName].notifIds.push(notifId)
    }

    root.groupsByAppName = groups
    root.appNameList = Object.keys(groups).sort((a, b) => groups[b].latestTime - groups[a].latestTime)
  }

  // objectMap[internalId] = { data: <plain serializable snapshot>, notif: <live Notification or null>, timeReceived }
  // `notif` is null for notifications restored from disk - `data` is what the UI reads either way.
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

      // keepOnReload replays onNotification for still-open notifications
      // after a hot-reload rebuilds the component tree - rebind the existing
      // entry instead of inserting a duplicate.
      const existingId = root.findExistingInternalId(notification)
      if (existingId !== null) {
        const entry = root.objectMap[existingId]
        entry.notif = notification
        entry.data = root.toRecord(notification, entry.timeReceived)

        notification.closed.connect(() => {
          root.removeFromModels(existingId)
          delete root.objectMap[existingId]
          root.persistNotifications()
        })
        root.persistNotifications()
        return
      }

      let internalId = (_idCounter++).toString()
      const timeReceived = Date.now()
      root.objectMap[internalId] = {
        "data": root.toRecord(notification, timeReceived),
        "notif": notification,
        "timeReceived": timeReceived
      }

      notificationModel.insert(0, {"notifId": internalId})
      root.persistNotifications()

      if (!notification.lastGeneration && !GlobalStates.doNotDisturb) {
        popupListModel.insert(0, {"notifId": internalId})
        popupTimerComponent.createObject(root, {"targetId": internalId})
      }
      notification.closed.connect(() => {
        root.removeFromModels(internalId)
        delete root.objectMap[internalId]
        root.persistNotifications()
      })
    }
  }

  // Ids are only unique per sending app's session, hence the appName check.
  function findExistingInternalId(notification) {
    const ids = Object.keys(root.objectMap)
    for (let i = 0; i < ids.length; i++) {
      const entry = root.objectMap[ids[i]]
      if (entry.data.id === notification.id && entry.data.appName === notification.appName) {
        return ids[i]
      }
    }
    return null
  }

  // Snapshots into a plain, JSON-serializable object so restored
  // notifications render identically to live ones. `tracked`/`lastGeneration`
  // are DBus session bookkeeping, not notification content, so they're
  // excluded.
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
      // Removal + persistence happens in the closed handler once confirmed.
      entry.notif.dismiss()
    } else {
      // Restored notification - no live backing to dismiss.
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
  // notificationModel is rebuilt from the JSON file on startup, newest first.
  function persistNotifications() {
    root.updateGroups()

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
    root.updateGroups()
  }

  FileView {
    id: notificationsFile
    path: Quickshell.env("HOME") + "/.config/peridot/.cache/notifications.json"

    // FileView loads asynchronously - Component.onCompleted would race the
    // read and always find the adapter still empty.
    onLoaded: root.loadPersistedNotifications()

    JsonAdapter {
      id: notificationsAdapter

      property var notifications: []
    }
  }
}


//
//  DeviceActivityMonitorExtension.swift
//  ActivityMonitorExtension
//
//  Created by Robert Herber on 2023-07-05.
//

import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import os

func executeAction(action: [String: Any], placeholders: [String: String?], eventKey: String) {
  let type = action["type"] as? String

  if let sleepBefore = action["sleepBefore"] as? Int {
    sleep(ms: sleepBefore)
  }

  if type == "blockSelection" {
    if let familyActivitySelectionId = action["familyActivitySelectionId"] as? String {
      if let activitySelection = getFamilyActivitySelectionById(id: familyActivitySelectionId) {
        updateShield(
          shieldId: action["shieldId"] as? String,
          triggeredBy: eventKey,
          activitySelectionId: familyActivitySelectionId
        )

        sleep(ms: 50)

        do {
          try blockSelectedApps(
            blockSelection: activitySelection,
            triggeredBy: eventKey
          )
        } catch {

        }
      } else {
        logger.log("No familyActivitySelection found with ID: \(familyActivitySelectionId)")
      }
    }
  } else if type == "unblockSelection" {
    if let familyActivitySelectionId = action["familyActivitySelectionId"] as? String {
      if let activitySelection = getFamilyActivitySelectionById(id: familyActivitySelectionId) {

        do {
          try unblockSelection(
            removeSelection: activitySelection,
            triggeredBy: eventKey
          )
        } catch {

        }

        userDefaults?
          .removeObject(
            forKey: SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX + "_" + familyActivitySelectionId)
      }
    }
  } else if type == "disableBlockAllMode" {
    disableBlockAllMode(triggeredBy: eventKey)
  } else if type == "openApp" {
    // todo: replace with general string
    openUrl(urlString: "device-activity://")

    sleep(ms: 1000)
  } else if type == "enableBlockAllMode" {
    updateShield(
      shieldId: action["shieldId"] as? String,
      triggeredBy: eventKey,
      activitySelectionId: nil
    )

    // sometimes the shield doesn't pick up the shield config change above, trying a sleep to get around it
    sleep(ms: 50)

    enableBlockAllMode(triggeredBy: eventKey)
  } else if type == "sendNotification" {
    if let notification = action["payload"] as? [String: Any] {
      sendNotification(contents: notification, placeholders: placeholders)
    }
  } else if type == "sendHttpRequest" {
    if let url = action["url"] as? String {
      let config = action["options"] as? [String: Any] ?? [:]

      task = sendHttpRequest(with: url, config: config, placeholders: placeholders)

      // required for it to have time to trigger before process/callback ends
      sleep(ms: 1000)
    }
  }

  if let sleepAfter = action["sleepAfter"] as? Int {
    sleep(ms: sleepAfter)
  }
}

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  override func intervalDidStart(for activity: DeviceActivityName) {
    super.intervalDidStart(for: activity)
    logger.log("intervalDidStart")

    self.executeActionsForEvent(
      activityName: activity.rawValue,
      callbackName: "intervalDidStart",
      eventName: nil
    )

    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalDidStart"
    )

    notifyAppWithName(name: "intervalDidStart")
  }

  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
    logger.log("intervalDidEnd")

    self.executeActionsForEvent(
      activityName: activity.rawValue,
      callbackName: "intervalDidEnd",
      eventName: nil
    )

    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalDidEnd"
    )

    notifyAppWithName(name: "intervalDidEnd")
  }

  func executeActionsForEvent(
    activityName: String,
    callbackName: String,
    eventName: String?
  ) {
    let key =
      eventName != nil
      ? "actions_for_\(activityName)_\(callbackName)_\(eventName!)"
      : "actions_for_\(activityName)_\(callbackName)"

    let placeholders = [
      "activityName": activityName,
      "callbackName": callbackName,
      "eventName": eventName
    ]

    CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)

    if let actions = userDefaults?.array(forKey: key) {
      actions.forEach { actionRaw in
        if let action = actionRaw as? [String: Any] {
          let skipIfAlreadyTriggeredAfter = action["skipIfAlreadyTriggeredAfter"] as? Double
          let skipIfLargerEventRecordedAfter = action["skipIfLargerEventRecordedAfter"] as? Double
          let skipIfAlreadyTriggeredWithinMS = action["skipIfAlreadyTriggeredWithinMS"] as? Double
          let skipIfLargerEventRecordedWithinMS =
            action["skipIfLargerEventRecordedWithinMS"] as? Double
          let skipIfLargerEventRecordedSinceIntervalStarted =
            action["skipIfLargerEventRecordedSinceIntervalStarted"] as? Bool
          let neverTriggerBefore = action["neverTriggerBefore"] as? Double
          let skipIfAlreadyTriggeredBefore = action["skipIfAlreadyTriggeredBefore"] as? Double

          let skipIfAlreadyTriggeredBetweenFromDate =
            action["skipIfAlreadyTriggeredBetweenFromDate"] as? Double
          let skipIfAlreadyTriggeredBetweenToDate =
            action["skipIfAlreadyTriggeredBetweenToDate"] as? Double

          if shouldExecuteAction(
            skipIfAlreadyTriggeredAfter: skipIfAlreadyTriggeredAfter,
            skipIfLargerEventRecordedAfter: skipIfLargerEventRecordedAfter,
            skipIfAlreadyTriggeredWithinMS: skipIfAlreadyTriggeredWithinMS,
            skipIfLargerEventRecordedWithinMS: skipIfLargerEventRecordedWithinMS,
            neverTriggerBefore: neverTriggerBefore,
            skipIfLargerEventRecordedSinceIntervalStarted:
              skipIfLargerEventRecordedSinceIntervalStarted,
            skipIfAlreadyTriggeredBefore: skipIfAlreadyTriggeredBefore,
            skipIfAlreadyTriggeredBetweenFromDate: skipIfAlreadyTriggeredBetweenFromDate,
            skipIfAlreadyTriggeredBetweenToDate: skipIfAlreadyTriggeredBetweenToDate,
            activityName: activityName,
            callbackName: callbackName,
            eventName: eventName
          ) {
            executeAction(
              action: action,
              placeholders: placeholders,
              eventKey: key
            )
          }
        }
      }
    }
  }

  override func eventDidReachThreshold(
    _ event: DeviceActivityEvent.Name, activity: DeviceActivityName
  ) {
    super.eventDidReachThreshold(event, activity: activity)
    logger.log("eventDidReachThreshold: \(event.rawValue, privacy: .public)")

    self.executeActionsForEvent(
      activityName: activity.rawValue,
      callbackName: "eventDidReachThreshold",
      eventName: event.rawValue
    )

    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "eventDidReachThreshold",
      eventName: event.rawValue
    )

    notifyAppWithName(name: "eventDidReachThreshold")
  }

  override func intervalWillStartWarning(for activity: DeviceActivityName) {
    super.intervalWillStartWarning(for: activity)
    logger.log("intervalWillStartWarning")

    self.executeActionsForEvent(
      activityName: activity.rawValue,
      callbackName: "intervalWillStartWarning",
      eventName: nil
    )

    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalWillStartWarning"
    )

    notifyAppWithName(name: "intervalWillStartWarning")
  }

  override func intervalWillEndWarning(for activity: DeviceActivityName) {
    super.intervalWillEndWarning(for: activity)
    logger.log("intervalWillEndWarning")

    self.executeActionsForEvent(
      activityName: activity.rawValue,
      callbackName: "intervalWillEndWarning",
      eventName: nil
    )

    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "intervalWillEndWarning"
    )

    notifyAppWithName(name: "intervalWillEndWarning")
  }

  override func eventWillReachThresholdWarning(
    _ event: DeviceActivityEvent.Name, activity: DeviceActivityName
  ) {
    super.eventWillReachThresholdWarning(event, activity: activity)
    logger.log("eventWillReachThresholdWarning: \(event.rawValue, privacy: .public)")

    self.executeActionsForEvent(
      activityName: activity.rawValue,
      callbackName: "eventWillReachThresholdWarning",
      eventName: event.rawValue
    )

    persistToUserDefaults(
      activityName: activity.rawValue,
      callbackName: "eventWillReachThresholdWarning",
      eventName: event.rawValue
    )

    notifyAppWithName(name: "eventWillReachThresholdWarning")
  }

}
